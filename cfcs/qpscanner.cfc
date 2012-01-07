<cfcomponent output="false" displayname="qpscanner v0.7.5">

	<cffunction name="init" returntype="any" output="false" access="public">
		<cfargument name="StartingDir"           type="String"  required        hint="Directory to begin scanning the contents of."/>
		<cfargument name="OutputFormat"          type="String"  default="html"  hint="Format of scan results: [html,wddx]"/>
		<cfargument name="RequestTimeout"        type="Numeric" default="-1"    hint="Override Request Timeout, -1 to ignore"/>
		<cfargument name="recurse"               type="Boolean" default="false" hint="Also scan sub-directories?"/>
		<cfargument name="Exclusions"            type="String"  default=""      hint="Exclude files & directories matching this regex."/>
		<cfargument name="scanOrderBy"           type="Boolean" default="true"  hint="Include ORDER BY statements in scan results?"/>
		<cfargument name="scanQoQ"               type="Boolean" default="true"  hint="Include Query of Queries in scan results?"/>
		<cfargument name="scanBuiltInFunc"       type="Boolean" default="true"  hint="Include Built-in Functions in scan results?"/>
		<cfargument name="showScopeInfo"         type="Boolean" default="true"  hint="Show scope information in scan results?"/>
		<cfargument name="highlightClientScopes" type="Boolean" default="true"  hint="Highlight scopes with greater risk?"/>
		<cfargument name="ClientScopes"          type="String"  default="form,url,client,cookie" hint="Scopes considered client scopes."/>
		<cfargument name="NumericFunctions"      type="String"  default="val,year,month,day,hour,minute,second,asc,dayofweek,dayofyear,daysinyear,quarter,week,fix,int,round,ceiling,gettickcount,len,min,max,pi,arraylen,listlen,structcount,listvaluecount,listvaluecountnocase,rand,randrange"/>
		<cfargument name="BuiltInFunctions"      type="String"  default="now,#Arguments.NumericFunctions#"/>

		<cfloop item="local.Arg" collection="#Arguments#">
			<cfset This[Arg] = Arguments[Arg]/>
		</cfloop>

		<cfset This.Totals =
			{ AlertCount= 0
			, QueryCount= 0
			, FileCount = 0
			, DirCount  = 0
			, Time      = 0
			}/>

		<cfset This.Timeout = false/>

		<cfset Variables.ResultFields = "FileId,FileName,QueryAlertCount,QueryTotalCount,QueryId,QueryName,QueryStartLine,QueryEndLine,ScopeList,ContainsClientScope,QueryCode"/>
		<cfset Variables.AlertData = QueryNew(Variables.ResultFields)/>

		<cfset Variables.Regexes =
			{ findQueries      = new cfregex( '(?si)(?:<cfquery\b)(?:[^<]++|<(?!/cfquery>))+(?=</cfquery>)' )
			, isQueryOfQuery   = new cfregex( '(?si)dbtype\s*=\s*["'']query["'']' )
			, killParams       = new cfregex( '(?si)<cfqueryparam[^>]++>' )
			, killCfTag        = new cfregex( '(?si)<cf[a-z]{2,}[^>]*+>' ) <!--- Deliberately excludes Custom Tags and CFX --->
			, killOrderBy      = new cfregex( '(?si)\bORDER BY\b.*?$' )
			, killBuiltIn      = new cfregex( '(?si)##(#ListChangeDelims(This.BuiltInFunctions,'|')#)\([^)]*\)##' )
			, findScopes       = new cfregex( '(?si)(?<=##([a-z]{1,20}\()?)[^\(##<]+?(?=\.[^##<]+?##)' )
			, findClientScopes = new cfregex( '(?i)\b(#ListChangeDelims(This.ClientScopes,'|')#)\b' )
			, findQueryName    = new cfregex( '(?<=\bname\s{0,99}=\s{0,99})(?:"[^"]++"|''[^'']++''|[^"''\s]++)' )
			, Newline          = new cfregex( chr(10) )
			}/>

		<cfset Variables.Exclusions = [] />
		<cfloop index="local.CurrentExclusion" list="#This.Exclusions#" delimiters=";">
			<cfset ArrayAppend( Variables.Exclusions , new cfregex(CurrentExclusion) ) />
		</cfloop>


		<cfreturn This/>
	</cffunction>



	<cffunction name="go" returntype="any" output="false" access="public">
		<cfset var StartTime = getTickCount()/>

		<cfif This.RequestTimeout GT 0>
			<cfsetting requesttimeout="#This.RequestTimeout#"/>
		</cfif>

		<cftry>
			<cfset scan(This.StartingDir)/>

			<!--- TODO: MINOR: CHECK: Is this the best way to handle this? --->
			<!--- If timeout occurs, ignore error and proceed. --->
			<cfcatch>
				<cfif find('timeout',cfcatch.message)>
					<cfset This.Timeout = True/>
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



	<cffunction name="scan" returntype="void" output="false" access="public">
		<cfargument name="DirName"           type="string"/>

		<cfif DirectoryExists(Arguments.DirName)>

			<cfdirectory
				name="local.qryDir"
				directory="#Arguments.DirName#"
				sort="type ASC,name ASC"
			/>

			<cfloop query="qryDir">

				<cfset var CurrentTarget = Arguments.DirName & '/' & Name />

				<cfset var process = true/>
				<cfloop index="local.CurrentExclusion" array=#Variables.Exclusions#>
					<cfif CurrentExclusion.matches( CurrentTarget )>
						<cfset process = false/>
						<cfbreak />
					</cfif>
				</cfloop>
				<cfif NOT process> <cfcontinue/> </cfif>


				<cfif (Type EQ "dir") AND This.recurse >
					<cfset This.Totals.DirCount = This.Totals.DirCount + 1 />

					<cfset scan( CurrentTarget )/>

				<cfelse>
					<cfset var Ext = LCase(ListLast(CurrentTarget,'.')) >

					<cfif Ext EQ 'cfc' OR Ext EQ 'cfm' OR Ext EQ 'cfml'>

						<cfset This.Totals.FileCount = This.Totals.FileCount + 1 />

						<cfset var qryCurData = hunt( CurrentTarget )/>

						<cfif qryCurData.RecordCount>
							<cfset Variables.AlertData = QueryAppend( Variables.AlertData , qryCurData )/>
						</cfif>

					</cfif>

				</cfif>

			</cfloop>

		<!--- This can only potentially trigger on first iteration, if This.StartingDir is a file. --->
		<cfelseif FileExists(Arguments.DirName)>
			<cfset This.Totals.FileCount = This.Totals.FileCount + 1 />

			<cfset var qryCurData = hunt( This.StartingDir )/>

			<cfif qryCurData.RecordCount>
				<cfset Variables.AlertData = QueryAppend( Variables.AlertData , qryCurData )/>
			</cfif>
		</cfif>

	</cffunction>




	<cffunction name="hunt" returntype="Query" output="false">
		<cfargument name="FileName"    type="String"/>
		<cfset var UniqueToken = Chr(65536)/>
		<cfset var qryResult   = QueryNew(Variables.ResultFields)/>


		<cffile action="read" file="#Arguments.FileName#" variable="local.FileData"/>

		<cfset var Matches = Variables.Regexes['findQueries'].find( text=FileData , returntype='info' )/>
		<cfset This.Totals.QueryCount += ArrayLen(Matches) />

		<cfloop index="local.i" from="1" to="#ArrayLen(Matches)#">

			<cfset var QueryTagCode = ListFirst( Matches[i].Match , '>' ) />
			<cfset var QueryCode    = ListRest( Matches[i].Match , '>' ) />

			<cfset var rekCode = Variables.Regexes['killParams'].replace( QueryCode , '' )/>
			<cfset rekCode = Variables.Regexes['killCfTag'].replace( rekCode , '' )/>

			<cfif NOT This.scanOrderBy>
				<cfset rekCode = Variables.Regexes['killOrderBy'].replace( rekCode , '' )/>
			</cfif>
			<cfif NOT This.scanBuiltInFunc>
				<cfset rekCode = Variables.Regexes['killBuiltIn'].replace( rekCode , '' )/>
			</cfif>

			<cfset var isRisk = find( '##' , rekCode )/>


			<cfif (NOT This.scanQoQ) AND Variables.Regexes['isQueryOfQuery'].matches( Matches[i].Match )>
				<cfset isRisk = false/>
			</cfif>


			<cfif isRisk>
				<cfset var CurRow = QueryAddRow(qryResult)/>

				<cfset qryResult.QueryCode[CurRow] = QueryCode.replaceAll( Chr(13)&Chr(10) , Chr(10) ) />
				<cfset qryResult.QueryCode[CurRow] = qryResult.QueryCode[CurRow].replaceAll( Chr(13) , Chr(10) ) />

				<cfif This.showScopeInfo >

					<cfset var ScopesFound = {} />
					<cfloop index="local.CurScope" array="#Variables.Regexes['findScopes'].match( rekCode )#">
						<cfset ScopesFound[CurScope] = true />
					</cfloop>

					<cfset qryResult.ContainsClientScope[CurRow] = false/>
					<cfif This.highlightClientScopes>
						<cfloop index="local.CurrentScope" list="#This.ClientScopes#">
							<cfif StructKeyExists( ScopesFound , CurrentScope )>
								<cfset qryResult.ContainsClientScope[CurRow] = true/>
								<cfbreak/>
							</cfif>
						</cfloop>
					</cfif>

					<cfset qryResult.ScopeList[CurRow] = StructKeyList(ScopesFound) />
				</cfif>

				<cfset var BeforeQueryCode = left( FileData , Matches[i].Pos ) />

				<cfset var StartLine = 1+Variables.Regexes['Newline'].matches( BeforeQueryCode , 'count' ) />
				<cfset var LineCount = Variables.Regexes['Newline'].matches( Matches[i].Match , 'count' ) />

				<cfset qryResult.QueryStartLine[CurRow] = StartLine/>
				<cfset qryResult.QueryEndLine[CurRow]   = StartLine + LineCount />
				<cfset qryResult.QueryName[CurRow]      = ArrayToList(Variables.Regexes['findQueryName'].match(text=QueryTagCode,limit=1)) />
				<cfset qryResult.QueryId[CurRow]        = createUuid() />
				<cfif NOT Len( qryResult.QueryName[CurRow] )>
					<cfset qryResult.QueryName[CurRow] = "[unknown]"/>
				</cfif>

			</cfif>

		</cfloop>

		<cfset var CurFileId = createUUID()/>
		<cfloop query="qryResult">
			<cfset qryResult.FileId[qryResult.CurrentRow]          = CurFileId />
			<cfset qryResult.FileName[qryResult.CurrentRow]        = Arguments.FileName />
			<cfset qryResult.QueryTotalCount[qryResult.CurrentRow] = ArrayLen(Matches) />
			<cfset qryResult.QueryAlertCount[qryResult.CurrentRow] = qryResult.RecordCount />
		</cfloop>
		<cfset This.Totals.AlertCount = This.Totals.AlertCount + qryResult.RecordCount />

		<cfreturn qryResult/>
	</cffunction>


	<cffunction name="QueryAppend" returntype="Query" output="false" access="private">
		<cfargument name="QueryOne" type="Query"/>
		<cfargument name="QueryTwo" type="Query"/>
		<!--- Bug fix for CF9 --->
		<cfif NOT Arguments.QueryOne.RecordCount><cfreturn Arguments.QueryTwo /></cfif>
		<cfif NOT Arguments.QueryTwo.RecordCount><cfreturn Arguments.QueryOne /></cfif>
		<!--- / --->
		<cfquery name="local.Result" dbtype="Query">
			SELECT * FROM Arguments.QueryOne
			UNION SELECT * FROM Arguments.QueryTwo
		</cfquery>
		<cfreturn Result/>
	</cffunction>




</cfcomponent>