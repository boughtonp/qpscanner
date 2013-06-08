<cftry><cfcontent reset="yes"/><cfcatch></cfcatch></cftry><cfoutput><!doctype html>
<html>
<head>
	<title>QueryParam Scanner<cfif StructKeyExists(rc,'Title')> :: #HtmlEditFormat(rc.Title)#</cfif></title>

	<link rel="stylesheet" type="text/css" href="./resources/styles/core.css"/>
	<link rel="stylesheet" type="text/css" href="./resources/styles/form.css"/>
	<link rel="stylesheet" type="text/css" href="./resources/styles/default.css"/>

	<script type="text/javascript" src="./resources/scripts/jquery-1.2.6.min.js"></script>
	<script type="text/javascript">
		var $j = jQuery.noConflict();
	</script>

</head>
<body id="#ListLast(rc.action,'.')#">
<cfif rc.action NEQ 'start.intro'>
	<h1><a href="?action=start.intro"><img src="./resources/images/long_logo.png" alt="QueryParam Scanner" style="width: 448px; height: 40px;"/></a></h1>
</cfif>

#Body#

</body></html></cfoutput>