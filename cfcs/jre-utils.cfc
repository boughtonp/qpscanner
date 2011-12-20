<cfcomponent output="false" displayname="jrex v0.8ish">


	<cffunction name="init" output="false" access="public">
		<cfargument name="DefaultFlags"        type="String"  default="MULTILINE"/>
		<cfargument name="IgnoreInvalidFlags"  type="Boolean" default="false" />
		<cfargument name="BackslashReferences" type="Boolean" default="false" />
		<cfargument name="SetNullGroupsBlank"  type="Boolean" default="true"  />

		<cfset var CurProp = 0 />

		<cfset This.Flags = 
			{ UNIX_LINES       = 1
			, CASE_INSENSITIVE = 2
			, COMMENTS         = 4
			, MULTILINE        = 8
			, DOTALL           = 32
			, UNICODE_CASE     = 64
			, CANON_EQ         = 128
			}/>


		<cfset This.DefaultFlags = This.parseFlags( Arguments.DefaultFlags , Arguments.IgnoreInvalidFlags )/>

		<cfloop index="CurProp" list="BackslashReferences,SetNullGroupsBlank">
			<cfset This[CurProp] = Arguments[CurProp] />
		</cfloop>


		<cfset Variables.PatternCache = {} />


		<!--- In CFMX we cannot define a "Replace" function directly. --->
		<cfset This.replace   = _replace/>
		<cfset StructDelete(This,'_replace')/>

		<cfreturn This/>
	</cffunction>



	<cffunction name="onMissingMethod" returntype="any" output="false" access="public">
		<cfargument name="MissingMethodName"      type="String" />
		<cfargument name="MissingMethodArguments" type="Struct" />
		
		<cfset var local = StructNew()>

		<cfif right(Arguments.MissingMethodName,6) EQ 'NOCASE'>
			<cfset local.TargetFunction = left(Arguments.MissingMethodName,len(Arguments.MissingMethodName)-6) />
			<cfset local.Args = Arguments.MissingMethodArguments />

			<cfif StructKeyExists(local.Args,'Flags')>
				<cfset local.Args.Flags = BitOr( local.Args.Flags , This.Flags.CASE_INSENSITIVE ) />
			<cfelse>
				<cfset local.Args.Flags = BitOr( This.DefaultFlags , This.Flags.CASE_INSENSITIVE ) />
			</cfif>

			<cfset local.Function = This[local.TargetFunction] />
			<cfreturn Function(ArgumentCollection=local.Args) />
		</cfif>

	</cffunction>



	<cffunction name="parseFlags" returntype="Numeric" output="false" access="public">
		<cfargument name="FlagList"           type="String"/>
		<cfargument name="IgnoreInvalidFlags" type="Boolean" default="false"/>
		<cfset var CurrentFlag = ""/>
		<cfset var ResultFlag = 0/>

		<cfloop index="CurrentFlag" list="#Arguments.FlagList#">

			<cfif isNumeric(CurrentFlag)>
				<cfset ResultFlag = BitOr( ResultFlag , CurrentFlag )/>

			<cfelseif StructKeyExists( This.Flags , CurrentFlag )>
				<cfset ResultFlag = BitOr( ResultFlag , This.Flags[CurrentFlag] )/>

			<cfelseif NOT Arguments.IgnoreInvalidFlags>
				<cfthrow message="Invalid Flag!" detail="[#CurrentFlag#] is not supported."/>

			</cfif>

		</cfloop>

		<cfreturn ResultFlag/>
	</cffunction>


	<cffunction name="compilePattern" output="false" access="public">
		<cfargument name="Regex" type="String" />
		<cfargument name="Flags" type="String" />

		<cfset var Key = Hash(Arguments.Regex&Arguments.Flags) />

		<cfif NOT StructKeyExists(Variables.PatternCache,Key)>
			<cfset Variables.PatternCache[Key] = createObject("java","java.util.regex.Pattern")
				.compile( Arguments.Regex , parseFlags(Arguments.Flags) ) />
		</cfif>

		<cfreturn Variables.PatternCache[Key]/>
	</cffunction>



	<cffunction name="flushPatternCache" returntype="void" outout="false" access="public"
		hint="Clears cache for specified pattern, or all patterns if none specified.">
		<cfargument name="Regex" type="String" required="false" />
		<cfargument name="Flags" type="String" required="false" />

		<cfif StructKeyExists(Arguments,'Regex')>
			<cfparam name="Arguments.Flags" default="#This.DefaultFlags#"/>

			<cfset StructDelete( Variables.PatternCache , Hash(serialize(Arguments)) ) />

		<cfelseif StructKeyExists(Arguments,'Flags')>
			<cfthrow
				message = "Argument 'flags' can only be used in conjunction with argument 'regex'."
				type    = "JreUtils.FlushPatternCache.InvalidArgument.Flags"
			/>

		<cfelse>
			<cfset Variables.PatternCache = {} />

		</cfif>

	</cffunction>




	<cffunction name="get" returntype="Array" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfset var Pattern = compilePattern( Arguments.Regex , Arguments.Flags )/>
		<cfset var Matcher = Pattern.Matcher(Arguments.Text)/>
		<cfset var Matches = ArrayNew(1)/>

		<cfloop condition="Matcher.find()">
			<cfset ArrayAppend(Matches,Matcher.Group())/>
		</cfloop>

		<cfreturn Matches/>
	</cffunction>



	<cffunction name="getFirst" returntype="String" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfset var Pattern = compilePattern( Arguments.Regex , Arguments.Flags )/>
		<cfset var Matcher = Pattern.Matcher(Arguments.Text)/>

		<cfif Matcher.find()>
			<cfreturn Matcher.Group() />
		<cfelse>
			<cfreturn '' />
		</cfif>
	</cffunction>



	<cffunction name="getCount" returntype="Numeric" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfset var Pattern = compilePattern( Arguments.Regex , Arguments.Flags )/>
		<cfset var Matcher = Pattern.Matcher(Arguments.Text)/>
		<cfset var Count = 0 />

		<cfloop condition="Matcher.find()">
			<cfset Count++ />
		</cfloop>

		<cfreturn Count />
	</cffunction>



	<cffunction name="getGroups" returntype="Array" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="SetNullGroupsBlank" type="Boolean" default="#This.SetNullGroupsBlank#"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfset var Pattern = compilePattern( Arguments.Regex , Arguments.Flags )/>
		<cfset var Matcher = Pattern.Matcher(Arguments.Text)/>
		<cfset var Matches = ArrayNew(1)/>


		<cfloop condition="Matcher.find()">
			<cfset CurMatch = 
				{ match = Matcher.Group()
				, groups = ArrayNew(1)
				}/>
			<cfloop index="i" from="1" to="#Matcher.groupCount()#">
				<cfif (Matcher.start(i) EQ -1) AND Arguments.SetNullGroupsBlank >
					<cfset ArrayAppend(CurMatch.Groups,'')/>
				<cfelse>
					<cfset ArrayAppend(CurMatch.Groups,Matcher.group(i))/>
				</cfif>
			</cfloop>

			<cfset ArrayAppend(Matches,CurMatch)/>
		</cfloop>

		<cfreturn Matches/>
	</cffunction>




	<!--- \ match* - clones of get* with first two arguments swapped. --->

	<cffunction name="match" returntype="Array" output="false" access="public"
		hint="This function swaps argument order for consistency with rematch">
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Text"    type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfreturn This.get( ArgumentCollection = Arguments )/>
	</cffunction>



	<cffunction name="matchFirst" returntype="String" output="false" access="public">
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Text"    type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfreturn This.getFirst( ArgumentCollection = Arguments )/>
	</cffunction>



	<cffunction name="matchCount" returntype="String" output="false" access="public">
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Text"    type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfreturn This.getCount( ArgumentCollection = Arguments )/>
	</cffunction>



	<cffunction name="matchGroups" returntype="Array" output="false" access="public">
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Text"    type="String"/>
		<cfargument name="SetNullGroupsBlank" type="Boolean" default="#This.SetNullGroupsBlank#"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfreturn This.getGroups( ArgumentCollection = Arguments ) />
	</cffunction>


	<!--- / match* --->



	<cffunction name="matches" returntype="Boolean" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfset var Pattern = compilePattern( Arguments.Regex , Arguments.Flags )/>
		<cfset var Matcher = Pattern.Matcher(Arguments.Text)/>

		<cfloop condition="Matcher.find()">
			<cfreturn true/>
		</cfloop>

		<cfreturn false/>
	</cffunction>



	<cffunction name="_replace" returntype="String" output="false" access="public">
		<cfargument name="Text"        type="String"/>
		<cfargument name="Regex"       type="String"/>
		<cfargument name="Replacement" type="Any"    hint="String or UDF"/>
		<cfargument name="Scope"       type="String" default="ONE" hint="ONE,ALL"/>
		<cfargument name="Flags"       type="String" default="#This.DefaultFlags#"/>

		<cfset var String     = ""/>
		<cfset var Pattern    = ""/>
		<cfset var Matcher    = ""/>
		<cfset var Results    = ""/>
		<cfset var Groups     = ""/>
		<cfset var GroupIndex = ""/>

		<cfif isSimpleValue(Arguments.Replacement)>

			<cfif This.BackslashReferences AND REfind('[\\$]',Arguments.Replacement)>
				<cfset Arguments.Replacement = replace(Arguments.Replacement,'$',Chr(65536),'all')/>
				<cfset Arguments.Replacement = REreplace(Arguments.Replacement,'\\(?=[0-9])','$','all')/>
				<cfset Arguments.Replacement = replace(Arguments.Replacement,Chr(65536),'\$','all')/>
			</cfif>

			<cfset String = createObject("java","java.lang.String").init(Arguments.Text)/>
			<cfif Arguments.Scope EQ "ALL">
				<cfreturn String.replaceAll(Arguments.Regex,Arguments.Replacement)/>
			<cfelse>
				<cfreturn String.replaceFirst(Arguments.Regex,Arguments.Replacement)/>
			</cfif>

		<cfelse>

			<cfset Pattern = compilePattern( Arguments.Regex , Arguments.Flags )/>
			<cfset Matcher = Pattern.Matcher( Arguments.Text )/>
			<cfset Results = createObject("java","java.lang.StringBuffer").init()/>

			<cfloop condition="Matcher.find()">

				<cfset Groups = ArrayNew(1)/>

				<cfloop index="GroupIndex" from="1" to="#Matcher.GroupCount()#">
					<cfset ArrayAppend( Groups , Matcher.Group( JavaCast("int",GroupIndex) ) )/>
				</cfloop>

				<cfset Matcher.appendReplacement
					( Results , Arguments.Replacement( Matcher.Group() , Groups ) )/>

				<cfif Arguments.Scope NEQ "ALL">
					<cfbreak/>
				</cfif>

			</cfloop>

			<cfset Matcher.appendTail(Results)/>

			<cfreturn Results.toString()/>
		</cfif>
	</cffunction>



	<cffunction name="split" returntype="Array" output="false" access="public">
		<cfargument name="Text"    type="String"/>
		<cfargument name="Regex"   type="String"/>
		<cfargument name="Flags"   default="#This.DefaultFlags#"/>

		<cfreturn compilePattern( Arguments.Regex , Arguments.Flags )
			.split(Arguments.Text)
			/>
	</cffunction>



</cfcomponent>