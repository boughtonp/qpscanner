<cfimport prefix="form" taglib="../../tags/form"/>

<form:main><!---action="#link(xfa.FormAction)#"--->

	<form:hidden id="instance" value="#Instance#"/>

	<cfoutput>
		<p>Found #Info.Totals.AlertCount# potential risks
			from #Info.Totals.QueryCount# queries
			across #Info.Totals.FileCount# files
			in approx #(Info.Totals.Time\100)/10# seconds <cfif Info.Timeout>(timed out)</cfif>.</p>
	</cfoutput>

<cfif Data.RecordCount>
	<script type="text/javascript" src="./resources/scripts/scan-results.js"></script>
	<br/>
	<form:controls id="DisplayOptions">Enable JavaScript to allow display options.</form:controls>


	<form:group id="results">
		<dl>
		<cfoutput query="Data" group="FileId">
			<dt class="file">
				<!---
				<input id="#FileId#" type="checkbox" name="Files" value="#FileName#"/>
				--->
				<label for="#FileId#">#FileName#</label>
				<span class="summary">
					- <strong class="alert">#QueryAlertCount#</strong> queries to check:
				</span>
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
					</dt>
					<cfset QCode = HtmlEditFormat(QueryCode).replaceAll( '(?<!\A)\n\r?' , '<br/>' )/>
					<dd class="query_code" id="#QueryId#">#QCode#</dd>
				</cfoutput>
				</dl>
			</dd>
		</cfoutput>
		</dl>
	</form:group>

	<!--- TODO: MINOR: Implement auto-fixing... --->
	<!---
		<form:controls>
			<form:submit value="Fix All"/>
			<form:submit value="Fix Selection"/>
		</form:controls>
	--->

	</cfif>

</form:main>