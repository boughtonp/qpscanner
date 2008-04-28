<cfset jre = CreateObject("component","jre-utils").init()/>

<cfparam name="Server.Separator.File" default="/"/>

<cfset Request.TotalFound = 0/>
<cfset Request.TotalQueries = 0/>

<!---
	This script needs to be re-done, it's too ugly.
	Need to check if performance can be improved.
	Also needs to support different output formats.
--->

<cffunction name="huntQP" output="false">
	<cfargument name="Filename"    type="string"/>
	<cfargument name="scanOrderBy" type="boolean" default="true"/>
	<cfargument name="showScopes"  type="boolean" default="false"/>
	<cfset var FileData = -1/>
	<cfset var Matches = -1/>
	<cfset var i = -1/>
	<cfset var info = -1/>
	<cfset var codebefore = -1/>
	<cfset var Result = StructNew()/>
	<cfset var UniqueToken = Chr(65536)/>
	<cfset var rekCode = ""/>

	<cfset var reFindQueries     = "(?si)(?<=(<cfquery[^p][^>]{0,300}>)).*?(?=</cfquery>)"/>
	<cfset var reKillParams      = "(?si)<cfqueryparam[^>]+>"/>
	<cfset var reKillSwitch      = "(?si)<cfswitch[^>]+>"/>
	<cfset var reKillIf          = "(?si)<cfif[^>]+>"/>
	<cfset var reKillOrderby     = "(?si)\bORDER BY\b.*?$"/>
	<cfset var reFindScopes      = "(?si)(?<=##([a-z]{1,20}\()?)[^\(##<]+?(?=\.[^##<]+?##)"/>
	<cfset var reFindName        = '(?si)(?<=(<cfquery[^>]{0,300}\bname=")).*?(?="[^>]{0,300}>)'/>

	<cffile action="read" file="#Arguments.filename#" variable="FileData"/>

	<cfset Matches = jre.Get(FileData,reFindQueries)/>

	<cfset Result.Filename = Arguments.filename/>
	<cfset Result.QueryCount = ArrayLen(Matches)/>
	<cfset Result.Alert = ArrayNew(1)/>

	<cfloop index="i" from="1" to="#ArrayLen(Matches)#">

		<cfset rekCode = jre.Replace(Matches[i],reKillParams,'','ALL')/>
		<cfset rekCode = jre.Replace(rekCode,reKillSwitch,'','ALL')/>
		<cfset rekCode = jre.Replace(rekCode,reKillIf,'','ALL')/>

		<cfif NOT Arguments.scanOrderBy>
			<cfset rekCode = jre.Replace(rekCode,reKillOrderby,'','ALL')/>
		</cfif>

		<cfif Find( '##' , rekCode )>
			<cfset info = StructNew()/>
			<cfset info.index = i/>
			<cfset info.qry = Matches[i]/>
			<cfif Arguments.showScopes>
				<cfset info.scopes = ArrayUnique( jre.get(Matches[i],reFindScopes) )/>
			</cfif>
			<cfset codebefore = REReplace(Replace(FileData,Matches[i],UniqueToken),"#UniqueToken#.*$",'')/>
			<cfset info.line_start = 1+ArrayLen(jre.Get(codebefore,chr(10)))/>
			<cfset info.line_end = info.line_start + ArrayLen(jre.get(Matches[i],chr(10)))/>
			<cfset info.name = ArrayToList(jre.get(ListLast(codebefore,chr(10)),reFindName))/>
			<cfif NOT Len(info.name)>
				<cfset info.name = "[unknown]"/>
			</cfif>
			<cfset ArrayAppend(Result.Alert,info)/>
		</cfif>

	</cfloop>

	<cfset Result.AlertCount = ArrayLen(Result.Alert)/>

	<cfreturn Result/>
</cffunction>



