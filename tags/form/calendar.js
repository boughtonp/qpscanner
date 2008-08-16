function showCalendar(id, start, limit)
{
	if (start == '')
	{
		start = -1;
		var mon = ('Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec').split(',');
		var m = mon[(new Date()).getMonth()];
	}
	else
	{
		var m = start.split(/[^0-9a-zA-Z]/,'')[1];
	}
	var cal = window.open('../form/calendar.html?'+start+'&'+id+'#'+m,'cal','width=320,height=220,status=yes,resizable=yes,scrollbars=yes');
}