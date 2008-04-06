<cfapplication name="qpScanner"/>
<cfsetting requesttimeout="300" enablecfoutputonly="true" showdebugoutput="false"/>

<cfinclude template="lay_header.cfm"/>

<cfif StructKeyExists(Url,'StartDir')>
	<cfinclude template="act_scan.cfm"/>
<cfelse>
	<cfinclude template="frm_setup.cfm"/>
</cfif>

<cfinclude template="lay_footer.cfm"/>