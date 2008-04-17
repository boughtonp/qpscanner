<cfcomponent output="false" displayname="jre-utils v0.5">


	<cffunction name="init" output="false" access="public">
		<cfargument name="DefaultFlags"        type="String"  default="MULTILINE"/>
		<cfargument name="IgnoreInvalidFlags"  type="Boolean" default="false"/>
		<cfargument name="BackslashReferences" type="Boolean" default="false"/>

		<cfset var CurrentFlag = ""/>

		<cfset This.Flags = Struct
			( UNIX_LINES       : 1
			, CASE_INSENSITIVE : 2
			, COMMENTS         : 4
			, MULTILINE        : 8
			, DOTALL           : 32
			, UNICODE_CASE     : 64
			, CANON_EQ         : 128
			)/>

		<cfset This.DefaultFlags = This.parseFlags( Arguments.DefaultFlags , Arguments.IgnoreInvalidFlags )/>

		<cfset This.BackslashReferences = Arguments.BackslashReferences/>

		<!--- In CFMX we cannot define a "Replace" function directly. --->
		<cfset This.replace   = _replace/>
		<cfset StructDelete(This,'_replace')/>

		<cfreturn This/>
	</cffunction>



	<cffunction name="Struct" returntype="Struct" access="private"><cfreturn Arguments/></cffunction>




	<cffunction name="parseFlags" returntype="Numeric" output="false" access="public">
		<cfargument name="FlagList"           type="String"/>
		<cfargument name="IgnoreInvalidFlags" type="Boolean" default="false"/>
		<cfset var CurrentFlag = ""/>
		<cfset var ResultFlag = 0/>

		<cfloop index="CurrentFlag" list="#Arguments.FlagList#">

			<cfif IsNumeric(CurrentFlag)>
				<cfset ResultFlag = BitOr( ResultFlag , CurrentFlag )/>

			<cfelseif StructKeyExists( This.Flags , CurrentFlag )>
				<cfset ResultFlag = BitOr( ResultFlag , This.Flags[CurrentFlag] )/>

			<cfelseif NOT Arguments.IgnoreInvalidFlags>
				<cfthrow message="Invalid Flag!" detail="[#CurrentFlag#] is not supported."/>

			</cfif>

		</cfloop>

		<cfreturn ResultFlag/>
	</cffunction>




	<cffunction name="get" returntype="Array" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfset var Pattern = CreateObject("java","java.util.regex.Pattern")
			.Compile( Arguments.Regex , parseFlags(Arguments.Flags) )/>
		<cfset var Matcher = Pattern.Matcher(Arguments.Text)/>
		<cfset var Matches = ArrayNew(1)/>

		<cfloop condition="Matcher.Find()">
			<cfset ArrayAppend(Matches,Matcher.Group())/>
		</cfloop>

		<cfreturn Matches/>
	</cffunction>



	<cffunction name="getNoCase" returntype="Array" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfreturn This.get
			( Text    : Arguments.Text
			, Pattern : Arguments.Regex
			, Flags   : BitOr( Arguments.Flags , This.Flags.CASE_INSENSITIVE )
			)/>
	</cffunction>




	<cffunction name="_replace" returntype="String" output="false" access="public">
		<cfargument name="Text"        type="String"/>
		<cfargument name="Regex"       type="String"/>
		<cfargument name="Replacement" type="Any"    hint="String or UDF"/>
		<cfargument name="Scope"       type="String" default="ONE" hint="ONE,ALL"/>

		<cfset var String     = ""/>
		<cfset var Pattern    = ""/>
		<cfset var Matcher    = ""/>
		<cfset var Results    = ""/>
		<cfset var Groups     = ""/>
		<cfset var GroupIndex = ""/>

		<cfif IsSimpleValue(Arguments.Replacement)>

			<cfif This.BackslashReferences AND REFind('[\\$]',Arguments.Replacement)>
				<cfset Arguments.Replacement = Replace(Arguments.Replacement,'$',Chr(65536),'all')/>
				<cfset Arguments.Replacement = REReplace(Arguments.Replacement,'\\(?=[0-9])','$','all')/>
				<cfset Arguments.Replacement = Replace(Arguments.Replacement,Chr(65536),'\$','all')/>
			</cfif>

			<cfset String = CreateObject("java","java.lang.String").init(Arguments.Text)/>
			<cfif Arguments.Scope EQ "ALL">
				<cfreturn String.ReplaceAll(Arguments.Regex,Arguments.Replacement)/>
			<cfelse>
				<cfreturn String.ReplaceFirst(Arguments.Regex,Arguments.Replacement)/>
			</cfif>

		<cfelse>

			<cfset Pattern = CreateObject("java","java.util.regex.Pattern").Compile(Arguments.Regex)/>
			<cfset Matcher = Pattern.Matcher( Arguments.Text )/>
			<cfset Results = CreateObject("java","java.lang.StringBuffer").init()/>

			<cfloop condition="Matcher.Find()">

				<cfset Groups = ArrayNew(1)/>

				<cfloop index="GroupIndex" from="1" to="#Matcher.GroupCount()#">
					<cfset ArrayAppend( Groups , Matcher.Group( JavaCast("int",GroupIndex) ) )/>
				</cfloop>

				<cfset Matcher.AppendReplacement
					( Results , Arguments.Replacement( Matcher.Group() , Groups ) )/>

				<cfif Arguments.Scope NEQ "ALL">
					<cfbreak/>
				</cfif>

			</cfloop>

			<cfset Matcher.AppendTail(Results)/>

			<cfreturn Results.ToString()/>
		</cfif>
	</cffunction>



</cfcomponent>