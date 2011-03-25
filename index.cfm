<cfsetting showdebugoutput="true" enablecfoutputonly="true"/>
<cfset Request.Errors = ArrayNew(1)/>

<cffunction name="Variables.Struct" returntype="Struct"><cfreturn Arguments/></cffunction>
<cfif StructKeyExists(Variables,'Variables.Struct')>
	<cfset Variables.Struct = Variables['Variables.Struct']/>
</cfif>

<cfset jre = Application.Cfcs.jre/>

<cfset Settings = Application.Cfcs.Settings/>

<cffunction name="link"><cfreturn "./index.cfm?fuseaction="&LCase(Arguments[1])/></cffunction>

<cfset FUSEBOX_APPLICATION_KEY = 'qpscanner'/>

<cfset FUSEBOX_MODE = "production"/>

<cfset FUSEBOX_PARAMETERS = Struct
	( defaultFuseaction    : "start.intro"
	, fuseactionVariable   : "fuseaction"
	, allowImplicitFusebox : false
	, mode                 : FUSEBOX_MODE
	, debug                : false
	)/>

<cfinclude template="./fusebox5/fusebox5.cfm"/>


<cfsetting showdebugoutput="false"/>