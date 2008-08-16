<cfsetting showdebugoutput="no" enablecfoutputonly="false"/>
function elem(ent){return document.getElementById(ent);}

<!--- TODO: Remote validation script. --->
var remote_validation = false;
var validation_script = '/validate.cfc?method=validate';
var last_call = new Date();

var pfct =
{ version : function(){return {version:'0.4-dev',major:0,minor:4,dev:true}}



/*
  vvv Validation and Error Handling vvv
*/

, validate : function(id, label, required)
	{
		var tag = elem(id);

		if (required && tag.value == '')
		{
			pfct.show_error(label+' is required', id);
			return false;
		}

		if (remote_validation == true)
		{
			var now = new Date();
		<!--- TODO: Remote validation script. --->
	//		http('GET' , validation_script+'&id='+id+'&label='+label+'&value='+tag.value+'&call='+now , handle_result);
		}

		// If we reach here, validation was passed.
		pfct.hide_error(id);
		return true;
	}


, handle_result : function(result)
	{
		if (result.success == true)
		{
			pfct.hide_error(result.id);
		}
		else
		{
			pfct.show_error(result.message, result.id);
		}

		return true;
	}


, show_error : function(msg, id)
	{

		if (!elem('pfct_error_box'))
		{
			var code = '<style type="text/css">';
			code += '#pfct_error_box {position: absolute; display: none; border: dashed 1px red; background-color: pink;}';
			code += '</style>';
			code += '<div id="pfct_error_box" class="error"></div>';
			document.body.innerHTML += code;
		}

		var tag = elem(id);

		tag.className += ' error';
		
		if (msg != '')
		{
			elem('pfct_error_box').innerHTML = msg;
			elem('pfct_error_box').style.top = pos.readTop(tag,0)+'px';
			elem('pfct_error_box').style.left = (pos.readLeft(tag,0) + pos.readWidth(tag))+'px';
			elem('pfct_error_box').style.display = 'block';
			elem('pfct_error_box').errorFor = id;
		}
	}

, hide_error : function(id)
	{

		elem(id).className = elem(id).className.replace('error','');

		if (elem('pfct_error_box') && elem('pfct_error_box').errorFor == id)
		if (true)
		{
			elem('pfct_error_box').innerHTML = '';
			elem('pfct_error_box').style.top = 0;
			elem('pfct_error_box').style.left = 0;
			elem('pfct_error_box').style.display = 'none';

		}
	}
/*
  ^^^ Validation and Error Handling ^^^
*/


/*
  vvv Date Parsing and Formatting vvv
*/
, months : 'January,February,March,April,May,June,July,August,September,October,November,December'.split(',')
, mlist : 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec'
, mon31 : 'Jan,Mar,May,Jul,Aug,Oct,Dec'

, readMonthFromNum : function(num, long)
	{
		if (long == undefined || long == false)
		{
			return pfct.months[num].substr(0,3);
		}
		else
		{
			return pfct.months[num];
		}
	}

, convertMonthToNum : function (month)
	{
		/*
			This function will handle months from a number of different languages.
			It works based on the first three letters, which are relatively similar
			between languages and different between the various month words.
		*/
	
		var l1 = month.substr(0,1).toUpperCase();
		var l2 = month.substr(1,1).toLowerCase();
		var l3 = month.substr(2,1).toLowerCase();
		var l4 = month.substr(3,1).toLowerCase();
		
		switch(l1)
		{
			case 'J':
			case 'I':
				if (l2 == 'a' || l2 == 'c') {return 1;} // January,Ianuarie,Ichigatsu
				else if (l3 == 'l' || l3 == 'y' || (l3 == 'i' && l4 != 'n') || l4 == 'l') {return 7;}  // July,Iulie,
				else {return 6;} // June
			break;
			case 'F': return 2; break; // February
			break;
			case 'M':
				if (l3 == 'y' || l3 == 'i' || l3 == 'j' || l2 == 'e' || l3 == 'e') {return 5;} // May,Mei,Maj,
				else {return 3;} // March
			break;
			case 'A':
				if (l2 == 'p' || l2 == 'v' || l2 == 'b' || l3 == 'p') {return 4;} // April,Avril,Abril,Aepril
				else {return 8;} // August
			break;
			case 'S': return  9; break; // September,S*
			case 'O':
				if (l2 == 'g'){return 8;} // Ogostus,Ogos
				else {return 10;}  // October,O*
			break;
			case 'N': return 11; break; // November,N*
			case 'D': return 12; break; // December,D*
			case 'E':
				if (l2 == 'p' || l2 == 'b') {return 4;} // Ebrel,Epril,Ebrill
				else if (l2 == 'n' || l3 == 'n') {return 1} // Enero,Eanáir 
				else if (l2 == 'l') {return 8;} // Elokuu
			break;
			case 'H':
				if (l3 == 'i' || l4 == 'i' || l4 == 'y') {return 7;} // Huls,Heinäkuu,Hulyo,Hainakuu 
				if (l3 == 'h') {return 4;} // Huhtikuu
				if (l3 == 'l') {return 2;} // Helmikuu
				if (l3 == 'k') {return 10;} // Hoktember
			break;
			case 'L':
				if (l3 == 'k') {return 10;} // Lokakuu
				if (l2 == 'e') {return 5;} // Lehekuu
			break;
			case 'P':
				if (l2 == 'i') { return 6;} // Piimäkuu
				else if (l2 == 'e') {return 2;} // Petrvar,Pebrero
			break;
			case 'V': return 2; break; // Veebruar
				
		}
		return -1;
	}

, formatDate : function(item, inputpriority, outputformat, mindate, maxdate)
	{
		var d = elem(item).value;
		var yearlimit = 1970;
		var day = -1;
		var month = -1;
		var year = -1;
		var format=0;

		if (inputpriority == 'DMY')
		{
		    format=0;
			var MsgFormat = 'Please use day-month-year format.';
		}
		else if (inputpriority == 'YMD')
		{
		    format=1;
			var MsgFormat = 'Please use year-month-day format.';
		}
		else if (inputpriority == 'MDY')
		{
		    format=2;
			var MsgFormat = 'Please use month-day-year format.';
		}
	
		if (d != '')
		{

		// --------------------
		// Stage1: Get Day, Month & Year.
	
			if (d.substr(0,4) == 'date')
			{
	
				DateNow = new Date();
	
				switch(d.substr(5,99))
				{
					case('now'):
					case('today'):
						// No changed needed.
					break;
	
					case('tomorrow'):
					case('tomorow'):
					case('tommorow'):
					case('tommorrow'):
						with (DateNow) setDate(getDate()+1);
					break;
	
					default:
						if (d.substr(4,1) == '+' || d.substr(4,1) == '-')
						{
							eval('with (DateNow) setDate(getDate()'+d.substr(4,99)+')');
						}
					break;
				}
				day = DateNow.getDate();
				month = DateNow.getMonth()+1;
				year = DateNow.getFullYear();
			}
			else
			if (d.split(/[^0-9A-Z]/i).length > 1)
			{
				d = d.split(/[^0-9A-Z]/i);
				if (format == 0)
				{
					day = d[0];
					month = d[1];
					year = d[2];
				}
				else if (format == 1)
				{
					year = d[0];
					month = d[1];
					day = d[2];
				}
				else if (format == 2)
				{
					month = d[0];
					day = d[1];
					year = d[2];
				}
	
			}
			else
			if (d.length == 6 || d.length == 5)
			{
				if (d.length == 5)
				{
					d = '0'+d;
				}
				if (format == 0)
				{
					day = d.substr(0,2);
					month = d.substr(2,2);
					year = d.substr(4,2);
				}
				else if (format == 1)
				{
					year = d.substr(0,2);
					month = d.substr(2,2);
					day = d.substr(4,2);
				}
				else if (format == 2)
				{
					month = d.substr(0,2);
					day = d.substr(2,2);
					year = d.substr(4,2);
				}
			}
			else
			{
				pfct.show_error('Unknown date format. '+MsgFormat,item);
				return false;
			}
	
		// -----------------------
		// Stage2: Put elements in correct format.
	
			if ((day <= 12 && month > 12 && month < 32) || (pfct.mlist.indexOf(day) != -1))
			{
				t=day;
				day=month;
				month=t;
			}
	
			if (1 <= month && month <= 12)
			{
	//			month = pfct.mlist.split(/,/)[month-1];
				month = pfct.readMonthFromNum(month-1);
			}
			else
			{
				month = month.substr(0,1).toUpperCase() + month.substr(1,15).toLowerCase();
			}
	
			if (year.length == 2)
			{
				if (year < yearlimit)
				{
					year = '20'+year;
				}
				else
				{
					year = '19'+year;
				}
			}
			else if (year.length == 1)
			{
				year = '200' + year;
			}
	
	
			if (pfct.convertMonthToNum(month) == -1)
			{
				pfct.show_error('Unknown date format, or invalid month. '+MsgFormat, item);
				return false;
			}
			else
			if ((day > 31 || day < 1)
			    ||(pfct.mon31.indexOf(month) == -1 && day > 30))
			{
				pfct.show_error('Unknown date format, or invalid number of days in month. '+MsgFormat, item);
				return false;
			}
			else
			if (month == 'Feb' && day > 28)
			{
				IsLeapYear = (year%4==0&&(year%100!=0||year%400==0))
				if (!(day == 29 && IsLeapYear))
				{
					pfct.show_error('Unknown date format, or invalid days in february. '+MsgFormat, item);
					return false;
				}
			}
	
		// -----------------------
		// Stage3: Return appropriate elements.
	
			d = new String(outputformat);
			d = d.replace(/(dd+|day)/,day);
			d = d.replace(/(mmm+|month)/,month);
			d = d.replace(/(yyy+|year)/,year);

			// TODO: Following lines don't work on IE.
			d = d.replace(/m+/,('0'+pfct.convertMonthToNum(month)).substr(-2,2));
			d = d.replace(/y+/,year.substr(-2,2));
	
			elem(item).value = d;
			pfct.hide_error(item);
			return true;
		}
		return false;

	}


/*
  ^^^ Date Parsing and Formatting ^^^
*/

};


<!--- TODO: Check these on IE - error box should be across and down one line, and is causing scrollbars to appear. --->
var pos =
{ readTop : function(tag, top_amount)
	{
		if (tag.offsetTop)  {top_amount = tag.offsetTop;}
		else if (tag.parentNode) {top_amount = top_amount + pos.readTop(tag.parentNode, top_amount);}
		return top_amount;
	}

, readLeft : function(tag, left_amount)
	{
		if (tag.offsetLeft)  {left_amount = tag.offsetLeft;}
		else if (tag.parentNode) {left_amount = left_amount + pos.readLeft(tag.parentNode, left_amount);}
		return left_amount;
	}

, readWidth : function(tag)
	{
		return tag.offsetWidth;
	}

, readHeight : function(tag)
	{
		return tag.offsetHeight;
	}

, num : function(val)
	{
		return (val.toString().replace(/[^0-9.]/mig,'')/1);
	}


};
<cfsetting enablecfoutputonly="true"/>