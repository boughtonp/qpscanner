<cfset Data = rc.ScanResults.Data />
<cfset Info = rc.ScanResults.Info />

<cfoutput>
	<p>Found #Info.Totals.AlertCount# potential risks across #Info.Totals.RiskFileCount# files,
		out of #Info.Totals.QueryCount# total queries in #Info.Totals.FileCount# scanned files,
		taking approx #(Info.Totals.Time\100)/10# seconds<cfif Info.Timeout> (timed out)</cfif>.</p>
</cfoutput>

<cfif Data.RecordCount>
	<script type="text/javascript" src="./resources/scripts/scan-results.js"></script>
	<br/>
	<fieldset class="controls" id="DisplayOptions">
		Enable JavaScript to allow display options.
	</fieldset>


	<fieldset class="main" id="results">
		<dl>
		<cfoutput query="Data" group="FileId">
			<dt class="file">
				<!---
				<input id="#FileId#" type="checkbox" name="Files" value="#FileName#"/>
				--->
				<label for="#FileId#">#FileName#</label>
				<span class="summary">
					- <strong class="alert">#QueryAlertCount#</strong> quer#iif(QueryAlertCount eq 1, "y", "ies")# to check:
				</span>
				<small class="id">#FileId#</small>
			</dt>
			<dd class="file_info" id="#FileId#_queries">
				<dl>
				<cfoutput>
					<dt class="query<cfif Len(ScopeList) AND ContainsClientScope> ContainsClientScope</cfif>">
						<label class="name" for="#QueryId#">#QueryName#</label>
						<cfif isNumeric(QueryStartLine)><small class="lines">(lines #QueryStartLine#..#QueryEndLine#)</small></cfif>
						<cfif Len(ScopeList)>
							<span class="scope_info">Scopes: #XmlFormat(ScopeList)# <cfif ContainsClientScope><em>!!!CLIENT SCOPE!!!</em></cfif></span>
						</cfif>
						<small class="id">#QueryId#</small>
					</dt>
					<cfset QCode = HtmlEditFormat(QueryCode).replaceAll( '(?<!\A)\r?\n' , '<br/>' )/>
					<dd class="query_code" id="#QueryId#">#QCode#</dd>
				</cfoutput>
				</dl>
			</dd>
		</cfoutput>
		</dl>
	</fieldset>

	</cfif>
