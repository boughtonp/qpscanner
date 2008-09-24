
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

<cfset ScanData.StartingDir = expandPath( ScanData.StartingDir & '/' )/>

<!--- Fix for CF bug: --->
<cfif isDefined('Server.ColdFusion.ProductName')
	AND Server.ColdFusion.ProductName EQ 'ColdFusion Server'
	AND ListLen(ScanData.StartingDir,':') GT 2>
	<cfset ScanData.StartingDir = rereplace( ScanData.StartingDir , "^.*([A-Za-z]:[^:]+)$" , "\1" )/>
</cfif>
<!--- / --->

<cfset ScanData.StartingDir = jre.replace( ScanData.StartingDir , '\\' , '/' ,  'all' )/>
<cfset ScanData.StartingDir = jre.replace( ScanData.StartingDir , '/+$' , '' , 'all' )/>