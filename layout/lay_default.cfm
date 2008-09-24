<cfparam name="Title" default=""/>
<cfparam name="Content" default=""/>
<cftry><cfcontent reset="yes"/><cfcatch></cfcatch></cftry><cfoutput><!DOCTYPE html>
<html>
<head>
	<title>QueryParam Scanner<cfif Len(Title)> :: #Title#</cfif></title>


	<link rel="stylesheet" type="text/css" href="./resources/styles/core.css"/>
	<link rel="stylesheet" type="text/css" href="./resources/styles/form.css"/>
	<link rel="stylesheet" type="text/css" href="./resources/styles/default.css"/>


	<script type="text/javascript" src="./resources/scripts/jquery-1.2.6.min.js"></script>
	<script type="text/javascript">
		var $j = jQuery.noConflict();
	</script>

	<cfif find('MSIE',CGI.HTTP_USER_AGENT)
		AND ListFirst(ArrayToList( jre.get(CGI.HTTP_USER_AGENT,'(?<=MSIE )\d+') )) LTE 6
		>
		<!--[if lt IE 7]>
			<style type="text/css">*{behavior:url(./resources/scripts/iepngfix.htc);}</style>
		<![endif]-->
	</cfif>

</head>
<body id="#myFusebox.OriginalFuseaction#">
<cfif myFusebox.OriginalFuseaction NEQ 'intro'>
	<h1><a href="#link('start.intro')#"><img src="./resources/images/long_logo.png" alt="QueryParam Scanner" style="width: 448px; height: 40px;"/></a></h1>
</cfif>

#Content#

</body></html></cfoutput>