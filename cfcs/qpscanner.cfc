<!--- qpscanner v0.7.5-dev | (c) Peter Boughton | License: GPLv3 | Website: sorcerersisle.com/projects:qpscanner.html --->
<cfcomponent output=false>

	<cffunction name="init" returntype="any" output=false access="public">
		<cfargument name="StartingDir"           type="String"  required        hint="Directory to begin scanning the contents of." />
		<cfargument name="OutputFormat"          type="String"  default="html"  hint="Format of scan results: [html,wddx]" />
		<cfargument name="RequestTimeout"        type="Numeric" default="-1"    hint="Override Request Timeout, -1 to ignore" />
		<cfargument name="recurse"               type="Boolean" default=false   hint="Also scan sub-directories?" />
		<cfargument name="Exclusions"            type="String"  default=""      hint="Exclude files & directories matching this regex." />
		<cfargument name="scanOrderBy"           type="Boolean" default=true    hint="Include ORDER BY statements in scan results?" />
		<cfargument name="scanQoQ"               type="Boolean" default=true    hint="Include Query of Queries in scan results?" />
		<cfargument name="scanBuiltInFunc"       type="Boolean" default=true    hint="Include Built-in Functions in scan results?" />
		<cfargument name="showScopeInfo"         type="Boolean" default=true    hint="Show scope information in scan results?" />
		<cfargument name="highlightClientScopes" type="Boolean" default=true    hint="Highlight scopes with greater risk?" />
		<cfargument name="ClientScopes"          type="String"  default="form,url,client,cookie" hint="Scopes considered client scopes." />
		<cfargument name="NumericFunctions"      type="String"  default="val,year,month,day,hour,minute,second,asc,dayofweek,dayofyear,daysinyear,quarter,week,fix,int,round,ceiling,gettickcount,len,min,max,pi,arraylen,listlen,structcount,listvaluecount,listvaluecountnocase,rand,randrange" />
		<cfargument name="BuiltInFunctions"      type="String"  default="now,#Arguments.NumericFunctions#" />
		<cfargument name="ReturnSqlSegments"     type="Boolean" default=false   hint="Include separate SELECT/FROM/WHERE/etc in result data?" />

		<cfloop item="local.Arg" collection=#Arguments# >
			<cfset This[Arg] = Arguments[Arg]/>
		</cfloop>

		<cfset This.ClientScopes = ListToArray(This.ClientScopes) />

		<cfset This.Totals =
			{ AlertCount    = 0
			, QueryCount    = 0
			, FileCount     = 0
			, RiskFileCount = 0
			, Time          = 0
			}/>

		<cfset This.Timeout = false />

		<cfset Variables.ResultFields = "FileId,FileName,QueryAlertCount,QueryTotalCount,QueryId,QueryName,QueryStartLine,QueryEndLine,ScopeList,ContainsClientScope,QueryCode,FilteredCode" />
		<cfset Variables.AlertData = QueryNew(Variables.ResultFields)/>

		<cfset Variables.Regexes =
			{ findQueries      = new cfregex( '(?si)(?:<cfquery\b)(?:[^<]++|<(?!/cfquery>))+(?=</cfquery>)' )
			, isQueryOfQuery   = new cfregex( '(?si)dbtype\s*=\s*["'']query["'']' )
			, killParams       = new cfregex( '(?si)<cfqueryparam[^>]++>' )
			, killCfTag        = new cfregex( '(?si)<cf[a-z]{2,}[^>]*+>' ) <!--- Deliberately excludes Custom Tags and CFX --->
			, killOrderBy      = new cfregex( '(?si)\bORDER BY\b.*?$' )
			, killBuiltIn      = new cfregex( '(?si)##(#ListChangeDelims(This.BuiltInFunctions,'|')#)\([^)]*\)##' )
			, findScopes       = new cfregex( '(?si)(?<=##([a-z]{1,20}\()?)[^\(##<]+?(?=\.[^##<]+?##)' )
			, findQueryName    = new cfregex( '(?<=\bname\s{0,99}=\s{0,99})(?:"[^"]++"|''[^'']++''|[^"''\s]++)' )
			, Newline          = new cfregex( chr(10) )
			}/>

		<cfif This.ReturnSqlSegments >
			<cfset Variables.ResultFields &= ',QuerySegments' />
			<cfset var SegKeywords = '(?i:SELECT|FROM|WHERE|GROUP BY|HAVING|ORDER BY)' />

			<cfsavecontent variable="Variables.Regexes.Segs"><cfoutput>
				(?x)

				## Segment names must be preceeded by newline or paren.
				## This helps avoid strings/variables causing confusion.
				(?<=
					(?:^|[()\n])
					\s{0,99}
				)
				#SegKeywords#[\s(]

				## This part needs to lazily consume content until it finds
				## the next segment, whilst also making sure it's not
				## dealing with a [bracketed] column name.
				##
				## For performance, splitting out whitespace and parens
				## allows the negative charset to match possessively
				## without breaking the overall laziness.
				(?:
					[^\[\s()]++
				|
					[\s()]+
				|
					\[(?!\s*#SegKeywords#\s*\])
				)+?

				## A segment must be ended by either end of string or
				## another segment.
				(?=
					$
				|
					(?<=[)\s])#SegKeywords#[\s(]
				)
			</cfoutput></cfsavecontent>
			<cfset Variables.Regexes.Segs = new cfregex(trim(Variables.Regexes.Segs)) />

			<cfset Variables.Regexes.SegNames = new cfregex('(?<=^#SegKeywords#)') />
		</cfif>

		<cfset Variables.Exclusions = [] />
		<cfloop index="local.CurrentExclusion" list=#This.Exclusions# delimiters=";" >
			<cfset ArrayAppend( Variables.Exclusions , new cfregex(CurrentExclusion) ) />
		</cfloop>

		<cfreturn This/>
	</cffunction>


	<cffunction name="go" returntype="Struct" output=false access="public">
		<cfset var StartTime = getTickCount()/>

		<cfif This.RequestTimeout GT 0>
			<cfsetting requesttimeout=#This.RequestTimeout# />
		</cfif>

		<cftry>
			<cfset scan(This.StartingDir) />

			<!--- TODO: MINOR: CHECK: Is this the best way to handle this? --->
			<!--- If timeout occurs, ignore error and proceed. --->
			<cfcatch>
				<cfif find('timeout',cfcatch.message)>
					<cfset This.Timeout = true />
				<cfelse>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>

		<cfset This.Totals.Time = getTickCount() - StartTime/>

		<cfreturn
			{ Data = Variables.AlertData
			, Info =
				{ Totals  = This.Totals
				, Timeout = This.Timeout
				}
			}/>
	</cffunction>


	<cffunction name="scan" returntype="void" output=false access="private">
		<cfargument name="DirName" type="string" required />

		<cfif DirectoryExists(Arguments.DirName)>

			<cfdirectory
				name      = "local.qryDir"
				directory = #Arguments.DirName#
				sort      = "type ASC,name ASC"
			/>

			<cfloop query="qryDir">
				<cfset var CurrentTarget = Arguments.DirName & '/' & Name />

				<cfset var process = true />
				<cfloop index="local.CurrentExclusion" array=#Variables.Exclusions# >
					<cfif CurrentExclusion.matches( CurrentTarget )>
						<cfset process = false />
						<cfbreak />
					</cfif>
				</cfloop>
				<cfif NOT process> <cfcontinue/> </cfif>

				<cfif (Type EQ "dir") AND This.recurse >

					<cfset scan( CurrentTarget )/>

				<cfelseif Type EQ "file">

					<cfset var Ext = LCase(ListLast(CurrentTarget,'.')) >

					<cfif Ext EQ 'cfc' OR Ext EQ 'cfm' OR Ext EQ 'cfml'>

						<cfset var qryCurData = hunt( CurrentTarget )/>

						<cfif qryCurData.RecordCount>
							<cfset QueryAppend( Variables.AlertData , qryCurData )/>
						</cfif>

					</cfif>

				</cfif>

			</cfloop>

		<!--- This can only potentially trigger on first iteration, if This.StartingDir is a file. --->
		<cfelseif FileExists(Arguments.DirName)>

			<cfset var qryCurData = hunt( This.StartingDir )/>

			<cfif qryCurData.RecordCount>
				<cfset QueryAppend( Variables.AlertData , qryCurData )/>
			</cfif>

		<cfelse>

			<cfthrow
				message = "Specified path [#Arguments.DirName#] cannot be accessed or does not exist."
				type    = "qpscanner.qpscanner.Scan.InvalidPath"
			/>
		</cfif>

	</cffunction>


	<cffunction name="hunt" returntype="Query" output=false access="private">
		<cfargument name="FileName" type="String" required />
		<cfset var qryResult = QueryNew(Variables.ResultFields) />

		<cfset local.FileData = FileRead(Arguments.FileName) />

		<cfset var Matches = Variables.Regexes['findQueries'].find( text=FileData , returntype='info' ) />

		<cfloop index="CurMatch" array=#Matches# >

			<cfset var QueryTagCode = ListFirst( CurMatch.Match , '>' ) />
			<cfset var QueryCode    = ListRest( CurMatch.Match , '>' ) />

			<cfset var rekCode = Variables.Regexes['killParams'].replace( QueryCode , '' )/>
			<cfset rekCode     = Variables.Regexes['killCfTag'].replace( rekCode , '' )/>

			<cfif NOT This.scanOrderBy>
				<cfset rekCode = Variables.Regexes['killOrderBy'].replace( rekCode , '' )/>
			</cfif>
			<cfif NOT This.scanBuiltInFunc>
				<cfset rekCode = Variables.Regexes['killBuiltIn'].replace( rekCode , '' )/>
			</cfif>

			<cfif (NOT find( '##' , rekCode ))
				OR (NOT This.scanQoQ AND Variables.Regexes['isQueryOfQuery'].matches( CurMatch.Match ) )
				>
				<cfcontinue />
			</cfif>

			<cfset var CurRow = QueryAddRow(qryResult)/>

			<cfset qryResult.QueryCode[CurRow]    = QueryCode.replaceAll( Chr(13)&Chr(10) , Chr(10) ).replaceAll( Chr(13) , Chr(10) ) />
			<cfset qryResult.FilteredCode[CurRow] = rekCode.replaceAll( Chr(13)&Chr(10) , Chr(10) ).replaceAll( Chr(13) , Chr(10) ) />

			<cfif This.showScopeInfo >
				<cfset var ScopesFound = {} />

				<cfloop index="local.CurScope" array=#Variables.Regexes['findScopes'].match( rekCode )# >
					<cfset ScopesFound[CurScope] = true />
				</cfloop>

				<cfset qryResult.ContainsClientScope[CurRow] = false />
				<cfif This.highlightClientScopes>
					<cfloop index="local.CurrentScope" array=#This.ClientScopes# >
						<cfif StructKeyExists( ScopesFound , CurrentScope )>
							<cfset qryResult.ContainsClientScope[CurRow] = true />
							<cfbreak/>
						</cfif>
					</cfloop>
				</cfif>

				<cfset qryResult.ScopeList[CurRow] = StructKeyList(ScopesFound) />
			</cfif>

			<cfif This.ReturnSqlSegments AND findNoCase('select',ListFirst(qryResult.QueryCode[CurRow],chr(10))) >
				<cftry>
					<cfset var RawSegs = Regexes.Segs.match(qryResult.QueryCode[CurRow]) />
					<cfset var SegStruct = {} />

					<cfcatch type="java.lang.StackOverflowError">
						<!---
							There's a chance of failing on complex
							queries; if so, ignore and continue scan.
						--->
						<cfset var RawSegs = [] />
						<cfset var SegStruct = "failed" />
					</cfcatch>
				</cftry>

				<cfloop index="local.CurSeg" array=#RawSegs# >
					<cfset CurSeg = Variables.Regexes.SegNames.split( text=trim(CurSeg) , limit=1 ) />
					<cfset CurSeg = {Name=CurSeg[1],Code=CurSeg[2]} />

					<cfif StructKeyExists(SegStruct,CurSeg.Name)>
						<cfif isSimpleValue(SegStruct[CurSeg.Name])>
							<cfset SegStruct[CurSeg.Name] = [ SegStruct[CurSeg.Name] ] />
						</cfif>
						<cfset ArrayAppend(SegStruct[CurSeg.Name],trim(CurSeg.Code)) />
					<cfelse>
						<cfset SegStruct[CurSeg.Name] = trim(CurSeg.Code) />
					</cfif>
				</cfloop>

				<cfset qryResult.QuerySegments[CurRow] = SegStruct />
			</cfif>

			<cfset var BeforeQueryCode = left( FileData , CurMatch.Pos ) />

			<cfset var StartLine = 1+Variables.Regexes['Newline'].matches( BeforeQueryCode , 'count' ) />
			<cfset var LineCount = Variables.Regexes['Newline'].matches( CurMatch.Match , 'count' ) />

			<cfset qryResult.QueryStartLine[CurRow] = StartLine/>
			<cfset qryResult.QueryEndLine[CurRow]   = StartLine + LineCount />
			<cfset qryResult.QueryName[CurRow]      = ArrayToList(Variables.Regexes['findQueryName'].match(text=QueryTagCode,limit=1)) />
			<cfset qryResult.QueryId[CurRow]        = hash(QueryTagCode&QueryCode,'SHA') />
			<cfif NOT Len( qryResult.QueryName[CurRow] )>
				<cfset qryResult.QueryName[CurRow] = "[unknown]"/>
			</cfif>
		</cfloop>

		<cfset var CurFileId = hash( Arguments.FileName & hash(FileData,'SHA') , 'SHA' ) />
		<cfloop query="qryResult">
			<cfset qryResult.FileId[qryResult.CurrentRow]          = CurFileId />
			<cfset qryResult.FileName[qryResult.CurrentRow]        = Arguments.FileName />
			<cfset qryResult.QueryTotalCount[qryResult.CurrentRow] = ArrayLen(Matches) />
			<cfset qryResult.QueryAlertCount[qryResult.CurrentRow] = qryResult.RecordCount />
		</cfloop>
		<cfset This.Totals.QueryCount += ArrayLen(Matches) />
		<cfset This.Totals.AlertCount += qryResult.RecordCount />
		<cfset This.Totals.FileCount++ />
		<cfif qryResult.RecordCount >
			<cfset This.Totals.RiskFileCount++ />
		</cfif>

		<cfreturn qryResult/>
	</cffunction>


	<cffunction name="QueryAppend" returntype="void" output=false access="private">
		<cfargument name="QueryOne" type="Query" required />
		<cfargument name="QueryTwo" type="Query" required />

		<cfset var OrigRow = QueryOne.RecordCount />

		<cfset QueryAddRow( QueryOne , QueryTwo.RecordCount )/>

		<cfloop index="local.CurCol" list=#QueryOne.ColumnList# >
			<cfloop query="QueryTwo">
				<cfset QueryOne[CurCol][OrigRow+CurrentRow] = QueryTwo[CurCol][CurrentRow] />
			</cfloop>
		</cfloop>

	</cffunction>


</cfcomponent>