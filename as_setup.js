$j(document).ready(function()
{
	$j('#advanced').hide();

	if ($j.browser.mozilla)
	{
		// Mozilla can't handle LEGEND, so we give it a DIV instead.
		// All legend declarations in the stylesheets must also have an accompying .legend declaration

		$j('#advanced>legend').replaceWith('<div class="legend">'+$j('#advanced>legend').html()+'</div>');
	}

	if ($j.browser.msie)
	{
		// IE ignores float:left on an element if you absolute position it, so lets just hack it...

		$j(window).resize(function()
		{
			$j('form>.controls>a').css
				({ position : 'absolute'
				 , display  : 'block'
				 , float    : 'left'
				 , clear    : 'none'
				 , left     : ($j(document).width()/2) - 310  +'px'
				 });
		});
	}
});