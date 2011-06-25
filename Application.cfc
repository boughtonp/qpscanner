<cfcomponent output="false">

	<cfset This.Name = "qpscanner@#CGI.SERVER_NAME#"/>
	<cfset This.SessionManagement = true/>


	<cffunction name="onApplicationStart" returntype="Boolean" output="false">
		<cfset var Result = True/>

		<cfset Application.Version = "0.7.4"/>

		<cfset Application.Cfcs.jre      = createObject("component","cfcs.jre-utils").init()/>
		<cfset Application.Cfcs.Settings = createObject("component","cfcs.settings").init
			( jre             : Application.Cfcs.jre
			, ConfigDirectory : expandPath('./config')
			)/>
		<cfset Application.Cfcs.Scanner  = createObject("component","cfcs.qpscanner")/>

		<cfreturn Result/>
	</cffunction>


	<cffunction name="onRequestStart" returntype="Boolean" output="false">
		<cfset var Result = True/>

		<!--- TODO: FIX: Implement as URL check once CFCs are stable. --->
		<cfif True>
			<cfset Result = Result AND onApplicationStart()/>
		</cfif>

		<cfreturn Result/>
	</cffunction>


</cfcomponent>