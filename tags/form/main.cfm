<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START"><cfsilent>
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->


			<!--- If no action specified, determine what it should be. --->
			<cfif NOT StructKeyExists(Attributes,'Action')>

				<!--- Check if used in Fusebox context, if so default Xfa to FormAction and use. --->
				<cfif StructKeyExists(Caller,'Myself') AND StructKeyExists(Caller,'Xfa')
					AND (StructKeyExists(Attributes,'Xfa') OR StructKeyExists(Caller.Xfa,'FormAction'))>

					<cfparam name="Attributes.Xfa" default="FormAction"/>

					<cfset Attributes.Action = Caller.Myself & Caller.Xfa[Attributes.Xfa]/>

				<!--- Unknown context, set action to current script. --->
				<cfelse>
					<cfset Attributes.Action = CGI.CONTEXT_PATH & CGI.SCRIPT_NAME & CGI.PATH_INFO/>
					<cfif ThisTag.PFCT.QueryInAction>
						<cfset Attributes.Action = ListAppend(Attributes.Action, CGI.QUERY_STRING, '?')/>
					</cfif>
				</cfif>

			</cfif>

			<cfparam name="Attributes.Method"     type="String"  default="post"/>
			<cfparam name="Attributes.Uploads"    type="Boolean" default="False"/>

			<cfif Attributes.Uploads>
				<cfset Attributes.EncType = "multipart/form-data"/>
			</cfif>

			<cfset ThisTag.ExcludedAttributes = "xfa,uploads,InlineValidation,ValidationEvents,ValidationFunction,ValidationService"/>

		<!---
			// CFML LOGIC //
		--->
	</cfsilent></cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

		<cfoutput><form #ThisTag.PFCT.readAttributes(Attributes, '{ALL}', ThisTag.ExcludedAttributes)#>
			#ThisTag.GeneratedContent#
		</form></cfoutput>
		<cfset ThisTag.GeneratedContent = ""/>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>