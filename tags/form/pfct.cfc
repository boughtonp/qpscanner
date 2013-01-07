<cfcomponent output="no">


	<cffunction name="Init" returntype="Any" output="No" access="Public">
		<!--- Settings --->
		<cfargument name="InlineValidation"   type="Boolean" default="False"/>
		<cfargument name="HighlightErrors"    type="Boolean" default="False"/>
		<cfargument name="AutoTabIndex"       type="Boolean" default="False"/>
		<cfargument name="AutoAccessKey"      type="Boolean" default="False"/>
		<cfargument name="HighlightAccessKey" type="Boolean" default="False"/>
		<cfargument name="AccessKeyOnTags"    type="Boolean" default="False"/>
		<cfargument name="UseLegend"          type="Boolean" default="False"/>
		<cfargument name="SendValue"          type="Boolean" default="True"/>
		<cfargument name="QueryInAction"      type="Boolean" default="False"/>

		<!--- Initial Values --->
		<cfargument name="TabIndex"           type="Numeric" default="0"/>
		<cfargument name="ReservedTabIndexes" type="String" default=""/>
		<cfargument name="ActiveScripts"      type="String" default=""/>

		<cfargument name="ErrorsVar"          type="String" default="Request.Errors"/>
		<cfargument name="ValidationEvents"   type="String" default="onblur"/>
		<cfargument name="ValidationFunction" type="String" default="pfct.validate('##Attributes.Id##', '##Attributes.Label##', ##Attributes.Required##)"/>

		<cfargument name="DateFunction"       type="String" default="pfct.formatDate('##Attributes.Id##', '##Attributes.InputPriority##', '##Attributes.OutputFormat##', '##Attributes.MinDate##', '##Attributes.MaxDate##')"/>
		<cfargument name="DateOutputFormat"   type="String" default="dd-mmm-yyyy"/>
		<cfargument name="DateInputPriority"  type="String" default="#ListFirst('DMY,YMD,MDY')#"/>

		<cfargument name="CalendarFunction"   type="String" default="showCalendar('##Attributes.Id##', '##Attributes.Value##')"/>
		<cfargument name="CalendarMethod"     type="String" default="DEFAULT"/>

		<!--- Script Settings --->
		<cfargument name="Location"           type="String" default="../form"/>
		<cfargument name="MainScript"         type="String" default="#Arguments.Location#/pfct.js.cfm"/>
		<!--- TODO: Decide on better validation script. --->
		<cfargument name="ValidationScript"   type="String" default="#Arguments.Location#/generic.validate.cfc"/>
		<!--- TODO: Tidy up calendar script(s) --->
		<cfargument name="CalendarScript"     type="String" default="#Arguments.Location#/calendar.js"/>
		<cfargument name="CalendarImage"      type="String" default="#Arguments.Location#/calendar.png"/>

		<!--- Constants --->
		<cfargument name="Splitters"          type="String"  default=":"/>
		<cfargument name="GroupSplitters"     type="String"  default="="/>
		<cfargument name="GroupDelimiters"    type="String"  default="|"/>
		<cfargument name="LabelHighlight"     type="String"  default="<em class=""accesskey"">\1</em>"/>
		<cfargument name="ButtonHighlight"    type="String"  default="&middot;\1&middot;"/>
		<cfargument name="AutoListMaxItems"   type="Numeric" default="5"/>
		<cfargument name="SelectFields"       type="String"  default="value,label,group"/>

		<!--- CSS Classes --->
		<cfargument name="FieldClass"         type="String" default="field"/>        <!--- Applied to DIV.field --->
		<cfargument name="RequiredClass"      type="String" default="required"/>     <!--- Applied to DIV.field and INPUT/SELECT --->
		<cfargument name="ReadonlyClass"      type="String" default="readonly"/>     <!--- Applied to DIV.field and INPUT/SELECT --->
		<cfargument name="LabelClass"         type="String" default="indiv header"/> <!--- Applied to main LABEL if no minors. --->
		<cfargument name="LabelHeaderClass"   type="String" default="header"/>       <!--- Applied to main LABEL in a field. --->
		<cfargument name="LabelItemClass"     type="String" default="indiv"/>        <!--- Applied to minor LABELs in a field. --->
		<cfargument name="FieldsetClass"      type="String" default="main"/>         <!--- Applied to FIELDSET.main --->
		<cfargument name="FieldsetLabelClass" type="String" default="label"/>        <!--- Applied to FIELDSET/LEGEND or FIELDSET/DIV.legend. --->
		<cfargument name="ControlsClass"      type="String" default="controls"/>     <!--- Applied to FIELDSET.controls --->
		<cfargument name="ErrorClass"         type="String" default="error"/>        <!--- applied to any element with validation errors.  --->
		<cfargument name="ErrorListClass"     type="String" default="errorlist"/>    <!--- applied to UL of errors. --->
		<cfargument name="HintClass"          type="String" default="hint"/>         <!--- applied to SMALL.hint ---->
		<cfargument name="EditClass"          type="String" default="edit"/>         <!--- applied to INPUT[text], INPUT[password], TEXTAREA] --->
		<cfargument name="BoxClass"           type="String" default="box"/>          <!--- applied to INPUT[checkbox] and INPUT[radio] --->
		<cfargument name="ValueClass"         type="String" default="value"/>        <!--- applied to div.VALUE --->
		<cfargument name="InputListClass"     type="String" default="input"/>        <!--- applied to ULs with INPUT[checkbox|radio] inside LIs --->

		<cfset var Arg = ""/>

		<!--- Place all properties into public This scope. --->
		<cfloop item="Arg" collection="#Arguments#">
			<cfset This[Arg] = Arguments[Arg]/>
		</cfloop>

		<cfreturn This/>
	</cffunction>



	<cffunction name="readAttributes" returntype="String" output="No" access="Public">
		<cfargument name="Attributes" type="Struct" required="True"/>
		<cfargument name="Prefixes"   type="String" required="False" default=""/>
		<cfargument name="Exclusions" type="String" required="False" default=""/>
		<cfargument name="Splitters"  type="String" required="False" default="#This.Splitters#"/>
		<cfargument name="Delimiters" type="String" required="False" default=","/>
		<cfset var Result = ""/>
		<cfset var Attr = ""/>
		<cfset var ThisPrefix = ""/>
		<cfset var Append = False/>

		<cfloop item="Attr" collection="#Arguments.Attributes#">
			<cfset Append = False/>
			<cfif Len(Arguments.Exclusions) AND ListFindNoCase(Arguments.Exclusions, Attr, Arguments.Delimiters)>
				<!--- Excluded; don't bother looking. --->
			<cfelse>
				<cfif Arguments.Prefixes EQ "{ALL}">
					<cfset Append = True/>
				<cfelseif ListLen(Attr, Arguments.Splitters) GT 1>
					<cfset ThisPrefix = ListFirst(Attr, Arguments.Splitters)/>
					<cfif ListFindNoCase(Arguments.Prefixes, ThisPrefix, Arguments.Delimiters)>
						<cfset Append = True/>
					</cfif>
				<cfelseif (Arguments.Prefixes EQ '') OR ListFindNoCase(Arguments.Prefixes, '{NON}', Arguments.Delimiters)>
					<cfset Append = True/>
				</cfif>
				<cfif Append>
					<cfif ListLen(Attr,Arguments.Splitters) GT 1>
						<cfset Result = ListAppend(Result
								, '#LCase(ListRest(Attr,Arguments.Splitters))#="#Arguments.Attributes[Attr]#"',' ')/>
					<cfelse>
						<cfset Result = ListAppend(Result
								, '#LCase(Attr)#="#Arguments.Attributes[Attr]#"',' ')/>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn Result/>
	</cffunction>



	<cffunction name="readNextTabIndex" returntype="Numeric" output="No" access="Public">
		<cftry>
			<cflock name="IncrementingTabIndex" timeout="3">
				<cfset This.TabIndex = This.TabIndex + 1/>
				<cfloop condition="ListFind(This.ReservedTabIndexes, This.TabIndex)">
					<cfset This.TabIndex = This.TabIndex + 1/>
				</cfloop>
				<cfreturn This.TabIndex/>
			</cflock>
			<cfcatch>
				<cfreturn 0/>
			</cfcatch>
		</cftry>
	</cffunction>


	<cffunction name="reserveTabIndex" returntype="Void" output="No" access="Public">
		<cfargument name="Index" type="Numeric" required="True"/>
		<cfif NOT ListFind(This.ReservedTabIndexes,Arguments.Index)>
			<cfset This.ReservedTabIndexes = ListAppend(This.ReservedTabIndexes, Arguments.Index)/>
		</cfif>
	</cffunction>



	<!--- TODO: Decide if reserveAccessKey() is necessary (IE cycles through, but FF only goes to first) --->


	<cffunction name="readAccessKey" returntype="String" output="No" access="Public">
		<cfargument name="Label" type="String" required="True"/>
		<cfset var Key = ""/>
		<cfset var i = 0/>
		<cfset Arguments.Label = REReplace(UCase(Arguments.Label),'[^A-Z0-9]','','all')/>
		<cfloop condition="(Key EQ '') AND (i LT Len(Arguments.Label))">
			<cfset  i = i + 1/>
			<!--- TODO: if using reserveAccessKey, implement <cfif checkAccessKey(Mid(Arguments.Label,i,1))> --->
			<cfset Key = Mid(Arguments.Label,i,1)/>
			<!--- </cfif> --->
		</cfloop>
		<!--- TODO: Decide what to do if Key is still blank here. --->
		<cfreturn Key/>
	</cffunction>



	<cffunction name="readHighlighted" returntype="String" output="No" access="Public">
		<cfargument name="Value"     type="String" required="True"/>
		<cfargument name="AccessKey" type="String" required="True"/>
		<cfargument name="Type"      type="String" required="No" default="LABEL"/>
		<cfset var Regex = ""/>
		<cfif Len(Arguments.AccessKey)>
			<cfswitch expression="#Arguments.Type#">
				<cfcase value="BTN,BUTTON">
					<cfset Regex = This.ButtonHighlight/>
				</cfcase>
				<cfdefaultcase>
					<cfset Regex = This.LabelHighlight/>
				</cfdefaultcase>
			</cfswitch>
			<cfreturn REReplaceNoCase(Arguments.Value, '(#Arguments.AccessKey#)', Regex)/>
		<cfelse>
			<cfreturn Arguments.Value/>
		</cfif>
	</cffunction>



	<cffunction name="linkScript" returntype="Boolean" output="No" access="Public">
		<cfargument name="Script"  type="String" required="True"/>
		<cfset var ScriptId = Hash(Arguments.Script)/>
		<cfif NOT ListFind(This.ActiveScripts, ScriptId)>
			<!---<cfhtmlhead text='<script type="text/javascript" src="#Arguments.Script#"></script>'/>--->
			<cfset This.ActiveScripts = ListAppend(This.ActiveScripts, ScriptId)/>
		</cfif>
		<cfreturn True/>
	</cffunction>






	<cffunction name="Options" returntype="Query" output="no" access="public">
		<cfargument name="Options"/>
		<cfargument name="Fields"          default="#This.SelectFields#"/>
		<cfargument name="Splitters"       default="#This.Splitters#"/>
		<cfargument name="GroupSplitters"  default="#This.GroupSplitters#"/>
		<cfargument name="GroupDelimiters" default="#This.GroupDelimiters#"/>
		<cfset var Result = QueryNew("value,label,group")/>
		<cfset var ThisGroup = "" />
		<cfset var Row = "" />
		<cfset var ThisRow = "" />
		<cfif IsSimpleValue(Arguments.Options)>
			<cfloop index="local.Group" list="#Arguments.Options#" delimiters="#Arguments.GroupDelimiters#">
				<cfif ListLen(Group, Arguments.GroupSplitters) GT 1>
					<cfset ThisGroup = ListFirst(Group, Arguments.GroupSplitters)/>
				<cfelse>
					<cfset ThisGroup = ""/>
				</cfif>
				<cfloop index="local.Item" list="#ListLast(Group, Arguments.GroupSplitters)#">
					<cfset Row = QueryAddRow(Result)/>
					<cfset Result.Value[Row] = ListFirst(Item, Arguments.Splitters)/>
					<cfset Result.Label[Row] = ListLast(Item,  Arguments.Splitters)/>
					<cfset Result.Group[Row] = ThisGroup/>
				</cfloop>
			</cfloop>
		<cfelseif IsQuery(Arguments.Options)>
			<cfloop query="Arguments.Options">
				<cfset Row = QueryAddRow(Result)/>
				<cfset Result.Value[Row] = Arguments.Options[ListGetAt(Arguments.Fields,1)]/>
				<cfset Result.Label[Row] = Arguments.Options[ListGetAt(Arguments.Fields,2)]/>
				<cfif ListLen(Arguments.Fields) GT 2>
					<cfset Result.Group[Row] = Arguments.Options[ListGetAt(Arguments.Fields,3)]/>
				</cfif>
			</cfloop>
		<cfelseif IsArray(Arguments.Options)>
			<cfloop index="local.i" from="1" to="#ArrayLen(Arguments.Options)#">
				<cfset ThisRow = Options
					( Arguments.Options
					, Arguments.Fields
					, Arguments.Splitters
					, Arguments.GroupSplitters
					, Arguments.GroupDelimiters
					)/>
				<cfset Row = QueryAddRow(Result)/>
				<cfset Result.Value[Row] = ThisRow.Value/>
				<cfset Result.Label[Row] = ThisRow.Label/>
				<cfset Result.Group[Row] = ThisRow.Group/>
			</cfloop>
		<cfelseif IsStruct(Arguments.Options)>
			<cfloop item="local.Key" collection="#Arguments.Options#">
				<cfset Row = QueryAddRow(Result)/>
				<cfset Result.Value[Row] = Key/>
				<cfset Result.Label[Row] = Arguments.Options[Key]/>
			</cfloop>
		</cfif>
		<cfreturn Result/>
	</cffunction>




</cfcomponent>