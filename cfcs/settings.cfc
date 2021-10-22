<!--- qpscanner v0.8-rc | (c) Peter Boughton | License: GPLv3 | Website: https://www.sorcerersisle.com/software/qpscanner --->
<cfcomponent output=false >

	<cffunction name="init" returntype="any" output=false access="public">
		<cfargument name="ConfigDirectory" type="String"/>

		<cfset This.ConfigDirectory = Arguments.ConfigDirectory/>

		<cfreturn This/>
	</cffunction>


	<cffunction name="read" returntype="any" output=false access="public">
		<cfargument name="ConfigId"  type="String" required_ />
		<cfargument name="Format"    type="String" default="default" />
		<cfargument name="Overrides" type="Struct" optional />
		<cfset var Setting = QueryNew("id,label,type,options,value,hint,status") />
		<cfset var Sections    = -1 />
		<cfset var SectionList = -1 />
		<cfset var CurSection  = -1 />
		<cfset var CurSetting  = -1 />
		<cfset var X           = -1 />
		<cfset var Result      = -1 />
		<cfset var RootConfigFile = This.ConfigDirectory&'/../config.ini' />
		<cfset var ThisConfigFile = lcase( REreplace( Arguments.ConfigId , '\W+' , '' , 'all' ) ) />
		<cfset ThisConfigFile = This.ConfigDirectory & '/#ThisConfigFile#.ini' />

		<cfif FileExists( ThisConfigFile )>

			<cfset Sections    = getProfileSections( RootConfigFile ) />
			<cfset SectionList = getProfileString( RootConfigFile ,'Config' , 'keys' ) />

			<cfloop index="CurSection" list=#SectionList# >
				<cfset X = QueryAddRow(Setting)/>
				<cfset Setting['Id'][X] = CurSection />
				<cfloop index="CurSetting" list=#Sections[CurSection]# >
					<cfset Setting[CurSetting][X] = getProfileString( RootConfigFile , CurSection , CurSetting )/>
				</cfloop>
			</cfloop>

			<cfloop query="Setting">
				<cfset Setting['Value'][CurrentRow] = getProfileString( ThisConfigFile , 'Settings' , Id )/>
			</cfloop>

			<cfswitch expression=#Arguments.Format# >
				<cfcase value="Struct">
					<cfset Result = StructNew()/>
					<cfloop query="Setting">
						<cfset Result[Id] = Value />
					</cfloop>

					<cfif StructKeyExists(Arguments,'Overrides')>
						<cfset overrideDefaults(Result,Arguments.Overrides) />

						<cfset expandValues(Result) />
					</cfif>

					<cfreturn Result />
				</cfcase>
				<cfdefaultcase>
					<cfreturn Setting />
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<cfthrow
				message = "Invalid Value '#Arguments.ConfigId#' for Argument ConfigId."
				detail  = "Cannot find configuration file at '#ConfigFile#'."
				type    = "qpscanner.Settings.Read.InvalidArgument.ConfigId"
			/>
		</cfif>
	</cffunction>


	<cffunction name="overrideDefaults" returntype="void" output=false access="private">
		<cfargument name="ScanSettings" type="Struct" required_ />
		<cfargument name="Overrides"    type="Struct" required_ />

		<cfloop item="local.Setting" collection=#Arguments.ScanSettings# >
			<cfif StructKeyExists( Arguments.Overrides , Setting )>
				<cfset Arguments.ScanSettings[Setting] = Arguments.Overrides[Setting] />
			</cfif>
		</cfloop>
	</cffunction>


	<cffunction name="expandValues" returntype="void" output=false access="private">
		<cfargument name="ScanSettings" type="Struct" required_ />

		<cfif StructKeyExists(Arguments.ScanSettings,'RequestTimeout')
			AND NOT isNumeric(Arguments.ScanSettings.RequestTimeout)
			>
			<cfset Arguments.ScanSettings.RequestTimeout = -1 />
		</cfif>

		<cfif Arguments.ScanSettings.StartingDir EQ 'auto'>
			<cfset Arguments.ScanSettings.StartingDir = findHomeDirectory() />
		</cfif>

		<cfset Arguments.ScanSettings.StartingDir = normalizePath(Arguments.ScanSettings.StartingDir) />

	</cffunction>


	<cffunction name="findHomeDirectory" returntype="String" output=false access="public">
		<cfset var CurDir = -1/>
		<cfset var DirList = "{home-directory},/,." />

		<cfloop index="CurDir" list=#DirList# >
			<cfif DirectoryExists( expandPath(CurDir) )>
				<cfreturn normalizePath( expandPath( CurDir ) ) />
			</cfif>
		</cfloop>
	</cffunction>


	<cffunction name="normalizePath" returntype="String" output=false access="private">
		<cfargument name="Path" type="String" required_ />

		<cfset var Result = Arguments.Path.replaceAll('[\\/]+','/') />

		<cfif len(Result) AND Result.endsWith('/') AND NOT Result.endsWith(':/') >
			<cfset Result = Left(Result,len(Result)-1) />
		</cfif>

		<cfreturn Result />
	</cffunction>


</cfcomponent>