<cfcomponent output="false">


	<cffunction name="init" returntype="any" output="false" access="public">
		<cfargument name="ConfigDirectory" type="String"/>

		<cfset This.ConfigDirectory = Arguments.ConfigDirectory/>

		<cfreturn This/>
	</cffunction>


	<cffunction name="read" returntype="any" output="false" access="public">
		<cfargument name="ConfigId"  type="String" required />
		<cfargument name="Format"    type="String" default="default" />
		<cfargument name="Overrides" type="Struct" optional />
		<cfset var Setting = QueryNew("id,label,type,options,value,hint")/>
		<cfset var Sections = -1/>
		<cfset var SectionList = -1/>
		<cfset var CurSection = -1/>
		<cfset var CurSetting = -1/>
		<cfset var X = -1/>
		<cfset var Result = -1/>
		<cfset var RootConfigFile = This.ConfigDirectory&'/../config.ini' />
		<cfset var ThisConfigFile = lcase( REreplace( Arguments.ConfigId , '\W+' , '' , 'all' ) ) />
		<cfset ThisConfigFile = This.ConfigDirectory & '/#Arguments.ConfigId#.ini'/>

		<cfif FileExists( ThisConfigFile )>

			<cfset Sections = getProfileSections( RootConfigFile )/>
			<cfset SectionList = getProfileString( RootConfigFile ,'Config' , 'keys' )/>

			<cfloop index="CurSection" list="#SectionList#">
				<cfset X = QueryAddRow(Setting)/>
				<cfset Setting['Id'][X] = CurSection />
				<cfloop index="CurSetting" list="#Sections[CurSection]#">
					<cfset Setting[CurSetting][X] = getProfileString( RootConfigFile , CurSection , CurSetting )/>
				</cfloop>
			</cfloop>

			<cfloop query="Setting">
				<cfset Setting['Value'][CurrentRow] = getProfileString( ThisConfigFile , 'Settings' , Id )/>
			</cfloop>


			<cfswitch expression="#Arguments.Format#">
				<cfcase value="Struct">
					<cfset Result = StructNew()/>
					<cfloop query="Setting">
						<cfset Result[Id] = Value />
					</cfloop>

					<cfif StructKeyExists(Arguments,'Overrides')>
						<cfset overrideDefaults(Result,Arguments.Overrides) />

						<cfset expandValues(Result) />
					</cfif>

					<cfreturn Result/>
				</cfcase>
				<cfdefaultcase>
					<cfreturn Setting/>
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<cfthrow
				message="Invalid Value '#Arguments.ConfigId#' for Argument ConfigId."
				detail="Cannot find configuration file at '#ConfigFile#'."
				type="qpscanner.Settings.Read.InvalidArgument.ConfigId"
			/>
		</cfif>
	</cffunction>


	<cffunction name="overrideDefaults" returntype="void" output=false access="private">
		<cfargument name="ScanSettings" type="Struct" required />
		<cfargument name="Overrides"    type="Struct" required />

		<cfloop item="local.Setting" collection="#Arguments.ScanSettings#">
			<cfif StructKeyExists( Arguments.Overrides , Setting )>
				<cfset Arguments.ScanSettings[Setting] = Arguments.Overrides[Setting] />
			</cfif>
		</cfloop>
	</cffunction>


	<cffunction name="expandValues" returntype="void" output=false access="private">
		<cfargument name="ScanSettings" type="Struct" required />

		<cfif StructKeyExists(Arguments.ScanSettings,'RequestTimeout')
			AND NOT isNumeric(Arguments.ScanSettings.RequestTimeout)
			>
			<cfset Arguments.ScanSettings.RequestTimeout = -1/>
		</cfif>

		<cfif Arguments.ScanSettings.StartingDir EQ 'auto'>
			<cfset Arguments.ScanSettings.StartingDir = findHomeDirectory()/>
		</cfif>

		<cfif NOT (ListFind('ColdFusion Server,BlueDragon',Server.ColdFusion.ProductName)
			AND isAbsoluteDirectory(Arguments.ScanSettings.StartingDir)
			)>
			<cfset Arguments.ScanSettings.StartingDir = expandPath( Arguments.ScanSettings.StartingDir & '/' )/>
		</cfif>

		<cfset Arguments.ScanSettings.StartingDir = Arguments.ScanSettings.StartingDir.replaceAll('\\','/').replaceAll('/+$','') />

	</cffunction>


	<cffunction name="isAbsoluteDirectory" returntype="Boolean" output=false access="private">
		<cfargument name="DirName" type="String" />

		<cfif findnocase('windows',Server.OS.Name)>
			<cfreturn refindnocase('\A[a-z]:',Arguments.DirName) />
		<cfelse>
			<cfreturn (left(Arguments.DirName,1) EQ '/') />
		</cfif>
	</cffunction>


	<cffunction name="findHomeDirectory" returntype="String" output="false">
		<cfset var Result = ""/>
		<cfset var CurDir = -1/>
		<cfset var DirList = "{home-directory},/,."/>

		<cfloop index="CurDir" list="#DirList#">
			<cfif DirectoryExists( expandPath(CurDir) )>
				<cfset Result = expandPath( CurDir )/>
				<cfbreak/>
			</cfif>
		</cfloop>

		<cfreturn Result.replaceAll('[\\/]+','/').replaceAll('(<!(:))/$','')  />
	</cffunction>


</cfcomponent>