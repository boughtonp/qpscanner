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

			<!--- Other Attributes: --->
			<cfparam name="Attributes.MinDate"         type="String"  default=""/>
			<cfparam name="Attributes.MaxDate"         type="String"  default=""/>
			<cfparam name="Attributes.OutputFormat"    type="String"  default="#ThisTag.PFCT.DateOutputFormat#"/>
			<cfparam name="Attributes.InputPriority"   type="String"  default="#ThisTag.PFCT.DateInputPriority#"/>
			<cfparam name="Attributes.DateFunction"    type="String"  default="#Evaluate(DE(ThisTag.PFCT.DateFunction))#"/>
			<cfparam name="Attributes.Calendar"        type="Boolean" default="False"/>
			<cfparam name="Attributes.CalendarScript"  type="String"  default="#ThisTag.PFCT.CalendarScript#"/>
			<cfparam name="Attributes.CalendarMethod"  type="String"  default="#ThisTag.PFCT.CalendarMethod#"/>
			<cfparam name="Attributes.CalendarImage"   type="String"  default="#ThisTag.PFCT.CalendarImage#"/>
			<cfparam name="Attributes.CalendarFunction" type="String" default="#Evaluate(DE(ThisTag.PFCT.CalendarFunction))#"/>

			<!--- Default Settings: --->
			<cfparam name="Attributes['Field:Class']"     type="String"  default="#ThisTag.PFCT.FieldClass#"/>
			<cfparam name="Attributes['Label:Class']"     type="String"  default="#ThisTag.PFCT.LabelClass#"/>
			<cfparam name="Attributes['Label:For']"       type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes['Input:Class']"      type="String"  default="#ThisTag.PFCT.EditClass#"/>
			<cfparam name="Attributes['Hint:Class']"      type="String"  default="#ThisTag.PFCT.HintClass#"/>

			<cfparam name="Attributes['Input:Onblur']"       type="String"  default=""/>

			<cfset Attributes['Input:Onblur'] = ListPrepend(Attributes['Input:Onblur'], Attributes.DateFunction, ';')/>

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


			<cfset ExcludedFields = "label,hint,required,calendar,calendarscript,calendarmethod,calendarimage,calendarfunction,datefunction,"
				& "inputpriority,outputformat,mindate,maxdate,validate,validationfunction,highlightaccesskey"/>


		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<!--- HTML Display. --->
			<cfoutput><div #ThisTag.PFCT.readAttributes(Attributes,'Field')#>
				<label #ThisTag.PFCT.readAttributes(Attributes, 'Label')#>#Attributes.Label#</label>
				<input #ThisTag.PFCT.readAttributes(Attributes, 'Input,Date,{NON}', ExcludedFields)#/></cfoutput>

				<cfif Attributes.Calendar>
					<cfswitch expression="#Attributes.CalendarMethod#">
						<cfcase value="CUSTOMTAG">
							<cfmodule template="#Attributes.CalendarScript#"
								targetelement="#Attributes.Id#"
								initialvalue="#Attributes.Value#"
							/>
						</cfcase>
						<cfcase value="CFINCLUDE">
							<cfinclude template="#Attributes.CalendarScript#"/>
						</cfcase>
						<cfcase value="JSINCLUDE">
							<cfoutput><script type="text/javascript" src="#Attributes.CalendarScript#"></script></cfoutput>
						</cfcase>
						<cfdefaultcase>
							<cfset ThisTag.PFCT.linkScript(ThisTag.PFCT.CalendarScript)/>
							<cfoutput><img class="calendar icon" src="#Attributes.CalendarImage#" alt="calendar" title="Show calendar"
								onclick="#Attributes.CalendarFunction#"/></cfoutput>
						</cfdefaultcase>
					</cfswitch>
				</cfif>

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