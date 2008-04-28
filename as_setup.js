$j(document).ready(function()
{
	$j('#advanced').hide();

	if ($j.browser.mozilla)
	{
		// Mozilla can't handle LEGEND, so we give it a DIV instead.
		// All legend declarations in the stylesheets must also have an accompying .legend declaration

		$j('#advanced>legend').replaceWith('<div class="legend">'+$j('#advanced>legend').html()+'</div>');
	}


});