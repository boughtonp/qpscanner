<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->

			<!--- Attributes. --->
			<cfparam name="Attributes.Id"          type="String"/>
			<cfparam name="Attributes.Name"        type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes.Value"       type="String"  default=""/>
			<cfparam name="Attributes.Type"        type="String"  default="hidden"/>

		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<cfoutput><input #ThisTag.PFCT.readAttributes(Attributes)#/></cfoutput>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>