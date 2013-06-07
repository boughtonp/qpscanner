<cfoutput>

	<form method="post" action="?action=scan.go" class="std typeA">

		<input type="hidden" name="config" value="#rc.Config#" />

		<fieldset class="main">

			<div class="col2 left">

				<cfloop query="rc.Setting">

					<cfif CurrentRow-1 EQ RecordCount\2></div><div class="col2 right"></cfif>

					<div class="field">
						<label class="indiv header" for="#id#">#HtmlEditFormat(label)#:</label>

						<cfif type EQ 'text'>
							<input
								class="edit" type="text"
								id="#id#" name="#id#"
								value="#HtmlEditFormat(Value)#"
							/>
						<cfelse>
							<cfif ListFirst(type) EQ 'boolean' >
								<cfset rc.Setting.options[CurrentRow] = "true,false" />
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

						<cfif len(trim(hint))>
							<small class="hint">#hint#</small>
						</cfif>
					</div>

				</cfloop>

			</div>

		</fieldset>

		<fieldset class="controls">
			<button type="reset">Reset</button>
			<button type="submit">Scan</button>
		</fieldset>

	</form>

</cfoutput>