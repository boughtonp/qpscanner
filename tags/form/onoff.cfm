<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->

			<!--- TODO: Decide if to rename this tag to something else (eg: binary?) --->

			<!--- Attributes. --->
			<cfparam name="Attributes.Id"                 type="String"/>
			<cfparam name="Attributes.Name"               type="String"  default="#Attributes.Id#"/>
			<cfparam name="Attributes.Label"              type="String"  default="#Attributes.Name#"/>
			<cfparam name="Attributes.Value"              type="String"  default="1"/>
			<cfparam name="Attributes.Hint"               type="String"  default=""/>
			<cfparam name="Attributes.Required"           type="Boolean" default="False"/>
			<cfparam name="Attributes.Mode"               type="String"  default="single"/>
			<cfparam name="Attributes['Field:Class']"     type="String"  default="#ThisTag.PFCT.FieldClass#"/>
			<cfparam name="Attributes['Label:Class']"     type="String"  default="#ThisTag.PFCT.LabelHeaderClass#"/>
			<cfparam name="Attributes['Input:Class']"     type="String"  default="#ThisTag.PFCT.BoxClass#"/>
			<cfparam name="Attributes.Options"            type="String"  default="1:Yes,0:No"/>

			<!--- Default Settings: --->

			<cfif Attributes.Required>
				<cfset Attributes['Field:Class'] = ListAppend(Attributes['Field:Class'],ThisTag.PFCT.RequiredClass,' ')/>
			</cfif>
			<cfif Len(Attributes.Hint)>
				<cfparam name="Attributes['Hint:Id']"     type="String"  default="#Attributes.Id#_hint"/>
				<cfparam name="Attributes['Hint:Class']"  type="String"  default="#ThisTag.PFCT.HintClass#"/>
			</cfif>

			<!--- Other Attributes: --->
			<cfparam name="Attributes.HighlightAccessKey" type="String"  default="#ThisTag.PFCT.HighlightAccessKey#"/>
<!---
			<cfparam name="Attributes.Validate"           type="Boolean" default="#ThisTag.PFCT.InlineValidation#"/>
			<cfparam name="Attributes.ValidationFunction" type="String"  default="#Evaluate(DE(ThisTag.PFCT.ValidationFunction))#"/>
--->


			<!--- Standard Processing: --->

			<cfif ThisTag.PFCT.AutoAccessKey AND NOT StructKeyExists(Attributes,'AccessKey')>
				<cfset Attributes['AccessKey'] = ThisTag.PFCT.readAccessKey(Attributes.Label)/>
			</cfif>

			<cfif StructKeyExists(Attributes,'AccessKey') AND Attributes.HighlightAccessKey>
				<cfset Attributes.Label = ThisTag.PFCT.readHighlighted(Attributes.Label, Attributes.AccessKey)/>
			</cfif>

<!---
			<cfif Attributes.Validate>
				<cfloop index="ThisEvent" list="#ThisTag.PFCT.ValidationEvents#">
					<cfparam name="Attributes['Input:#ThisEvent#']" default=""/>
					<cfset Attributes['Input:#ThisEvent#'] = ListAppend(Attributes['Input:#ThisEvent#'], Attributes.ValidationFunction, ';')/>
				</cfloop>
			</cfif>
--->



			<cfset Attributes.Mode = UCase(Attributes.Mode)/>

			<cfswitch expression="#Attributes.Mode#">
				<cfcase value="SINGLE">
					<cfparam name="Attributes['Input:Type']"      type="String"  default="checkbox"/>
				</cfcase>
				<cfcase value="DOUBLE">
					<cfparam name="Attributes['Input:Type']"      type="String"  default="radio"/>
					<cfset Attributes['Label1'] = ListLast(ListFirst(Attributes.Options,','),':')/>
					<cfset Attributes['Label0'] = ListLast(ListLast(Attributes.Options,','),':')/>
					<cfset Attributes['Input1:Value'] = ListFirst(ListFirst(Attributes.Options,','),':')/>
					<cfset Attributes['Input0:Value'] = ListFirst(ListLast(Attributes.Options,','),':')/>
					<cfloop index="ThisTag.i" list="1,0">
						<cfparam name="Attributes['Input#ThisTag.i#:Id']" default="#Attributes.Id &'_'& Attributes['Input#ThisTag.i#:Value']#"/>
						<cfparam name="Attributes['Label#ThisTag.i#:For']" default="#Attributes['Input#ThisTag.i#:Id']#"/>
						<cfparam name="Attributes['Label#ThisTag.i#:Class']" default="#ThisTag.PFCT.LabelItemClass#"/>
					</cfloop>
					<cfif StructKeyExists(Attributes,'TabIndex')>
						<cfset ThisTag.PFCT.reserveTabIndex(ListFirst(Attributes.TabIndex))/>
						<cfset ThisTag.PFCT.reserveTabIndex(ListLast(Attributes.TabIndex))/>
					<cfelseif ThisTag.PFCT.AutoTabIndex>
						<cfset Attributes['Input1:TabIndex'] = ThisTag.PFCT.readNextTabIndex()/>
						<cfset Attributes['Input0:TabIndex'] = ThisTag.PFCT.readNextTabIndex()/>
					</cfif>
				</cfcase>
			</cfswitch>

			<cfset ExcludedAttr = 'label,label1,label0,hint,required,options,mode,validate,validationfunction,highlightaccesskey'/>

			<cfset DoubleExcludedAttr = ExcludedAttr&'id,value'/>

		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<cfoutput><div #ThisTag.PFCT.readAttributes(Attributes,'Field')#>
				<label for="#Attributes.Id#" #ThisTag.PFCT.readAttributes(Attributes,'Label')#>#Attributes.Label#</label></cfoutput>
				<cfswitch expression="#Attributes.Mode#">
					<cfcase value="SINGLE">
						<cfoutput><input #ThisTag.PFCT.readAttributes(Attributes,'Input,{NON}',ExcludedAttr)#/></cfoutput>
					</cfcase>
					<cfcase value="DOUBLE">
						<cfoutput><ul class="input">
							<cfloop index="ThisTag.i" list="1,0"><li>
								<input #ThisTag.PFCT.readAttributes(Attributes,'Input,Input#ThisTag.i#,{NON}',DoubleExcludedAttr)#/>
								<label #ThisTag.PFCT.readAttributes(Attributes,'Label#ThisTag.i#')#>#Attributes['Label#ThisTag.i#']#</label>
							</li>
							</cfloop>
						</ul></cfoutput>
					</cfcase>
				</cfswitch>
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