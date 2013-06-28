<cfoutput>

	<div class="about">
		<img src="./resources/images/logo.jpg" alt="QueryParam Scanner" />
		#view('start/_about')#
	</div>

	<div class="start">
		<p>To use default options, simply enter the directory below and hit scan.</p>

		<p>Alternatively, visit the <a href="?action=start.config">Configuration</a>
		page for more options.</p>

		#view('start/_quickstart')#
	</div>

	<br class="break" />

</cfoutput>