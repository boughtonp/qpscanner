<cfoutput>
	<form method="get" action="?" class="std typeA">

		<input type="hidden" name="action" value="scan.go" />

		<h2>Quick Start</h2>

		<fieldset class="main">

			<div class="field">
				<label for="config" class="indiv header">Select Config:</label>
				<ul class="input">
					<li>
						<input id="config_default" checked="checked" value="default" name="config" type="radio" class="box" />
						<label for="config_default" class="indiv">default</label>
					</li>
					<li>
						<input id="config_paranoid"  value="paranoid" name="config" type="radio" class="box" />
						<label for="config_paranoid" class="indiv">paranoid</label>
					</li>
				</ul>
			</div>

			<div class="field">
				<label for="StartingDir" class="indiv header">Starting Directory:</label>
				<input id="StartingDir" type="text" name="StartingDir" value="#rc.StartingDir#" class="edit" />

				<small class="hint" id="StartingDir_hint">Absolute path or mapping.</small>
			</div>

			<div class="field">
				<label for="recurse" class="indiv header">Recurse sub-directories?</label>

				<ul class="input">
					<li>
						<input id="recurse_true"  value="true" name="recurse" type="radio" class="box" />
						<label for="recurse_true" class="indiv">true</label>
					</li>
					<li>
						<input id="recurse_false" checked="checked" value="false" name="recurse" type="radio" class="box" />
						<label for="recurse_false" class="indiv">false</label>
					</li>
				</ul>

				<small class="hint" id="hint_recurse">Set to true to scan inside sub-directories.</small>
			</div>

		</fieldset>

		<fieldset class="controls">
			<button type="submit">Scan</button>
		</fieldset>

	</form>
</cfoutput>