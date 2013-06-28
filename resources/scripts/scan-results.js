$j().ready( init );


function init()
{
	// INFO: Setup interface events
	$j('dt.file').click( toggleFileInfo );
	$j('dt.query').click( toggleQueryCode );

	$j('dt.file .id,dt.query .id').click( function(){return false;} );

	highlightClientScopeFiles();

	renderDisplayOptions();
}



function toggleFileInfo()
{
	$j(this).find('+dd.file_info').toggle();
}


function toggleAllFileInfo()
{
	// Ideally, we should fire each toggleFileInfo call:
	// $j('dt.file').click();
	// But it's simpler just to toggle all queries...

	$j('dd.file_info').toggle();
}


function toggleQueryCode()
{
	$j(this).find('+dd.query_code').toggle();
}

function toggleAllQueryCode()
{
	$j('dd.query_code').toggle();
}



function highlightClientScopeFiles()
{
	$j('dt.file:has(+dd * .ContainsClientScope)').addClass('ContainsClientScope');
}



function renderDisplayOptions()
{
	$j('#DisplayOptions')
		.html('')
		.append('<input type="checkbox" checked id="toggle_files" /><label class="indiv" for="toggle_files">toggle file contents</label>')
		.append('<input type="checkbox" checked id="toggle_queries" /><label class="indiv" for="toggle_queries">toggle query contents</label>')
		;

	$j('#DisplayOptions #toggle_files').click( toggleAllFileInfo );
	$j('#DisplayOptions #toggle_queries').click( toggleAllQueryCode );
}