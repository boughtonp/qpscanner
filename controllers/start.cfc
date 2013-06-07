component
{

	function intro(rc)
	{
		if ( NOT StructKeyExists(rc,'StartingDir') )
			rc.StartingDir = Application.Cfcs.Settings.findHomeDirectory();

	}

	function config(rc)
	{
		if ( NOT StructKeyExists(rc,'Config') )
			rc.Config = "default";

		rc.Setting = Application.Cfcs.Settings.read( ConfigId:rc.Config , Format:'query' );
	}

}