<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->


			<!--- Standard Attributes: --->
			<cfparam name="Attributes.Id"              type="String"/>
			<cfparam name="Attributes.Name"            type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes.Label"           type="String"  default="#Attributes.Name#"/>
			<cfparam name="Attributes.Value"           type="String"  default=""/>
			<cfparam name="Attributes.Hint"            type="String"  default=""/>
			<cfparam name="Attributes.Required"        type="Boolean" default="False"/>
			<cfparam name="Attributes.Multi"           type="Boolean" default="False"/>
			<cfparam name="Attributes.Type"            type="String"  default="File"/>

			<!--- Other Attributes: --->
			<cfif Attributes.Multi>
				<cfparam name="Attributes.Min"         type="Numeric" default="1"/>
				<cfparam name="Attributes.Max"         type="Numeric" default="10"/>
			</cfif>

			<!--- Default Settings: --->
			<cfparam name="Attributes['Field:Class']"     type="String"  default="#ThisTag.PFCT.FieldClass#"/>
			<cfparam name="Attributes['Label:Class']"     type="String"  default="#ThisTag.PFCT.LabelClass#"/>
			<cfparam name="Attributes['Label:For']"       type="String"  default="#Attributes.Id#"/>


			<cfif Len(Attributes.Hint)>
				<cfparam name="Attributes['Hint:Class']"  type="String"  default="#ThisTag.PFCT.HintClass#"/>
				<cfparam name="Attributes['Hint:Id']"     type="String"  default="#Attributes.Id#_hint"/>
			</cfif>


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


			<cfset ExcludedFields = "label,hint,required"/>


		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<!--- TODO: Display a message if form uploading hasn't been enabled? --->

			<!--- HTML Display. --->
			<cfoutput><div #ThisTag.PFCT.readAttributes(Attributes,'Field')#>
				<label #ThisTag.PFCT.readAttributes(Attributes, 'Label')#>#Attributes.Label#</label>
				<input #ThisTag.PFCT.readAttributes(Attributes, 'Input,Upload,{NON}', ExcludedFields)#/></cfoutput>
				<cfif Attributes.Multi>
					<!--- TODO: Multiple upload fields. --->
				</cfif>
				<cfif Len(Attributes.Hint)><cfoutput><small #ThisTag.PFCT.readAttributes(Attributes,'Hint')#>#Attributes.Hint#</small></cfoutput></cfif>
				<cfoutput>#ThisTag.GeneratedContent#
			</div></cfoutput>
			<cfset ThisTag.GeneratedContent = ""/>


		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>