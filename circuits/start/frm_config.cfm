<cfimport prefix="form" taglib="../../tags/form"/>

<cfoutput>

	<form:main action="#link(xfa.Scan)#" class="std typeA">

		<form:hidden id="config" value="#Attributes.Config#"/>

		<form:group>

			<div class="col2 left">

				<cfloop query="Setting">

					<cfif CurrentRow-1 EQ RecordCount\2></div><div class="col2 right"></cfif>

					<cfif (type NEQ 'text') >
						<cfswitch expression="#ListFirst(type)#">
							<cfcase value="boolean">
								<form:select
									id="#id#"
									label="#label#"
									options="true,false"
									value="#value#"
									hint="#hint#"
								/>
							</cfcase>
							<cfcase value="select">
								<form:select
									id="#id#"
									label="#label#:"
									options="#options#"
									value="#value#"
									hint="#hint#"
								/>
							</cfcase>
						</cfswitch>
					<cfelse>
						<form:edit
							id="#id#"
							label="#label#:"
							value="#value#"
							hint="#hint#"
						/>
					</cfif>

				</cfloop>

			</div>

		</form:group>

		<form:controls>

			<form:reset/>
			<!---
			<form:submit name="action" value="Save"/>
			<form:submit name="action" value="Save & Scan"/>
			--->
			<form:submit name="action" value="Scan"/>

		</form:controls>

	</form:main>

</cfoutput>