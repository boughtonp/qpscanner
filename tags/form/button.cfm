<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
		<cfinclude template="_init.cfm"/>
		<!---
			\\ CFML LOGIC \\
		--->


			<!--- Standard Attributes: --->
			<cfparam name="Attributes.Value"       type="String"  default=""/>

			<!--- Other Attributes: --->
			<cfparam name="Attributes.Type"        type="String"  default="button"/>
			<cfparam name="Attributes.HighlightAccessKey" type="Boolean"  default="#ThisTag.PFCT.HighlightAccessKey#"/>


			<!--- Standard Processing: --->
			<cfif ThisTag.PFCT.AutoTabIndex AND NOT StructKeyExists(Attributes,'TabIndex')>
				<cfset Attributes['TabIndex'] = ThisTag.PFCT.readNextTabIndex()/>
			</cfif>

			<cfif ThisTag.PFCT.AutoAccessKey AND NOT StructKeyExists(Attributes,'AccessKey')>
				<cfset Attributes['AccessKey'] = ThisTag.PFCT.readAccessKey(Attributes.Value)/>
			</cfif>

			<cfif StructKeyExists(Attributes,'AccessKey') AND Attributes.HighlightAccessKey>
				<cfset Attributes.Value = ThisTag.PFCT.readHighlighted(Attributes.Value,Attributes.AccessKey,'BTN')/>
			</cfif>

		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<cfif (Attributes.Type EQ "input")>
				<cfset Attributes.Type = "button"/>
				<cfoutput><input #ThisTag.PFCT.readAttributes(Attributes, '{ALL}', 'highlightaccesskey')#/></cfoutput>
			<cfelse>
				<cfoutput><button #ThisTag.PFCT.readAttributes(Attributes, '{ALL}', 'highlightaccesskey,value')#>#Attributes.Value&ThisTag.GeneratedContent#</button></cfoutput>
				<cfset ThisTag.GeneratedContent = ""/>
			</cfif>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>