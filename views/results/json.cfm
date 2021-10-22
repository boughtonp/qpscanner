<cfcontent type="application/json"/><cfoutput>{
	<cfset Data = rc.ScanResults.Data />
	<cfset Info = rc.ScanResults.Info />
	"info" :
	{ "count" :
		{ "alerts"    : #Info.Totals.AlertCount#
		, "riskfiles" : #Info.Totals.RiskFileCount#
		, "queries"   : #Info.Totals.QueryCount#
		, "files"     : #Info.Totals.FileCount#
		}
	, "timetaken" : #Info.Totals.Time#
	, "timeout"   : #Info.Timeout#
	}

	, "files" : </cfoutput>
	[<cfoutput query="Data" group="FileId">
	<cfif CurrentRow GT 1>,</cfif>
		{ "id"         : #serializeJson(FileId)#
		, "name"       : #serializeJson(FileName)#
		, "alertcount" : #QueryAlertCount#
		, "queries" :
			<cfset SubRow = 0 />
			[<cfoutput><cfif SubRow++ >,</cfif>
				{ "id" : #serializeJson(QueryId)#
				, "name" : #serializeJson(QueryName)#
				<cfif isNumeric(QueryStartLine)>, "startline" : #QueryStartLine#
				, "endline" : #QueryEndLine#</cfif>
				<cfif Len(ScopeList)> , "scopes" : #serializeJson(ScopeList)#</cfif>
				, "code" : #serializeJson(QueryCode)#
				, "FilteredCode" : #serializeJson(FilteredCode)#
				<cfif StructKeyExists(Data,'QuerySegments')>
				, "segments" : #serializeJson(QuerySegments)#
				</cfif>
				}
			</cfoutput>]
		}
	</cfoutput>
	<cfoutput>]

}</cfoutput>