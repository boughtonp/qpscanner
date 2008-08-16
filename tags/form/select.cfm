<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->

			<!--- Standard Attributes: --->
			<cfparam name="Attributes.Id"                 type="String"/>
			<cfparam name="Attributes.Name"               type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes.Label"              type="String"  default="#Attributes.Name#"/>
			<cfparam name="Attributes.Value"              type="String"  default=""/>
			<cfparam name="Attributes.Hint"               type="String"  default=""/>
			<cfparam name="Attributes.Required"           type="Boolean" default="False"/>

			<!--- Extra Attributes: ---->
			<cfparam name="Attributes.Mode"               type="String"  default="AUTO"/>
			<cfparam name="Attributes.Options"            type="String"  default=""/>
			<cfparam name="Attributes.Query"              type="String"  default=""/>
			<cfif Len(Attributes.Query)><cfset Attributes.Options = Caller[Attributes.Query]/></cfif>
			<cfparam name="Attributes.Fields"             type="String"  default="value,label,group"/>

			<!--- Options: --->
			<cfparam name="Attributes.Multi"              type="Boolean" default="False"/>
			<cfparam name="Attributes.Grouped"            type="Boolean" default="False"/>

			<!--- Default Settings: --->
			<cfparam name="Attributes['Field:Class']"     type="String"  default="#ThisTag.PFCT.FieldClass#"/>
			<cfparam name="Attributes['Label:Class']"     type="String"  default="#ThisTag.PFCT.LabelClass#"/>
			<cfparam name="Attributes['LabelI:Class']"    type="String"  default="#ThisTag.PFCT.LabelItemClass#"/>
			<cfparam name="Attributes['Label:For']"       type="String"  default="#Attributes.Id#"/>

			<!--- Others: --->
			<cfparam name="Attributes.AutoListMaxItems"   type="Numeric" default="#ThisTag.PFCT.AutoListMaxItems#"/>


			<cfif Attributes.Required>
				<cfset Attributes['Field:Class'] = ListAppend(Attributes['Field:Class'], ThisTag.PFCT.RequiredClasss, ' ')/>
			</cfif>

			<cfif Len(Attributes.Hint)>
				<cfparam name="Attributes['Hint:Id']"    type="String"  default="hint_#Attributes.Id#"/>
				<cfparam name="Attributes['Hint:Class']" type="String"  default="#ThisTag.PFCT.HintClass#"/>
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

			<cfset Attributes.Mode = UCase(Attributes.Mode)/>


		<!--- TODO: Cleanup - this bit shouldn't be so complicated. --->

			<cfif IsQuery(Attributes.Options)>
				<cfset ThisTag.Options = Attributes.Options/>

			<cfelseif IsArray(Attributes.Options)>
				<cfset ThisTag.Options = QueryNew("value,label,group")/>
				<cfloop index="ThisTag.i" from="1" to="#ArrayLen(Attributes.Options)#">
					<cfset QueryAddRow(ThisTag.Options)>
					<cfset QuerySetCell(ThisTag.Options, "value", ListGetAt(Attributes.Options[ThisTag.i], 1, ThisTag.PFCT.Splitters))/>
					<cfif ListLen(Attributes.Options[ThisTag.i], ThisTag.PFCT.Splitters) EQ 1>
						<cfset QuerySetCell(ThisTag.Options, "label", ListGetAt(Attributes.Options[ThisTag.i], 1, ThisTag.PFCT.Splitters))/>
					<cfelse>
						<cfset QuerySetCell(ThisTag.Options, "label", ListGetAt(Attributes.Options[ThisTag.i], 2, ThisTag.PFCT.Splitters))/>
						<cfif ListLen(Attributes.Options[ThisTag.i], ThisTag.PFCT.Splitters) EQ 3>
							<cfset QuerySetCell(ThisTag.Options, "group", ListGetAt(Attributes.Options[ThisTag.i], 3, ThisTag.PFCT.Splitters))/>
						</cfif>
					</cfif>
				</cfloop>

			<cfelseif IsStruct(Attributes.Options)>
				<cfset ThisTag.Options = QueryNew("value,label,group")/>
				<cfloop item="ThisTag.group" collection="#Attributes.Options#">
					<cfloop index="ThisTag.i" from="1" to="#ArrayLen(Attributes.Options[ThisTag.group])#">
						<cfset QueryAddRow(ThisTag.Options)>
						<cfset QuerySetCell(ThisTag.Options, "value", ListGetAt(Attributes.Options[ThisTag.i], 1, ThisTag.PFCT.Splitters))/>
						<cfif ListLen(Attributes.Options[ThisTag.i], ThisTag.PFCT.Splitters) EQ 1>
							<cfset QuerySetCell(ThisTag.Options, "label", ListGetAt(Attributes.Options[ThisTag.i], 1, ThisTag.PFCT.Splitters))/>
						<cfelse>
							<cfset QuerySetCell(ThisTag.Options, "label", ListGetAt(Attributes.Options[ThisTag.i], 2, ThisTag.PFCT.Splitters))/>
						</cfif>
						<cfset QuerySetCell(ThisTag.Options, "group", ThisTag.group)/>
					</cfloop>
				</cfloop>

			<cfelseif IsSimpleValue(Attributes.Options)>
				<cfif Attributes.Grouped AND ListLen(Attributes.Options, ThisTag.PFCT.GroupDelimiters) GT 1>
					<cfset ThisTag.Options = QueryNew("value,label,group")/>
					<cfloop index="ThisTag.i" from="1" to="#ListLen(Attributes.Options, ThisTag.PFCT.GroupDelimiters)#">
						<cfset ThisTag.group = ListGetAt(Attributes.Options, ThisTag.i, ThisTag.PFCT.GroupDelimiters)/>
						<cfset ThisTag.items = ListRest(ThisTag.group, ThisTag.PFCT.GroupSplitters)/>
						<cfset ThisTag.group = ListFirst(ThisTag.group, ThisTag.PFCT.GroupSplitters)/>
						<cfloop index="ThisTag.n" list="#ThisTag.items#">
							<cfset QueryAddRow(ThisTag.Options)/>
							<cfset QuerySetCell(ThisTag.Options, "value", ListFirst(ThisTag.n, ThisTag.PFCT.Splitters))/>
							<cfset QuerySetCell(ThisTag.Options, "label", ListLast(ThisTag.n, ThisTag.PFCT.Splitters))/>
							<cfset QuerySetCell(ThisTag.Options, "group", ThisTag.group)/>
						</cfloop>
					</cfloop>
				<cfelse>
					<cfset ThisTag.Options = QueryNew("value,label")/>
					<cfloop index="ThisTag.i" list="#Attributes.Options#">
						<cfset QueryAddRow(ThisTag.Options)/>
						<cfset QuerySetCell(ThisTag.Options, "value", ListFirst(ThisTag.i, ThisTag.PFCT.Splitters))/>
						<cfset QuerySetCell(ThisTag.Options, "label", ListLast(ThisTag.i, ThisTag.PFCT.Splitters))/>
					</cfloop>
				</cfif>

			</cfif>
		<!--- / --->



			<cfif Attributes.Mode EQ "AUTO">
				<cfif ThisTag.Options.RecordCount GTE Attributes.AutoListMaxItems>
					<cfset Attributes.Mode = "DROP"/>
				<cfelse>
					<cfset Attributes.Mode = "LIST"/>
				</cfif>
			</cfif>


			<cfswitch expression="#Attributes.Mode#">
				<cfcase value="DROP">
					<cfif Attributes.Multi>
						<cfset Attributes['Select:Multiple'] = "multiple"/>
					</cfif>
				</cfcase>
				<cfcase value="LIST">
					<cfparam name="Attributes['Input:Class']" type="String"  default="#ThisTag.PFCT.BoxClass#"/>
					<cfif Attributes.Multi>
						<cfset Attributes['Input:Type'] = "checkbox"/>
					<cfelse>
						<cfset Attributes['Input:Type'] = "radio"/>
					</cfif>
				</cfcase>
				<cfdefaultcase>
					<!--- TODO: Write custom code handling? --->
				</cfdefaultcase>
			</cfswitch>


			<cfset ThisTag.ValueColumn = ListGetAt(Attributes.Fields,1)/>
			<cfset ThisTag.LabelColumn = ListGetAt(Attributes.Fields,2)/>
			<cfif ListLen(Attributes.Fields) GT 2>
				<cfset ThisTag.GroupColumn = ListGetAt(Attributes.Fields,3)/>
			<cfelse>
				<cfset ThisTag.GroupColumn = ""/>
			</cfif>


			<cfset ExcludedAttributes = "Options,query,fields,mode,hint,required,validate,label,multi,value,grouped,"
				& "validationfunction,highlightaccesskey,autolistmaxitems"/>

		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<cfoutput><div #ThisTag.PFCT.readAttributes(Attributes,'Field')#>
				<label #ThisTag.PFCT.readAttributes(Attributes,'Label')#>#Attributes.Label#</label></cfoutput>

				<cfswitch expression="#Attributes.Mode#">
					<cfcase value="DROP">
						<cfoutput>
						<select #ThisTag.PFCT.readAttributes(Attributes,'Input,Select,{NON}',ExcludedAttributes)#></cfoutput>
						<cfif Len(ThisTag.GroupColumn)
							AND ListFindNoCase(ThisTag.Options.ColumnList, ThisTag.GroupColumn)>
							<cfoutput query="ThisTag.Options" group="#ThisTag.GroupColumn#">
								<optgroup label="#ThisTag.Options[ThisTag.GroupColumn][CurrentRow]#">
								<cfoutput>
									<option <cfif Attributes.Value EQ ThisTag.Options[ThisTag.ValueColumn][CurrentRow]>selected="selected"</cfif> value="#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" #ThisTag.PFCT.readAttributes(Attributes,'Option',ExcludedAttributes)#>#ThisTag.Options[ThisTag.LabelColumn][CurrentRow]#</option></cfoutput>
								</optgroup>
							</cfoutput>
						<cfelse>
							<cfoutput query="ThisTag.Options">
								<option value="#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" <cfif Attributes.Value EQ ThisTag.Options[ThisTag.ValueColumn][CurrentRow]>selected="selected"</cfif> #ThisTag.PFCT.readAttributes(Attributes,'Option',ExcludedAttributes)#>#ThisTag.Options[ThisTag.LabelColumn][CurrentRow]#</option></cfoutput>
						</cfif>
						<cfoutput>
						</select></cfoutput>
					</cfcase>
					<cfcase value="LIST">
						<cfoutput>
						<ul class="#ThisTag.PFCT.InputListClass#"></cfoutput>
						<cfif Len(ThisTag.GroupColumn)
							AND ListFindNoCase(ThisTag.Options.ColumnList, ThisTag.GroupColumn)>
							<cfoutput query="ThisTag.Options" group="#ThisTag.GroupColumn#">
								<li><label>#ThisTag.Options[ThisTag.GroupColumn][CurrentRow]#</label>
								<ul>
								<cfoutput>
								<li><input id="#Attributes['Id']#_#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" <cfif Attributes.Value EQ ThisTag.Options[ThisTag.ValueColumn][CurrentRow]>checked="checked"</cfif> value="#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" name="#Attributes.Name#" #ThisTag.PFCT.readAttributes(Attributes,'Input,Option','id,'&ExcludedAttributes)#/>
								<label for="#Attributes['Id']#_#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" #ThisTag.PFCT.readAttributes(Attributes,'LabelI',ExcludedAttributes)#>#ThisTag.Options[ThisTag.LabelColumn][CurrentRow]#</label>
							</li></cfoutput>
								</ul></li>
							</cfoutput>
						<cfelse>
							<cfoutput query="ThisTag.Options">
								<li><input id="#Attributes['Id']#_#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" <cfif Attributes.Value EQ ThisTag.Options[ThisTag.ValueColumn][CurrentRow]>checked="checked"</cfif> value="#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" name="#Attributes.Name#" #ThisTag.PFCT.readAttributes(Attributes,'Input,Option','id,'&ExcludedAttributes)#/>
								<label for="#Attributes['Id']#_#ThisTag.Options[ThisTag.ValueColumn][CurrentRow]#" #ThisTag.PFCT.readAttributes(Attributes,'LabelI',ExcludedAttributes)#>#ThisTag.Options[ThisTag.LabelColumn][CurrentRow]#</label>
							</li></cfoutput>
						</cfif>
						<cfoutput>
						</ul></cfoutput>
					</cfcase>
				</cfswitch>


				<cfoutput>
				<cfif Len(Attributes.Hint)><small #ThisTag.PFCT.readAttributes(Attributes,'Hint')#>#Attributes.Hint#</small></cfif>
				#ThisTag.GeneratedContent#
			</div></cfoutput>
			<cfset ThisTag.GeneratedContent = ""/>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>