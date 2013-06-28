<cfoutput>

	<form method="get" action="?" >

		<input type="hidden" name="action" value="scan.go" />
		<input type="hidden" name="config" value="default" />

		<fieldset class="main">

			<div class="field">
				<label for="StartingDir" class="indiv header">Directory:</label>
				<input id="StartingDir" type="text" name="StartingDir" value="#rc.StartingDir#" class="edit" />

				<small class="hint" id="StartingDir_hint">Absolute path or mapping.</small>
			</div>

			<div class="field">
				<label for="recurse" class="indiv header">Recurse?</label>

				<ul class="input">
					<li>
						<input id="recurse_true"  value="true" name="recurse" type="radio" class="box" />
						<label for="recurse_true" class="indiv">yes</label>
					</li>
					<li>
						<input id="recurse_false" checked="checked" value="false" name="recurse" type="radio" class="box" />
						<label for="recurse_false" class="indiv">no</label>
					</li>
				</ul>

				<small class="hint" id="hint_recurse">Enable recursion to also scan sub-directories.</small>
			</div>

		</fieldset>

		<fieldset class="controls">
			<button type="submit">Scan</button>
		</fieldset>

	</form>

</cfoutput>