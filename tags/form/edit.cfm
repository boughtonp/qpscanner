<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START"><cfsilent>
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->

			<!--- Attributes. --->
			<cfparam name="Attributes.Id"                 type="String"/>
			<cfparam name="Attributes.Name"               type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes.Label"              type="String"  default="#Attributes.Name#"/>
			<cfparam name="Attributes.Value"              type="String"  default=""/>
			<cfparam name="Attributes.Hint"               type="String"  default=""/>
			<cfparam name="Attributes.Required"           type="Boolean" default="False"/>
			<cfparam name="Attributes.Masked"             type="Boolean" default="False"/>
			<cfparam name="Attributes.Multi"              type="Boolean" default="False"/>
			<cfparam name="Attributes['Field:Class']"     type="String"  default="#ThisTag.PFCT.FieldClass#"/>
			<cfparam name="Attributes['Label:Class']"     type="String"  default="#ThisTag.PFCT.LabelClass#"/>
			<cfparam name="Attributes['Input:Class']"     type="String"  default="#ThisTag.PFCT.EditClass#"/>
			<cfparam name="Attributes['Label:For']"       type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes['Input:Type']"      type="String"  default="text"/>

			<!--- Default Settings: --->

			<cfif Attributes.Required>
				<cfset Attributes['Field:Class'] = ListAppend(Attributes['Field:Class'], ThisTag.PFCT.RequiredClass, ' ')/>
			</cfif>
			<cfif StructKeyExists(Attributes,'Readonly') AND Attributes.Readonly>
				<cfset Attributes['Field:Class'] = ListAppend(Attributes['Field:Class'], ThisTag.PFCT.ReadonlyClass, ' ')/>
				<!--- TODO: Remove; move to CSS --->
				<cfparam name="Attributes['Input:Style']" default=""/>
				<cfif NOT Find('border',Attributes['Input:Style'])>
					<cfset Attributes['Input:Style'] = ListAppend(Attributes['Input:Style'],'border: dotted 1px silver',';')/>
				</cfif>
				<!--- / --->
			</cfif>

			<cfif Attributes.Masked>
				<cfset Attributes['Input:Type'] = "password"/>
			</cfif>
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





			<cfset ThisTag.ExcludedAttributes = "label,required,masked,multi,validate,hint,validationfunction,highlightaccesskey"/>

		<!---
			// CFML LOGIC //
		--->
	</cfsilent></cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<cfoutput><div #ThisTag.PFCT.readAttributes(Attributes,'Field')#>
				<label #ThisTag.PFCT.readAttributes(Attributes,'Label')#>#Attributes.Label#</label></cfoutput>
				<cfif Attributes.Multi>
					<cfoutput>
					<textarea #ThisTag.PFCT.readAttributes(Attributes,'Input,Textarea,{NON}',ThisTag.ExcludedAttributes&',value,input:type')#>#Attributes.Value#</textarea></cfoutput>
				<cfelse>
					<cfoutput>
					<input #ThisTag.PFCT.readAttributes(Attributes,'Input,{NON}',ThisTag.ExcludedAttributes)#/></cfoutput>
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