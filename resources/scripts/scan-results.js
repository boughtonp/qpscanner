$j().ready( init );


function init()
{
	// INFO: Setup interface events
	$j('dt.file').click( toggleFileInfo );
	$j('dt.query').click( toggleQueryCode );

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
		.append('<button type="button">toggle all files</button>')
		.append('<button type="button">toggle all queries</button>')
		;

	$j('#DisplayOptions button:contains(toggle all files)').click( toggleAllFileInfo );
	$j('#DisplayOptions button:contains(toggle all queries)').click( toggleAllQueryCode );
}