
<!---
	INFO:
	Expands automatic values.
--->


<cfif StructKeyExists(ScanData,'RequestTimeout') AND NOT isNumeric(ScanData.RequestTimeout)>
	<cfset ScanData.RequestTimeout = -1/>
</cfif>

<cfif ScanData.StartingDir EQ 'auto'>
	<cfset ScanData.StartingDir = Settings.findHomeDirectory()/>
</cfif>


<cffunction name="isAbsoluteDirectory" returntype="Boolean" output="false">
	<cfargument name="DirName" type="String" />
	
	<cfif findnocase('windows',Server.OS.Name)>
		<cfreturn refindnocase('\A[a-z]:',Arguments.DirName) />
	<cfelse>
		<cfreturn (left(Arguments.DirName,1) EQ '/') />
	</cfif>
</cffunction>

<cfif NOT (ListFind('ColdFusion Server,BlueDragon',Server.ColdFusion.ProductName)
	AND isAbsoluteDirectory(ScanData.StartingDir)
	)>
	<cfset ScanData.StartingDir = expandPath( ScanData.StartingDir & '/' )/>
</cfif>


<cfset ScanData.StartingDir = jre.replace( ScanData.StartingDir , '\\' , '/' ,  'all' )/>
<cfset ScanData.StartingDir = jre.replace( ScanData.StartingDir , '/+$' , '' , 'all' )/>