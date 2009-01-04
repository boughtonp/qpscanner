<cfsetting showdebugoutput="true" enablecfoutputonly="true"/>
<cfset Request.Errors = ArrayNew(1)/>

<cffunction name="Struct" returntype="Struct"><cfreturn Arguments/></cffunction>

<cfset jre = Application.Cfcs.jre/>

<cfset Settings = Application.Cfcs.Settings/>

<cffunction name="link"><cfreturn "./index.cfm?fuseaction="&LCase(Arguments[1])/></cffunction>

<cfset FUSEBOX_APPLICATION_KEY = 'qpscanner'/>

<cfif CGI.SERVER_NAME EQ 'qpscanner.dev'>
	<cfset FUSEBOX_MODE =  "development-full-load"/>
<cfelse>
	<cfset FUSEBOX_MODE = "production"/>
</cfif>

<cfset FUSEBOX_PARAMETERS = Struct
	( defaultFuseaction    : "start.intro"
	, fuseactionVariable   : "fuseaction"
	, allowImplicitFusebox : false
	, mode                 : FUSEBOX_MODE
	, debug                : false
	)/>

<cfinclude template="./fusebox5/fusebox5.cfm"/>


<cfsetting showdebugoutput="false"/>