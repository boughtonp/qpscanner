<cfcontent type="text/xml"/><cfoutput><?xml version="1.0" encoding="UTF-8"?>
<qpscanner>
	<cfset Data = rc.ScanResults.Data />
	<cfset Info = rc.ScanResults.Info />
	<info>
		<count>
			<alerts>#Info.Totals.AlertCount#</alerts>
			<riskfiles>#Info.Totals.RiskFileCount#</riskfiles>
			<queries>#Info.Totals.QueryCount#</queries>
			<files>#Info.Totals.FileCount#</files>
		</count>
		<timetaken timeout="#Info.Timeout#">#Info.Totals.Time#</timetaken>
	</info>

	</cfoutput>
	<cfoutput query="Data" group="FileId">
		<file id="#XmlFormat(FileId)#">
			<name>#XmlFormat(FileName)#</name>
			<alertcount>#QueryAlertCount#</alertcount>
			<queries>
			<cfoutput>
				<query id="#XmlFormat(QueryId)#">
					<name>#XmlFormat(QueryName)#</name>
					<cfif isNumeric(QueryStartLine)><startline>#QueryStartLine#</startline>
					<endline>#QueryEndLine#</endline></cfif>
					<cfif Len(ScopeList)><scopes>#XmlFormat(ScopeList)#</scopes></cfif>
					<code>#XmlFormat(QueryCode)#</code>
				</query>
			</cfoutput>
			</queries>
		</file>
	</cfoutput>
	<cfoutput>

</qpscanner></cfoutput>