<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->


			<!--- Standard Attributes: --->
			<cfparam name="Attributes.Id"          type="String"/>
			<cfparam name="Attributes.Name"        type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes.Label"       type="String"  default="#Attributes.Name#"/>
			<cfparam name="Attributes.Value"       type="String"  default=""/>
			<cfparam name="Attributes.Hint"        type="String"  default=""/>
			<cfparam name="Attributes.Required"    type="Boolean" default="False"/>

			<!--- Other Attributes: --->
			<cfparam name="Attributes.HighlightAccessKey" type="String"  default="#ThisTag.PFCT.HighlightAccessKey#"/>
			<cfparam name="Attributes.Validate"           type="Boolean" default="#ThisTag.PFCT.InlineValidation#"/>
			<cfparam name="Attributes.ValidationFunction" type="String"  default="#Evaluate(DE(ThisTag.PFCT.ValidationFunction))#"/>


			<!--- Standard Processing: --->
			<cfif StructKeyExists(Attributes, 'TabIndex')>
				<cfset ThisTag.PFCT.reserveTabIndex(Attributes.TabIndex)/>
			<cfelseif ThisTag.PFCT.AutoTabIndex>
				<cfset Attributes['TabIndex'] = ThisTag.PFCT.readNextTabIndex()/>
			</cfif>

			<cfif ThisTag.PFCT.AutoAccessKey AND NOT StructKeyExists(Attributes,'AccessKey')>
				<cfset Attributes['AccessKey'] = ThisTag.PFCT.readAccessKey(Attributes.Label)/>
			</cfif>

			<cfif StructKeyExists(Attributes,'AccessKey') AND Attributes.HighlightAccessKey>
				<cfset Attributes.Label = ThisTag.PFCT.readHighlighted(Attributes.Label, Attributes.AccessKey)/>
			</cfif>

			<cfif Attributes.Validate>
				<cfloop index="ThisEvent" list="#ThisTag.PFCT.ValidationEvents#">
					<cfparam name="Attributes['Input:#ThisEvent#']" default=""/>
					<cfset Attributes['Input:#ThisEvent#'] = ListAppend(Attributes['Input:#ThisEvent#'], Attributes.ValidationFunction, ';')/>
				</cfloop>
			</cfif>


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