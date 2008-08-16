<cfimport prefix="form" taglib="../../tags/form"/>

<cfoutput>
	<form:main action="#link(xfa.Scan)#" class="std typeA">

		<h2>Quick Start</h2>

		<form:group>

			<form:select
				id      = "config"
				label   = "Select Config:"
				options = "default,paranoid"
				value   = "default"
			/>

			<form:edit
				id    = "StartingDir"
				label = "Starting Directory:"
				value = "#Settings.findHomeDirectory()#"
				hint  = "Absolute path or mapping. No ending slash required."
			/>

			<form:select
				id      = "recurse"
				label   = "Recurse sub-directories?"
				options = "true,false"
				value   = "false"
				hint    = "Set to true to scan inside sub-directories."
			/>

		</form:group>

		<form:controls>

			<form:submit value="Scan"/>

		</form:controls>

	</form:main>
</cfoutput>