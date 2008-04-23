<cfoutput>
	<form action="./index.cfm" method="GET">
		<fieldset>
			<div class="field">
				<label class="header" for="startdir">Starting Directory:</label>
				<input class="edit" type="text" name="startdir" value="C:\dev"/>
				<small class="hint">Absolute path or mapping. No ending slash required.</small>
			</div>
			<div class="field">
				<label class="header" for="recurse">Recursive?</label>
				<input class="box" type="radio" name="recurse" checked="true" value="1" id="recurse_1"/>
					<label class="indiv" for="recurse_1">Yes</label>
				<input class="box" type="radio" name="recurse" value="0" id="recurse_0"/>
					<label class="indiv" for="recurse_0">No</label>
				<small class="hint">Scan files in sub-directories also.</small>
			</div>
		</fieldset>
		<fieldset id="advanced">
			<legend>Advanced Settings</legend>
			<div class="field">
				<label class="header" for="scan_orderby">Scan Order By?</label>
				<input class="box" type="radio" name="scan_orderby" checked="true" value="1" id="scan_orderby_1"/>
					<label class="indiv" for="scan_orderby_1">Yes</label>
				<input class="box" type="radio" name="scan_orderby" value="0" id="scan_orderby_0"/>
					<label class="indiv" for="scan_orderby_0">No</label>
				<small class="hint">Disable to exclude the ORDER BY clause from search results.
				Variables in the ORDER BY cannot use cfqueryparam, but should still be checked.</small>
			</div>
			<div class="field">
				<label class="header" for="show_scopes">Show Scope Info?</label>
				<input class="box" type="radio" name="show_scopes" checked="true" value="1" id="show_scopes_1"/>
					<label class="indiv" for="show_scopes_1">Yes</label>
				<input class="box" type="radio" name="show_scopes" value="0" id="show_scopes_0"/>
					<label class="indiv" for="show_scopes_0">No</label>
				<small class="hint">When enabled, scans for and shows which scopes have been used.</small>
			</div>
			<div class="field">
				<label class="header" for="highlight_scopes">Highlight Client Scopes?</label>
				<input class="box" type="radio" name="highlight_scopes" value="1" id="highlight_scopes_1"/>
					<label class="indiv" for="highlight_scopes_1">Yes</label>
				<input class="box" type="radio" name="highlight_scopes" checked="true" value="0" id="highlight_scopes_0"/>
					<label class="indiv" for="highlight_scopes_0">No</label>
				<small class="hint">When enabled, client-supplied scopes are highlighted.</small>
			</div>
			<div class="field">
				<label class="header" for="client_scopes">Client Scopes</label>
				<input class="edit" type="text" name="client_scopes" value="cgi,cookie,form,url"/>
				<small class="hint">If your framework puts form/url in other scopes, add it here.</small>
			</div>
		</fieldset>
		<fieldset class="controls">
			<a href="##advanced" onclick="$j('##advanced').toggle();return false;">toggle advanced settings</a>
			<button type="reset">Reset</button>
			<button type="submit">Scan</button>
		</fieldset>
	</form>

	<script type="text/javascript" src="as_setup.js"></script>
</cfoutput>