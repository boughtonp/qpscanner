
<cfparam name="Attributes.Config" default="default"/>
<cfparam name="Attributes.Instance" default="#createUuid()#"/>

<cfset ScanData = Settings.read( ConfigId:Attributes.Config , Format:'Struct' )/>

<!---
	INFO:
	Loop through settings and override any that have been specified.
--->
<cfloop item="Setting" collection="#ScanData#">
	<cfif StructKeyExists( Attributes , Setting )>
		<cfset ScanData[Setting] = Attributes[Setting] />
	</cfif>
</cfloop>