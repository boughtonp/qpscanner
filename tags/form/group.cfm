<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START"><cfsilent>
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->

			<!--- Attributes. --->
			<cfparam name="Attributes.Class" type="String" default="#ThisTag.PFCT.FieldsetClass#"/>
			<cfparam name="Attributes.Label" type="String" default=""/>

			<cfparam name="Attributes.UseLegend"        type="Boolean" default="#ThisTag.PFCT.UseLegend#"/>

			<cfif NOT Attributes.UseLegend>
				<cfparam name="Attributes['Label:Class']" type="String" default="#ThisTag.PFCT.FieldsetLabelClass#"/>
			</cfif>

		<!---
			// CFML LOGIC //
		--->
	</cfsilent></cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<cfoutput><fieldset #ThisTag.PFCT.readAttributes(Attributes,'Fieldset,{NON}','label,UseLegend')#></cfoutput>
				<cfif Len(Attributes.Label)>
					<cfif Attributes.UseLegend>
						<cfoutput><legend #ThisTag.PFCT.readAttributes(Attributes,'Legend,Label')#>#Attributes.Label#</legend></cfoutput>
					<cfelse>
						<cfoutput><div #ThisTag.PFCT.readAttributes(Attributes,'Legend,Label')#>#Attributes.Label#</div></cfoutput>
					</cfif>
				</cfif>
				<cfoutput>#ThisTag.GeneratedContent#
			</fieldset></cfoutput>
			<cfset ThisTag.GeneratedContent = ""/>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>