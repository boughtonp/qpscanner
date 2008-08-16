<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->

			<!--- Attributes. --->
			<cfparam name="Attributes.Errors"          type="Any"    default="#ThisTag.PFCT.ErrorsVar#"/>
			<cfparam name="Attributes.ListClass"       type="String" default="#ThisTag.PFCT.ErrorListClass#"/>
			<cfparam name="Attributes.Class"       type="String" default="#ThisTag.PFCT.ErrorListClass#"/>
			<cfparam name="Attributes.HighlightClass"  type="String" default="#ThisTag.PFCT.ErrorClass#"/>
			<cfparam name="Attributes.Label"           type="String" default=""/>
			<cfparam name="Attributes.Message"         type="String" default="Please correct the following errors:"/>
			<cfparam name="Attributes.HighlightErrors" type="Boolean" default="#ThisTag.PFCT.HighlightErrors#"/>
			<cfparam name="Attributes.UseLegend"       type="Boolean" default="#ThisTag.PFCT.UseLegend#"/>


			<cfif IsSimpleValue(Attributes.Errors)>
				<cfif StructKeyExists(Caller, Attributes.Errors)>
					<cfset Attributes.Errors = Caller[Attributes.Errors]/>
				<cfelseif IsDefined(Attributes.Errors)>
					<cfset Attributes.Errors = Evaluate(Attributes.Errors)/>
				<cfelse>
					<!--- TODO: Improve this bit. --->
					<cfset Attributes.Errors = ListToArray(Attributes.Errors)/>
				</cfif>
			</cfif>

		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->


			<cfif IsArray(Attributes.Errors) AND ArrayLen(Attributes.Errors)>
				<cfoutput><fieldset #ThisTag.PFCT.readAttributes(Attributes,'Fieldset,{NON}','label,message,highlighterrors,errors,listclass,uselegend,highlightclass')#>
					<cfif Len(Attributes.Label)><cfif Attributes.UseLegend>
						<legend #ThisTag.PFCT.readAttributes(Attributes,'Legend,Label')#>#Attributes.Label#</legend>
					<cfelse>
						<div #ThisTag.PFCT.readAttributes(Attributes,'Legend,Label')#>#Attributes.Label#</div>
					</cfif></cfif>
						<cfif Len(Attributes.Message)><p>#Attributes.Message#</p></cfif>
						<ul class="#Attributes.ListClass#"></cfoutput>
						<cfloop index="i" from="1" to="#ArrayLen(Attributes.Errors)#">
							<cfif IsSimpleValue(Attributes.Errors[i])>
								<cfoutput><li>#Attributes.Errors[i]#</li></cfoutput>
							<cfelseif IsStruct(Attributes.Errors[i])>
								<cfif StructKeyExists(Attributes.Errors[i],'Message')>
									<cfoutput><li>#Attributes.Errors[i].Message#
									</cfoutput>
										<cfif StructKeyExists(Attributes.Errors[i],'Id')>
											<cfparam name="Attributes.Errors[i].Label" default="#Attributes.Errors[i].Id#"/>
											<cfif ListLen(Attributes.Errors[i].Id,'|') EQ 1>
											<cfoutput>(Field: <a href="###Attributes.Errors[i].Id#">#Attributes.Errors[i].Label#</a>)</cfoutput>
											<cfelse>
											<cfoutput>(Fields: <cfloop index="n" from="1" to="#ListLen(Attributes.Errors[i].Id,'|')#"><cfif n GT 1> and </cfif>
												<a href="###ListGetAt(Attributes.Errors[i].Id,n,'|')#">#ListGetAt(Attributes.Errors[i].Label,n,'|')#</a></cfloop>)</cfoutput>
											</cfif>
											<cfif Attributes.HighlightErrors>
												<cfparam name="ThisTag.ErrorFields" default="#ArrayNew(1)#"/>
												<cfset ArrayAppend(ThisTag.ErrorFields,LCase(Attributes.Errors[i].Id))/>
											</cfif>
										</cfif>
									<cfoutput></li></cfoutput>
								<cfelse>
									<cfoutput><li>
										<dl><cfloop index="ThisKey" list="#StructKeyList(Attributes.Errors[i])#">
											<dt>#ThisKey#:</dt>
											<dd>#Attributes.Errors[i][ThisKey]#;</dd>
										</cfloop></dl>
									</li></cfoutput>
								</cfif>
							<cfelse>
								<cftry>
									<cfoutput><li>#ToString(Attributes.Errors[i])#</li></cfoutput>
									<cfcatch>
										<cfoutput><li><cfdump var="#Attributes.Errors[i]#"/></li></cfoutput>
									</cfcatch>
								</cftry>
							</cfif>
						</cfloop>
						<cfoutput></ul>
						#ThisTag.GeneratedContent#
					</fieldset>

					<cfif StructKeyExists(ThisTag, 'ErrorFields')><script type="text/javascript">
					<!--
						function show_errors()
						{
						<cfloop index="i" from="1" to="#ArrayLen(ThisTag.ErrorFields)#">
						<cfloop index="ThisId" list="#ThisTag.ErrorFields[i]#" delimiters="|">
						<!---pfct.show_error('','#LCase(ThisId)#');</cfloop></cfloop>--->
						
						
						<!--- $j('###LCase(ThisId)#').parent().animate({backgroundColor:'olive'},'fast') --->
						

						<!--- TODO: Fix properly. --->
						// $j('###LCase(ThisId)#').parent().css('background','##800000');
						
						</cfloop></cfloop>

						}
						$j(document).ready(show_errors);
					// -->
					</script></cfif>
				</cfoutput>
				<cfset ThisTag.GeneratedContent = ""/>
			<cfelseif NOT IsArray(Attributes.Errors)>
				<cfoutput>APPLICATION ERROR: Expected Array!</cfoutput>
				<cfdump var="#Attributes.Errors#"/>
			</cfif>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>