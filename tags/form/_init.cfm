<cfsilent>
	<!--- Old Railo versions and BlueDragon do not support the prefix:value attribute format, so we must convert from prefix_value. --->
	<cfif  (StructKeyExists(Server,'Railo')      AND Server.Railo.Version LT "1.0.0.032")
		OR (StructKeyExists(Server,'BlueDragon') AND Server.BlueDragon.Edition LTE 6)
		>
		<cfloop item="AttrName" collection="#Attributes#">
			<cfif Find('_',AttrName)>
				<cfset Attributes[Replace(AttrName,'_',':')] = Attributes[AttrName]/>
				<cfset StructDelete(Attributes, AttrName)/>
			</cfif>
		</cfloop>
	</cfif>
	<!--- / --->

	<!--- If no instance already setup, initiate it. --->
	<cfparam name="Attributes.Instance" default="PFCT"/>
	<cfif NOT StructKeyExists(Request, Attributes.Instance)>
		<cfset Request[Attributes.Instance] = CreateObject("component","pfct").init()/>
	</cfif>
	<cfset ThisTag.PFCT = Request[Attributes.Instance]/>
	<cfset ThisTag.Instance = Duplicate(Attributes.Instance)/>
	<cfset StructDelete(Attributes,'Instance')/>
	<!--- / --->

	<!--- Put main JS script in HEAD tag. --->
	<cfset ThisTag.PFCT.linkScript(ThisTag.PFCT.MainScript)/>
	<!--- / --->
</cfsilent>