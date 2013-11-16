<cfif StructKeyExists(Request,'Exception')>

	<cfif StructKeyExists(rc,'OutputFormat') AND NOT StructKeyExists(rc,'Debug')>
		<cfset ExceptionData =
			{ 'Type'    = Request.Exception.Cause.Type
			, 'Message' = Request.Exception.Cause.Message
			}/>
		<cfif StructKeyExists(Request.Exception.Cause,'TagContext')
			AND ArrayLen(Request.Exception.Cause.TagContext)
			>
			<cfset ExceptionData['RawTrace'] = Request.Exception.TagContext[1].raw_trace />
		</cfif>

		<cfswitch expression=#rc.OutputFormat#>
			<cfcase value="JSON">
				<cfcontent type="application/json"/><cfoutput>#serializeJson(ExceptionData)#</cfoutput>
			</cfcase>
			<cfcase value="WDDX">
				<cfcontent type="text/xml"/><cfwddx action="cfml2wddx" input="#ExceptionData#"/>
			</cfcase>
			<cfcase value="XML"><cfcontent reset type="text/xml"/><cfoutput><?xml version="1.0" encoding="UTF-8"?>
				<qpscanner><error type="#XmlFormat(ExceptionData.Type)#">
				<message>#XmlFormat(ExceptionData.Message)#</message>
				<cfif StructKeyExists(ExceptionData,'RawTrace')
				><raw-trace>#XmlFormat(ExceptionData.RawTrace)#</raw-trace></cfif>
				</error></qpscanner></cfoutput>
			</cfcase>
			<cfdefaultcase>
				<cfoutput><p class="error">
					<b>Error: #HtmlEditFormat(ExceptionData.Message)#</b>
					<br/>Type: #HtmlEditFormat(ExceptionData.Type)#
					<cfif StructKeyExists(ExceptionData,'RawTrace')
					><br/>RawTrace: #HtmlEditFormat(ExceptionData.RawTrace)#</cfif>
				</p></cfoutput>
			</cfdefaultcase>
		</cfswitch>

	<cfelse>
		<cfdump var=#Request.Exception# />
	</cfif>
<cfelse>
	No Exception?
</cfif>