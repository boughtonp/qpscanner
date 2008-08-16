<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->



		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->



		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>