<cffunction name="loopDir" output="true">
	<cfargument name="DirName"      type="string"/>
	<cfargument name="recurse"      type="boolean"/>
	<cfargument name="scanOrderBy"  type="boolean" default="true"/>
	<cfargument name="showScopes"   type="boolean" default="false"/>
	<cfargument name="markScopes"   type="boolean" default="false"/>
	<cfargument name="ClientScopes" type="string"  default="cgi,cookie,form,url"/>
	<cfset var Data = -1/>
	<cfset var qryDir = -1/>
	<cfset var fId = -1/>
	<cfset var qId = -1/>
	<cfset var reFindClientScopes = "\b("&ListChangeDelims(Arguments.ClientScopes,'|')&")\b"/>

	<cfdirectory name="qryDir" directory="#Arguments.dirname#" sort="name ASC"/>

	<cfloop query="qryDir">

		<cfif (type EQ "dir") AND Arguments.recurse>

			<cfset loopDir
				( DirName      : Arguments.dirname & Server.Separator.File & name
				, recurse      : true
				, scanOrderBy  : Arguments.scanOrderBy
				, showScopes   : Arguments.showScopes
				, markScopes   : Arguments.markScopes
				, ClientScopes : Arguments.ClientScopes
				)/>

		<cfelseif Left(Right(name,4),3) EQ '.cf'>

			<cfset Data = huntQP
				( Filename    : Arguments.dirname & Server.Separator.File & name
				, scanOrderBy : Arguments.scanOrderBy
				, showScopes  : Arguments.showScopes
				)/>

			<cfif Data.AlertCount>
				<cfset fId = 'f'&Hash(Data.Filename)/>
				<div id="#fId#" class="fRow" onclick="$j('##info_#fId#').toggle(50);">
					#Data.Filename# - <strong>#Data.AlertCount#</strong> found from #Data.QueryCount# queries.
				</div>
				<div id="info_#fId#" class="fSub">
					<cfloop index="i" from="1" to="#Data.AlertCount#">
						<cfset qId = fId&'_'&Hash(Data.Alert[i].qry) />
						<div class="qRow" onclick="$j('###qId#').toggle(50);">
							<strong>#Data.Alert[i].Name#</strong>:#Data.Alert[i].line_start#..#Data.Alert[i].line_end#
							<cfif StructKeyExists(Data.Alert[i],'scopes') AND ArrayLen(Data.Alert[i].scopes)>
								<span class="scope_info">Scopes: #XmlFormat(ArrayToList(Data.Alert[i].scopes,' '))#</span>
								<cfif Arguments.MarkScopes AND REFind(reFindClientScopes,ArrayToList(Data.Alert[i].scopes,' '))>
									<script type="text/javascript">
									<!--
										$j('###fId#,##info_#fId#').addClass('scopeWarning');
									// -->
									</script>
								</cfif>
							</cfif>
						</div>
						<pre id="#qId#" class="qSub">#htmlEditFormat(Data.Alert[i].qry)#
						</pre>
					</cfloop>
				</div>
			</cfif>

			<cfset Request.TotalFound = Request.TotalFound + Data.AlertCount/>
			<cfset Request.TotalQueries = Request.TotalQueries + Data.QueryCount/>

			<cfflush/>
		</cfif>
	</cfloop>
</cffunction>


<cffunction name="ArrayUnique" returntype="Array" output="false">
	<cfargument name="ArrayVar" type="Array"/>
	<cfset var UniqueToken = Chr(65536)/>
	<cfset var Result = Duplicate(Arguments.ArrayVar)/>
	<cfset ArraySort(Result,'text')/>
	<cfset Result = ArrayToList( Result , UniqueToken )/>
	<cfset Result = REReplace( Result & UniqueToken , '(\b(.*?)\b)\1+' , '\1' , 'all' )/>
	<cfset Result = ListToArray( Result , UniqueToken )/>
	<cfreturn Result/>
</cffunction>


<cfoutput>
	<p id="status">Scanning...</p>
	<script type="text/javascript">
	<!--
		$j('##status').prepend('<img src="./scanning.gif" alt="..." title="Scanning"/>');
	// -->
	</script>

	<div id="results">
		<cfset loopDir
			( DirName      : Url.StartDir
			, recurse      : Url.Recurse
			, scanOrderBy  : Url.Scan_OrderBy
			, showScopes   : Url.Show_Scopes
			, markScopes   : Url.Highlight_Scopes
			, ClientScopes : Url.Client_Scopes
			)/>
	</div>

	<cfif Request.TotalQueries GT 0>
		<script type="text/javascript">
		<!--
			$j('##status').text('Scan complete. Select a file to see details of queries found, then select a query to see its code.');
		// -->
		</script>
		<p>Found #Request.TotalFound# out of #Request.TotalQueries# queries.</p>
	<cfelse>
		<script type="text/javascript">
		<!--
			$j('##status').text('Scan complete. No queries found.');
		// -->
		</script>
	</cfif>
</cfoutput>