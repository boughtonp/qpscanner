<cfsetting enablecfoutputonly="true"/>
<cfswitch expression="#UCase(ThisTag.ExecutionMode)#">
	<cfcase value="START">
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
			<cfparam name="Attributes.SendValue"          type="Boolean" default="#ThisTag.PFCT.SendValue#"/>
			<cfparam name="Attributes['Field:Class']"     type="String"  default="#ThisTag.PFCT.FieldClass#"/>
			<cfparam name="Attributes['Label:Class']"     type="String"  default="#ThisTag.PFCT.LabelClass#"/>
			<cfparam name="Attributes['Value:Class']"     type="String"  default="#ThisTag.PFCT.ValueClass#"/>
			<cfparam name="Attributes['Label:For']"       type="String"  default="#Attributes.Id#"/>

			<!--- Default Settings: --->

			<cfif Len(Attributes.Hint)>
				<cfparam name="Attributes['Hint:Class']"  type="String"  default="#ThisTag.PFCT.HintClass#"/>
				<cfparam name="Attributes['Hint:Id']"     type="String"  default="#Attributes.Id#_hint"/>
			</cfif>

			<cfif Attributes.SendValue>
				<cfparam name="Attributes['Hidden:Type']" type="String"  default="hidden"/>
				<cfparam name="Attributes['Hidden:Id']"   type="String"  default="#Attributes.Id#_hidden"/>
				<cfparam name="Attributes['Hidden:Name']" type="String"  default="#Attributes.Name#"/>
				<cfparam name="Attributes['Hidden:Value']" type="String" default="#Attributes.Value#"/>
			</cfif>

		<!---
			// CFML LOGIC //
		--->
	</cfcase>
	<cfcase value="END">
		<!---
			\\ HTML OUTPUT \\
		--->

			<cfoutput><div #ThisTag.PFCT.readAttributes(Attributes,'Field')#>
				<label #ThisTag.PFCT.readAttributes(Attributes,'Label')#>#Attributes.Label#</label>
				<div #ThisTag.PFCT.readAttributes(Attributes,'Value,{NON}','label,hint,value,name')#>#Attributes.Value#</div></cfoutput>
				<cfif Attributes.SendValue><cfoutput><input #ThisTag.PFCT.readAttributes(Attributes, 'Hidden')#/></cfoutput></cfif>
				<cfif Len(Attributes.Hint)><cfoutput><small #ThisTag.PFCT.readAttributes(Attributes, 'Hint')#>#Attributes.Hint#</small></cfoutput></cfif>
				<cfoutput>#ThisTag.GeneratedContent#
			</div></cfoutput>
			<cfset ThisTag.GeneratedContent = ""/>

		<!---
			// HTML OUTPUT //
		--->
	</cfcase>
</cfswitch>
<cfsetting enablecfoutputonly="false"/>