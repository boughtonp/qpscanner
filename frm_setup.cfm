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
		<fieldset class="controls">
			<button type="reset">Reset</button>
			<button type="submit">Scan</button>
		</fieldset>
	</form>
</cfoutput>