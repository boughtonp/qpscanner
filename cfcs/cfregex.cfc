<cfcomponent output=false >


	<cffunction name="init" returntype="any" output=false>
		<cfset StructDelete(This,'init') />

		<cfset Variables.Modes =
			{ UNIX_LINES       = 1
			, CASE_INSENSITIVE = 2
			, COMMENTS         = 4
			, MULTILINE        = 8
			, DOTALL           = 32
			, UNICODE_CASE     = 64
			, CANON_EQ         = 128
			}/>

		<cfset Variables.DefaultModes = 0 />

		<cfreturn This.compile(ArgumentCollection=Arguments) />
	</cffunction>


	<!---
		\\\ INTERNAL \\\
	--->

	<cffunction name="parseModes" returntype="Numeric" output="false" access="private">
		<cfargument name="ModeList"           type="String"  required="true" />
		<cfargument name="IgnoreInvalidModes" type="Boolean" default="false"/>
		<cfset var CurrentMode = ""/>
		<cfset var ResultMode = 0/>

		<cfloop index="CurrentMode" list="#Arguments.ModeList#">

			<cfif isNumeric(CurrentMode)>
				<cfset ResultMode = BitOr( ResultMode , CurrentMode )/>

			<cfelseif StructKeyExists( Variables.Modes , CurrentMode )>
				<cfset ResultMode = BitOr( ResultMode , Variables.Modes[CurrentMode] )/>

			<cfelseif NOT Arguments.IgnoreInvalidModes>
				<cfthrow
					message = "Invalid Mode!"
					detail  = "Mode [#CurrentMode#] is not supported."
					type    = "cfRegex.Compile.InvalidMode"
				/>

			</cfif>

		</cfloop>

		<cfreturn ResultMode />
	</cffunction>


	<cffunction name="compilePattern" returntype="void" output="false" access="private">
		<cfargument name="Pattern" type="String" required="true" />
		<cfargument name="Modes"   type="String" required="true" />

		<cfset Variables.PatternText = Arguments.Pattern />

		<cfset Variables.ActiveModes = parseModes(Arguments.Modes) />

		<cfset Variables.PatternObject = createObject("java","java.util.regex.Pattern")
			.compile( Arguments.Pattern , Variables.ActiveModes ) />

	</cffunction>


	<cffunction name="buildMatchInfo" returntype="Struct" output="false" access="private">
		<cfargument name="Matcher"    type="any"     required="true" />
		<cfargument name="PosOffset"  type="Numeric" optional />
		<cfargument name="GroupNames" type="any"     optional />

		<cfset var MatchInfo =
			{ Match  = Matcher.group()
			, Groups = []
			} />

		<cfif StructKeyExists(Arguments,'PosOffset')>
			<cfset MatchInfo.Pos    = Arguments.PosOffset+Matcher.start() />
			<cfset MatchInfo.Len    = Matcher.end()-Matcher.start() />
		</cfif>

		<cfset var CurGroup = 0 />
		<cfloop index="CurGroup" from=1 to=#Matcher.groupCount()#>
			<cfif StructKeyExists(Arguments,'PosOffset')>
				<cfset MatchInfo.Groups[CurGroup] =
					{ Pos   = Arguments.PosOffset+Matcher.start(CurGroup)
					, Len   = Matcher.end(CurGroup)-Matcher.start(CurGroup)
					, Match = Matcher.group(JavaCast('int',CurGroup))
					} />
			<cfelse>
				<cfset MatchInfo.Groups[CurGroup] = Matcher.group(JavaCast('int',CurGroup)) />
			</cfif>
		</cfloop>

		<cfif StructKeyExists(Arguments,'GroupNames')>
			<cfif isSimpleValue(Arguments.GroupNames)>
				<cfset Arguments.GroupNames = ListToArray(Arguments.GroupNames) />
			</cfif>
			<cfif ArrayLen(Arguments.GroupNames)>
				<cfset var i = 0 />
				<cfset MatchInfo.NamedGroups = {} />
				<cfloop index="i" from="1" to="#Min(ArrayLen(Arguments.GroupNames),ArrayLen(MatchInfo.Groups))#">
					<cfset MatchInfo.NamedGroups[ Arguments.GroupNames[i] ] = MatchInfo.Groups[i] />
				</cfloop>
			</cfif>
		</cfif>

		<cfreturn MatchInfo />
	</cffunction>


	<!---
		/// INTERNAL ///
	--->


	<cffunction name="compile" returntype="cfRegex"    output="false" access="public" action>
		<cfargument name="Pattern" type="String" required="true" />
		<cfargument name="Modes"   type="String" default="#Variables.DefaultModes#" />
		<cfset StructDelete(This,'compile') />

		<cfset compilePattern(ArgumentCollection=Arguments) />

		<cfreturn this />
	</cffunction>

	<!---
		\\\ EXTERNAL \\\
	--->

	<cffunction name="find"    returntype="Array"   output="false" access="public" action>
		<cfargument name="Text"       type="String"  required="true"  />
		<cfargument name="Start"      type="Numeric" default=1  />
		<cfargument name="Limit"      type="Numeric" default=0 />
		<cfargument name="ReturnType" type="String"  default="pos" />

		<cfif NOT ListFindNoCase('pos,sub,info',Arguments.ReturnType)>
			<cfthrow message="Unknown returntype" />
		</cfif>

		<cfset var Offset = Max(1,Arguments.Start) />
		<cfif Offset GT 1>
			<cfset Arguments.Text = mid(Arguments.Text,Offset,Len(Arguments.Text)) />
		</cfif>

		<cfset var Matcher = Variables.PatternObject.Matcher(Arguments.Text) />
		<cfset var Results = [] />

		<cfloop condition="Matcher.find()">
			<cfswitch expression=#LCase(Arguments.ReturnType)#>
				<cfcase value="pos">
					<cfset var CurMatch = Offset+Matcher.start() />
				</cfcase>
				<cfcase value="sub">
					<cfset var CurMatch =
						{ pos = [Offset+Matcher.start()]
						, len = [Matcher.end()-Matcher.start()]
						} />
					<cfloop index="local.CurGroup" from=1 to=#Matcher.groupCount()#>
						<cfset ArrayAppend(CurMatch.pos,Offset+Matcher.start(CurGroup)) />
						<cfset ArrayAppend(CurMatch.len,Matcher.end(CurGroup)-Matcher.start(CurGroup)) />
					</cfloop>
				</cfcase>
				<cfcase value="info">
					<cfset var CurMatch = buildMatchInfo(Matcher,Offset) />
				</cfcase>
			</cfswitch>
			<cfset ArrayAppend( Results , CurMatch ) />

			<cfif ArrayLen(Results) EQ Arguments.Limit>
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn Results />
	</cffunction>


	<cffunction name="match"   returntype="Array"   output="false" access="public" action>
		<cfargument name="Text"         type="String"   required="true"  />
		<cfargument name="Start"        type="Numeric"  optional  />
		<cfargument name="Limit"        type="Numeric"  default=0 />
		<cfargument name="ReturnType"   type="String"   default="match" hint="match|groups|namedgroups|full" />
		<cfargument name="GroupNames"   type="any"      default="" hint="Required if returnType=NamedGroup." />
		<cfargument name="Callback"     type="any"      optional   hint="Function called to determine if a match is included in results." />
		<cfargument name="CallbackData" type="Struct"   optional   hint="Extra data which is passed in to callback function." />

		<cfif NOT ListFindNoCase('match,groups,namedgroups,full',Arguments.ReturnType)>
			<cfthrow message="Unknown returntype" />
		</cfif>

		<cfset var Offset = 1 />
		<cfif StructKeyExists(Arguments,'Start') AND Arguments.Start>
			<cfset Arguments.Text = mid(Arguments.Text,Arguments.Start,Len(Arguments.Text)) />
			<cfset Offset = Arguments.Start+1 />
		</cfif>

		<cfset var Matcher = Variables.PatternObject.Matcher(Arguments.Text) />
		<cfset var Results = [] />

		<cfif StructKeyExists(Arguments,'GroupNames') AND isSimpleValue(Arguments.GroupNames)>
			<cfset Arguments.GroupNames = ListToArray(Arguments.GroupNames) />
		</cfif>

		<cfloop condition="Matcher.find()">

			<cfif StructKeyExists(Arguments,'Callback')>
				<cfif NOT StructKeyExists(Arguments,'CallbackData')>
					<cfset Arguments.CallbackData = {} />
				</cfif>
				<cfif NOT Arguments.Callback( ArgumentCollection=buildMatchInfo(Matcher,Offset,Arguments.GroupNames) , Data=Arguments.CallbackData )>
					<cfcontinue />
				</cfif>
			</cfif>

			<cfswitch expression=#Arguments.ReturnType#>
				<cfcase value="match">
					<cfset var CurMatch = Matcher.Group() />
				</cfcase>
				<cfcase value="groups">
					<cfset var CurMatch = [] />
					<cfloop index="local.CurGroup" from=1 to=#Matcher.groupCount()#>
						<cfset CurMatch[CurGroup] = Matcher.group(JavaCast('int',CurGroup)) />
					</cfloop>
				</cfcase>
				<cfcase value="namedgroups">
					<cfset var CurMatch = {} />
					<cfloop index="local.CurGroup" from=1 to=#Matcher.groupCount()#>
						<cfset CurMatch[Arguments.GroupNames[CurGroup]] = Matcher.group(JavaCast('int',CurGroup)) />
					</cfloop>
				</cfcase>
				<cfcase value="full">
					<cfset var CurMatch = buildMatchInfo(Matcher=Matcher,GroupNames=Arguments.GroupNames) />
				</cfcase>
			</cfswitch>

			<cfset ArrayAppend( Results , CurMatch ) />

			<cfif ArrayLen(Results) EQ Arguments.Limit>
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn Results />
	</cffunction>


	<cffunction name="matches" returntype="any" output="false" access="public" action>
		<cfargument name="Text"       type="String"  required="true" />
		<cfargument name="ReturnType" type="String"  optional hint="exact,partial,start,end,count" />

		<cfif StructKeyExists(Arguments,'ReturnType')>
			<cfset Arguments.ReturnType = LCase(Arguments.ReturnType) />

		<!--- INFO: If no unnamed args, don't waste time checking for them. --->
		<cfelseif StructCount(arguments) EQ 2>
			<cfset Arguments.ReturnType = 'exact' />

		<cfelse>
			<cfif StructKeyExists(Arguments,'Exact') AND Arguments.Exact >
				<cfset Arguments.ReturnType = "exact" />
			<cfelseif StructKeyExists(Arguments,'Count') AND Arguments.Count >
				<cfset Arguments.ReturnType = "count" />
			<cfelse>
				<cfif StructKeyExists(Arguments,'at')>
					<cfif Arguments.At EQ 'anywhere'>
						<cfset Arguments.ReturnType = 'partial' />
					<cfelse>
						<cfset Arguments.ReturnType = LCase(Arguments.At) />
					</cfif>
				<cfelseif StructKeyExists(Arguments,'Partial') AND Arguments.Partial >
					<cfset Arguments.ReturnType = "partial" />
				</cfif>
			</cfif>
			<cfif NOT StructKeyExists(Arguments,'ReturnType')>
				<cfset Arguments.ReturnType = 'exact' />
			</cfif>
		</cfif>

		<cfswitch expression="#Arguments.ReturnType#">
			<cfcase value="exact">
				<cfreturn Variables.PatternObject.Matcher(Arguments.Text).matches() />
			</cfcase>
			<cfcase value="count">
				<cfset var Matcher = Variables.PatternObject.Matcher(Arguments.Text) />
				<cfset local.Count = 0 />
				<cfloop condition="Matcher.find()">
					<cfset local.Count++ />
				</cfloop>
				<cfreturn local.Count />
			</cfcase>
			<cfcase value="start">
				<cfreturn Variables.PatternObject.Matcher(Arguments.Text).lookingAt() />
			</cfcase>
			<cfcase value="end">
				<cfset var Matcher = Variables.PatternObject.Matcher(Arguments.Text) />
				<cfset var LastPos = -1 />
				<cfloop condition="Matcher.find()">
					<cfset LastPos = Matcher.end() />
				</cfloop>
				<cfreturn (LastPos EQ Len(Arguments.Text)) />
			</cfcase>
			<cfcase value="partial">
				<cfreturn Variables.PatternObject.Matcher(Arguments.Text).find() />
			</cfcase>
			<cfdefaultcase>
				<cfthrow
					message = "Invalid ReturnType '#Arguments.ReturnType#' for matches"
					type    = "cfRegex.Match.InvalidArgument.ReturnType"
				/>
			</cfdefaultcase>
		</cfswitch>
	</cffunction>


	<cffunction name="escape"  returntype="String"  output="false" access="public" action>
		<cfargument name="ReturnType" type="String" default=REGEX hint="regex|class" />
		<cfif NOT ListFind('regex,class',LCase(Arguments.ReturnType))>
			<cfthrow
				message = "Invalid Argument ReturnType, received [#Arguments.ReturnType#]"
				detail  = "ReturnType value must be one of 'regex' OR 'class'."
				type    = "cfRegex.Escape.InvalidArgument.ReturnType"
			/>
		</cfif>
		<cfif NOT StructKeyExists(Variables,'Escaped#Arguments.ReturnType#')>
			<cfif Arguments.ReturnType EQ 'regex'>
				<cfset Variables.EscapedRegex = Variables.PatternText.replaceAll('[$^*()+\[\]{}.?\\|]','\\$0') />
			<cfelse>
				<cfset Variables.EscapedClass = Variables.PatternText
					.replaceAll('(.)(?=.*?\1)','')
					.replaceAll('(^\^|[\\\-\[\]])','\\$0')
					.replaceAll(chr(9),'\t')
					.replaceAll(chr(10),'\n')
					.replaceAll(chr(13),'\r')
					/>
			</cfif>
			<cfif BitAnd(Variables.ActiveModes,Variables.Modes['COMMENTS']) >
				<cfset Variables['Escaped#Arguments.ReturnType#'] = Variables['Escaped#Arguments.ReturnType#'].replaceAll('##| ','\\$0') />
			</cfif>
		</cfif>
		<cfreturn Variables['Escaped#Arguments.ReturnType#'] />
	</cffunction>


	<cffunction name="quote"   returntype="String"  output="false" access="public" action>
		<cfif NOT StructKeyExists(Variables,'Quoted')>
			<cfset Variables.Quoted = createObject("java","java.util.regex.Pattern").quote(Variables.PatternText) />
		</cfif>
		<cfreturn Variables.Quoted />
	</cffunction>


	<cffunction name="replace" returntype="String"  output="false" access="public" action>
		<cfargument name="Text"         type="String"  required="true"  />
		<cfargument name="Replacement"  type="Any"     optional hint="String,Array,Function"/>
		<cfargument name="Start"        type="Numeric" optional  />
		<cfargument name="Limit"        type="Numeric" default=0 />
		<cfargument name="GroupNames"   type="any"     default="" hint="Passed into Callback function if provided" />
		<cfargument name="CallbackData" type="Struct"  optional   hint="Extra data which is passed in to callback function." />

		<cfif StructKeyExists(Arguments,'Callback') >
			<cfset Arguments.Replacement = Arguments.Callback />
		<cfelseif NOT StructKeyExists(Arguments,'Replacement')>
			<cfthrow
				message = "Missing Argument Replacement"
				type    = "cfRegex.Replace.MissingArgument"
			/>
		</cfif>

		<cfset var Prefix = "" />
		<cfset var Offset = 1 />
		<cfif StructKeyExists(Arguments,'Start') AND Arguments.Start >
			<cfset Offset = Arguments.Start+1 />
			<cfset Prefix = Left(Arguments.Text,Arguments.Start) />
			<cfset Arguments.Text = Mid(Arguments.Text,Arguments.Start+1,Len(Arguments.Text)) />
		</cfif>

		<cfset var Matcher = Variables.PatternObject.Matcher( Arguments.Text )/>
		<cfset var Results = createObject("java","java.lang.StringBuffer").init(Prefix)/>
		<cfset var ReplacementsMade = 0 />
		<cfset var ReplacePos = 1 />

		<cfif NOT StructKeyExists(Arguments,'CallbackData')>
			<cfset Arguments.CallbackData = {} />
		</cfif>

		<cfloop condition="Matcher.find()">

			<cfif isSimpleValue(Arguments.Replacement)>
				<cfset Matcher.appendReplacement( Results , Arguments.Replacement )/>

			<cfelseif isArray(Arguments.Replacement)>

				<cfif isSimpleValue(Arguments.Replacement[ReplacePos])>
					<cfset Matcher.appendReplacement( Results , Arguments.Replacement[ReplacePos] )/>
				<cfelse>
					<cfset var CurrentReplaceFunc = Arguments.Replacement[ReplacePos] />
