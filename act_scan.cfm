<cfset jre = CreateObject("component","jre-utils").init()/>

<cfset Request.TotalFound = 0/>
<cfset Request.TotalQueries = 0/>

<!---
	This script needs to be re-done, it's too ugly.
	Need to check if performance can be improved.
	Also needs to support different output formats.
--->

<cffunction name="huntQP" output="false">
	<cfargument name="filename"    type="string"/>
	<cfset var FileData = -1/>
	<cfset var Matches = -1/>
	<cfset var i = -1/>
	<cfset var info = -1/>
	<cfset var codebefore = -1/>
	<cfset var Result = StructNew()/>
	<cfset var UniqueToken = Chr(65536)/>

	<cfset var reFindQueries     = "(?s)(?<=(<cfquery[^p][^>]{0,300}>)).*?(?=</cfquery>)"/>
	<cfset var reKillParams      = "(?s)<cfqueryparam[^>]+>"/>

	<cffile action="read" file="#Arguments.filename#" variable="FileData"/>

	<cfset Matches = jre.Get(FileData,reFindQueries)/>

	<cfset Result.Filename = Arguments.filename/>
	<Cfset Result.QueryCount = ArrayLen(Matches)/>
	<cfset Result.Alert = ArrayNew(1)/>

	<cfloop index="i" from="1" to="#ArrayLen(Matches)#">
		<cfif Find( '##' ,  jre.Replace(Matches[i],reKillParams,'','ALL')  )>
			<cfset info = StructNew()/>
			<cfset info.index = i/>
			<cfset info.qry = Matches[i]/>
			<cfset codebefore = REReplace(Replace(FileData,Matches[i],UniqueToken),"#UniqueToken#.*$",'')/>
			<cfset info.line_start = 1+ArrayLen(jre.Get(codebefore,chr(10)))/>
			<cfset info.line_end = info.line_start + ArrayLen(jre.Get(info.qry,chr(10)))/>
			<cfset ArrayAppend(Result.Alert,info)/>
		</cfif>
	</cfloop>

	<cfset Result.AlertCount = ArrayLen(Result.Alert)/>

	<cfreturn Result/>
</cffunction>



<cffunction name="loopDir" output="true">
	<cfargument name="dirname" type="string"/>
	<cfargument name="recurse" type="boolean"/>
	<cfargument name="token"   type="string" default="<<<<<<e>>>>>>"/>
	<cfset var Data = -1/>
	<cfset var qryDir = -1/>

	<cfdirectory name="qryDir" directory="#Arguments.dirname#" sort="name ASC"/>

	<cfloop query="qryDir">

		<cfif (type EQ "dir") AND Arguments.recurse>

			<cfset loopDir( Arguments.dirname&'\'&name , true , arguments.token )/>

		<cfelseif Left(Right(name,4),3) EQ '.cf'>

			<cfset Data = huntQP( Arguments.dirname&'\'&name , arguments.token )/>

			<cfif Data.AlertCount>
				<div class="fRow" onclick="$j('##f#Hash(Data.Filename)#').toggle(50);">#Data.Filename# - <strong>#Data.AlertCount#</strong> found from #Data.QueryCount# queries.</div>
				<div id="f#Hash(Data.Filename)#" class="fSub">
					<cfloop index="i" from="1" to="#Data.AlertCount#">
						<div class="qRow" onclick="$j('##i#Hash(Data.Alert[i].qry)#').toggle(50);">#Data.Filename#:#Data.Alert[i].line_start#..#Data.Alert[i].line_end#</div>
						<pre id="i#Hash(Data.Alert[i].qry)#" class="qSub">#htmlEditFormat(Data.Alert[i].qry)#</pre>
					</cfloop>
				</div>
			</cfif>

			<cfset Request.TotalFound = Request.TotalFound + Data.AlertCount/>
			<cfset Request.TotalQueries = Request.TotalQueries + Data.QueryCount/>

			<cfflush/>
		</cfif>
	</cfloop>
</cffunction>



<cfoutput>
	<p id="status">Scanning...</p>
	<script type="text/javascript">
	<!--
		$j('##status').prepend('<img src="./scanning.gif" alt="..." title="Scanning"/>');
	// -->
	</script>

	<div id="results">
		<cfset loopDir( Url.StartDir , Url.Recurse )/>
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