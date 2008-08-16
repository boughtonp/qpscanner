<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->

			<cfloop item="ThisSetting" collection="#Attributes#">
				<cfset ThisTag.PFCT[ThisSetting] = Attributes[ThisSetting]/>
			</cfloop>

		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

		<cfif StructKeyExists(Attributes,'Debug') AND Attributes.Debug>
			<cfoutput><dl class="debug"></cfoutput>
				<cfloop item="ThisSetting" collection="#ThisTag.PFCT#">
				<cfoutput>
					<dt>#ThisSetting#</dt></cfoutput>
					<cfif IsSimpleValue(ThisTag.PFCT[ThisSetting])>
						<cfoutput><dd>#XmlFormat(ThisTag.PFCT[ThisSetting])#</dd></cfoutput>
					<cfelseif IsCustomFunction(ThisTag.PFCT[ThisSetting])>
						<cfoutput><dd>[function]</dd></cfoutput>
					<cfelseif IsObject(ThisTag.PFCT[ThisSetting])>
						<cfoutput><dd>[object]</dd></cfoutput>
					<cfelse>
						<cfoutput><dd><cfdump var="#ThisTag.PFCT[ThisSetting]#"/></dd></cfoutput>
					</cfif>
				</cfloop>
			<cfoutput></dl></cfoutput>
		</cfif>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>