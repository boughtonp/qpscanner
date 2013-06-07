<cfif StructKeyExists(Request,'Exception')>
	<cfdump var=#Request.Exception# />
<cfelse>
	No Exception?
</cfif>