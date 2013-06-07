<cfcomponent output="false" extends="framework">
	<cfsetting showdebugoutput=false />

	<cfset This.Name = "qpscanner_v0.7.5-dev@#CGI.SERVER_NAME#"/>
	<cfset This.SessionManagement = true/>

	<cfset Variables.Framework =
		{ DefaultSection   : 'start'
		, DefaultItem      : 'intro'
		, ReloadApplicationOnEveryRequest : true
		}/>

	<cffunction name="setupApplication" output="false">

		<cfset Application.Version = "0.7.5-dev"/>

		<cfset Application.Cfcs =
			{ Settings = new cfcs.settings( ConfigDirectory : expandPath('./config') )
			, Scanner  = createObject("component","cfcs.qpscanner")
			}/>
	</cffunction>


</cfcomponent>