<cfset Matcher.appendReplacement
						( Results
						, CurrentReplaceFunc( ArgumentCollection=buildMatchInfo(Matcher,Offset,Arguments.GroupNames) , Data = Arguments.CallbackData )
						)/>
				</cfif>

				<cfif ++ReplacePos GT ArrayLen(Arguments.Replacement)>
					<cfset ReplacePos = 1 />
				</cfif>

			<cfelse>

				<cfset Matcher.appendReplacement
					( Results
					, Arguments.Replacement( ArgumentCollection=buildMatchInfo(Matcher,Offset,Arguments.GroupNames) , Data = Arguments.CallbackData )
					)/>

			</cfif>

			<cfif ++ReplacementsMade EQ Arguments.Limit>
				<cfbreak/>
			</cfif>

		</cfloop>

		<cfset Matcher.appendTail(Results)/>

		<cfreturn Results.toString() />
	</cffunction>


	<cffunction name="split"   returntype="Array"   output="false" access="public" action>
		<cfargument name="Text"         type="String"  required="true" />
		<cfargument name="Start"        type="Numeric" optional  />
		<cfargument name="Limit"        type="Numeric" default=0  hint="The maximum number of times a split is made (i.e. limit+1=max array size)"/>
		<cfargument name="GroupNames"   type="any"     default="" hint="Passed into Callback function if provided" />
		<cfargument name="Callback"     type="any"     optional />
		<cfargument name="CallbackData" type="Struct"  optional hint="Extra data which is passed in to callback function." />

		<cfset var Offset = 1 />
		<cfif StructKeyExists(Arguments,'Start') AND Arguments.Start >
			<cfset var Prefix = Left(Arguments.Text,Arguments.Start) />
			<cfset Offset = 1+Arguments.Start />
			<cfset Arguments.Text = Mid(Arguments.Text,Arguments.Start+1,Len(Arguments.Text)) />
		</cfif>

		<cfif StructKeyExists(Arguments,'Callback')>
			<cfset var Matcher = Variables.PatternObject.Matcher( Arguments.Text )/>
			<cfset var TextPos = 1 />
			<cfset var ArrayPos = 1 />
			<cfset var Results = [''] />
			<cfif NOT StructKeyExists(Arguments,'CallbackData')>
				<cfset Arguments.CallbackData = {} />
			</cfif>

			<cfloop condition="Matcher.find(TextPos-1)">

				<cfif Arguments.Callback( ArgumentCollection=buildMatchInfo(Matcher,Offset,Arguments.GroupNames) , Data=Arguments.CallbackData )>

					<cfset Results[ArrayPos] &= mid(Arguments.Text,TextPos,Matcher.start()+1-TextPos) />
					<cfset TextPos = Matcher.end()+1 />

					<cfset ArrayPos++ />
					<cfset Results[ArrayPos] = '' />

					<cfif Arguments.Limit AND ArrayLen(Results) GT Arguments.Limit>
						<cfbreak />
					</cfif>
				<cfelse>
					<cfset Results[ArrayPos] &= mid(Arguments.Text,TextPos,Matcher.end()+1-TextPos) />
					<cfset TextPos = Matcher.end()+1 />
				</cfif>

			</cfloop>

			<cfset Results[ArrayPos] &= mid(Arguments.Text,TextPos,len(Arguments.Text)) />

		<cfelse>
			<cfif Arguments.Limit>
				<!---
					NOTE:
					For java.util.regex, limit is array length.
					For cfregex, limit is number of times the action occurs.
					Therefor, must add one...
				--->
				<cfset var Results = Variables.PatternObject.split(Arguments.Text,Arguments.Limit+1) />
			<cfelse>
				<cfset var Results = Variables.PatternObject.split(Arguments.Text) />
			</cfif>
		</cfif>

		<cfif isDefined('Prefix') AND ArrayLen(Results)>
			<cfset Results[1] = Prefix & Results[1] />
		</cfif>

		<cfreturn Results />
	</cffunction>

	<!---
		/// EXTERNAL ///
	--->



	<!---
		CALLBACK SAMPLES

		A callback function can be used with the following functions:
		.replace
		.match
		.split

		A callback is called each time a match is found, and allows for
		conditional behaviour to be executed at this point,
		to change how the function behaves towards the match.

		A Replace Callback determines what text to use for replacement.
		A Match Callback determines whether to include or exclude the match in results.
		A Split Callback determines whether to split or not at the match.

		The callbacks are identical except for returntype.
		(For Replace it returns text, for everything else, it returns a boolean.)

		See http://docs.cfregex.net/Callbacks.html

		<cffunction name="ReplaceCallback" returntype="String" output="false">
			<cfargument name="Pos"         type="Numeric" required="true"  hint="The start position of the match."  />
			<cfargument name="Len"         type="Numeric" required="true"  hint="The length of the match."          />
			<cfargument name="Match"       type="String"  required="true"  hint="The text of the match."            />
			<cfargument name="Groups"      type="Array"   required="true"  hint="Array of group information."       />
			<cfargument name="NamedGroups" type="Struct"  optional  hint="Struct of named group information." />
			<cfargument name="Data"        type="Struct"  optional  hint="Struct containing passed-in data." />

			<cfreturn 'replacement text' />
		</cffunction>


		<cffunction name="BooleanCallback" returntype="Boolean" output="false">
			<cfargument name="Pos"         type="Numeric" required="true"  hint="The start position of the match."  />
			<cfargument name="Len"         type="Numeric" required="true"  hint="The length of the match."          />
			<cfargument name="Match"       type="String"  required="true"  hint="The text of the match."            />
			<cfargument name="Groups"      type="Array"   required="true"  hint="Array of group information."       />
			<cfargument name="NamedGroups" type="Struct"  optional  hint="Struct of named group information." />
			<cfargument name="Data"        type="Struct"  optional  hint="Struct containing passed-in data." />

			<cfreturn true />
		</cffunction>

	--->


</cfcomponent>