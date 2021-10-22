component
{
	function init(fw){variables.fw=arguments.fw;}


	function go(rc)
	{
		if ( NOT StructKeyExists(rc,'Config') )
			rc.Config = "default";

		if ( NOT StructKeyExists(rc,'Instance') )
			rc.Instance = createUuid();

		if ( NOT StructKeyExists(rc,'OutputFormat') )
			rc.OutputFormat = 'html';

		rc.ScanData = Application.Cfcs.Settings.read
			( ConfigId  : rc.Config
			, Format    : 'Struct'
			, Overrides : rc
			);

		Request.Scanner = Application.Cfcs.Scanner.init( ArgumentCollection = rc.ScanData );

		rc.ScanResults = Request.Scanner.go();

		Session.Instance[rc.Instance] =
			{ Settings = rc.ScanData
			, Results  = rc.ScanResults
			, TimeRun  = Now()
			};

		fw.setView('results.#rc.OutputFormat#');

		request.layout = rc.OutputFormat EQ 'html';

		rc.Title = 'Scan Results';
	}


}