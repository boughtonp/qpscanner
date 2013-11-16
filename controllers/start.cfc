component
{


	function intro(rc)
	{
		rc.Title = 'Start';

		if ( NOT StructKeyExists(rc,'StartingDir') )
			rc.StartingDir = Application.Cfcs.Settings.findHomeDirectory();
	}


	function config(rc)
	{
		rc.Title = 'Configuration';

		if ( NOT StructKeyExists(rc,'Config') )
			rc.Config = "default";

		rc.Setting = Application.Cfcs.Settings.read( ConfigId:rc.Config , Format:'query' );
	}


	function error(rc)
	{
		request.layout = rc.OutputFormat EQ 'html';
	}


}