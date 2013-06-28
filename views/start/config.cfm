<cfoutput>

	<form method="get" action="?" >

		<input type="hidden" name="action" value="scan.go" />

		<input type="hidden" name="config" value="#rc.Config#" />

		<fieldset class="main">

			<cfloop query="rc.Setting">

				<div class="field #id#">
					<label class="indiv header" for="#id#">#HtmlEditFormat(label)#:</label>

					<cfif type EQ 'text'>
						<input
							class="edit" type="text"
							id="#id#" name="#id#"
							value="#HtmlEditFormat(Value)#"
						/>
					<cfelse>
						<cfif ListFirst(type) EQ 'boolean' >
							<cfset rc.Setting.options[CurrentRow] = "yes,no" />
						</cfif>
						<ul class="input">
							<cfloop index="CurOpt" list=#options# >
								<li>
									<input id="#id#_#CurOpt#"  <cfif value EQ CurOpt>checked="checked"</cfif> value="#CurOpt#" name="#id#" type="radio" class="box" />
									<label for="#id#_#CurOpt#" class="indiv">#CurOpt#</label>
								</li>
							</cfloop>
						</ul>
					</cfif>

					<cfif len(trim(status))>
						<em class="experimental"
							title="This functionality is provided for convenience but contains known bugs or limitations."
							>EXPERIMENTAL
						</em>
					</cfif>
					<cfif len(trim(hint))>
						<small class="hint">#hint#</small>
					</cfif>
				</div>

			</cfloop>

		</fieldset>

		<fieldset class="controls">
			<button type="reset">Reset</button>
			<button type="submit">Scan</button>
		</fieldset>

	</form>

</cfoutput>