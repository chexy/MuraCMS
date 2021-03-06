<!--- This file is part of Mura CMS.

Mura CMS is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, Version 2 of the License.

Mura CMS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Mura CMS. If not, see <http://www.gnu.org/licenses/>.

Linking Mura CMS statically or dynamically with other modules constitutes the preparation of a derivative work based on 
Mura CMS. Thus, the terms and conditions of the GNU General Public License version 2 ("GPL") cover the entire combined work.

However, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with programs
or libraries that are released under the GNU Lesser General Public License version 2.1.

In addition, as a special exception, the copyright holders of Mura CMS grant you permission to combine Mura CMS with 
independent software modules (plugins, themes and bundles), and to distribute these plugins, themes and bundles without 
Mura CMS under the license of your choice, provided that you follow these specific guidelines: 

Your custom code 

• Must not alter any default objects in the Mura CMS database and
• May not alter the default display of the Mura CMS logo within Mura CMS and
• Must not alter any files in the following directories.

 /admin/
 /tasks/
 /config/
 /requirements/mura/
 /Application.cfc
 /index.cfm
 /MuraProxy.cfc

You may copy and distribute Mura CMS with a plug-in, theme or bundle that meets the above guidelines as a combined work 
under the terms of GPL for Mura CMS, provided that you include the source code of that other code when and as the GNU GPL 
requires distribution of source code.

For clarity, if you create a modified version of Mura CMS, you are not obligated to grant this special exception for your 
modified version; it is your choice whether to do so, or to make such modified version available under the GNU General Public License 
version 2 without this exception.  You may, if you choose, apply this exception to your own modified versions of Mura CMS.
--->
<cfcomponent extends="mura.cfobject" output="false">
<cfset variables.useMode=true>
<cffunction name="init" output="false" returntype="any">
<cfargument name="useMode" required="true" default="true">
<cfargument name="tempDir" required="true" default="#application.configBean.getTempDir()#">

<cfif findNoCase(server.os.name,"Windows")>
	<cfset variables.useMode=false>
<cfelse>
	<cfif isBoolean(arguments.useMode)>
	<cfset variables.useMode=arguments.useMode>
	<cfelse>
	<cfset variables.useMode=true>
	</cfif>
</cfif>

<cfset variables.tempDir=arguments.tempDir >

<cfif isNumeric(application.configBean.getValue("defaultFileMode"))>
	<cfset variables.defaultFileMode=application.configBean.getValue("defaultFileMode")>
<cfelse>
	<cfset variables.defaultFileMode=775>
</cfif>

<cfreturn this>
</cffunction>

<cffunction name="copyFile" output="false">
<cfargument name="source">
<cfargument name="destination">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfif variables.useMode >
	<cffile action="copy" mode="#arguments.mode#" source="#arguments.source#" destination="#arguments.destination#" />
<cfelse>
	<cffile action="copy" source="#arguments.source#" destination="#arguments.destination#" />
</cfif>
</cffunction>

<cffunction name="moveFile" output="false">
<cfargument name="source">
<cfargument name="destination">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfif variables.useMode >
	<cffile action="copy" mode="#arguments.mode#" source="#arguments.source#" destination="#arguments.destination#" />
    <cffile action="delete" file="#arguments.source#" />
	<!---<cffile action="move" mode="#arguments.mode#" source="#arguments.source#" destination="#arguments.destination#" />--->
<cfelse>
	<cffile action="copy" source="#arguments.source#" destination="#arguments.destination#" />
    <cffile action="delete" file="#arguments.source#" />
	<!---<cffile action="move" source="#arguments.source#" destination="#arguments.destination#" />--->
</cfif>
</cffunction>

<cffunction name="renameFile" output="false">
<cfargument name="source">
<cfargument name="destination">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfif variables.useMode >
	<cffile action="rename" mode="#arguments.mode#" source="#arguments.source#" destination="#arguments.destination#" />
<cfelse>
	<cffile action="rename" source="#arguments.source#" destination="#arguments.destination#" />
</cfif>
</cffunction>

<cffunction name="writeFile" output="true">
	<cfargument name="file">
	<cfargument name="output">
	<cfargument name="addNewLine" required="true" default="true">
	<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
	<cfset var new = "">
	<cfset var x = "">
	<cfset var counter = 0>
	
	<cfif isDefined('arguments.output.mode')>
		<!---<cftry>--->
			<cfset new = FileOpen(arguments.file, "write")>

			<cfloop condition="!fileIsEOF( arguments.output )">
				<cfset x = FileRead(arguments.output, 10000)>
				<cfset FileWrite(new, x)>
				<cfset counter = counter + 1>
			</cfloop>

			<cfset FileClose(arguments.output)>
			<cfset FileClose(new)>
			
			<cfif fileExists(arguments.output.path)>
				<cfset FileDelete(arguments.output.path)>
			<cfelseif fileExists(arguments.output.path & "/" & arguments.output.name)>
				<cfset FileDelete(arguments.output.path & "/" & arguments.output.name)>
			</cfif>
		<!---
			<cfcatch>
				<cfif session.mura.username eq "Admin">
					<cfdump var="#arguments.output#">
					<cfdump var="#counter#">
					<cfdump var="#cfcatch#">
				</cfif>
				<cfabort>
			</cfcatch>
		</cftry--->
	<cfelse>
		<cfif variables.useMode >		
			<cffile action="write" mode="#arguments.mode#" file="#arguments.file#" output="#arguments.output#" addnewline="#arguments.addNewLine#"/>
		<cfelse>
			<cffile action="write" file="#arguments.file#" output="#arguments.output#" addnewline="#arguments.addNewLine#"/>
		</cfif>
	</cfif>
</cffunction>

<cffunction name="uploadFile" output="false">
<cfargument name="filefield">
<cfargument name="destination" required="true" default="#variables.tempDir#">
<cfargument name="nameConflict" required="true" default="makeunique">
<cfargument name="attributes" required="true" default="normal">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfargument name="accept" required="false" default="" />

<cfset touchDir(arguments.destination,arguments.mode) />

<cfif variables.useMode >
	<cffile action="upload"
					fileField="#arguments.fileField#"
					destination="#arguments.destination#"
					nameConflict="#arguments.nameConflict#"
					mode="#arguments.mode#"
					attributes="#arguments.attributes#"
					result="upload"
					accept="#arguments.accept#">
<cfelse>
	<cffile action="upload"
					fileField="#arguments.fileField#"
					destination="#arguments.destination#"
					nameConflict="#arguments.nameConflict#"
					attributes="#arguments.attributes#"
					result="upload"
					accept="#arguments.accept#">
</cfif>
<cfreturn upload>
</cffunction>

<cffunction name="appendFile" output="false">
<cfargument name="file">
<cfargument name="output">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfif variables.useMode >
	<cffile action="append" mode="#arguments.mode#" file="#arguments.file#" output="#arguments.output#"/>
<cfelse>
	<cffile action="append" file="#arguments.file#" output="#arguments.output#" />
</cfif>
</cffunction>

<cffunction name="createDir" output="false">
<cfargument name="directory">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfif variables.useMode >
	<cfdirectory action="create" mode="#arguments.mode#" directory="#arguments.directory#"/>
<cfelse>
	<cfdirectory action="create" directory="#arguments.directory#"/>
</cfif>
</cffunction>

<cffunction name="touchDir" output="false">
<cfargument name="directory">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfif not DirectoryExists(arguments.directory)>
	<cfset createDir(arguments.directory,arguments.mode) />
</cfif>
</cffunction>

<cffunction name="renameDir" output="false">
<cfargument name="directory">
<cfargument name="newDirectory">
<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
<cfif variables.useMode >
	<cfdirectory action="rename" mode="#arguments.mode#" directory="#arguments.directory#" newDirectory="#arguments.newDirectory#"/>
<cfelse>
	<cfdirectory action="rename" directory="#arguments.directory#" newDirectory="#arguments.newDirectory#"/>
</cfif>
</cffunction>

<cffunction name="deleteDir" output="false">
<cfargument name="directory">
<cfargument name="recurse" required="true" default="true">
<cfdirectory action="delete" directory="#arguments.directory#" recurse="#arguments.recurse#"/>
</cffunction>

<cffunction name="copyDir" returnType="any" output="false">
	<cfargument name="baseDir" default="" required="true" />
	<cfargument name="destDir" default="" required="true" />
	<cfargument name="excludeList" default="" required="true" />
	<cfargument name="sinceDate" default="" required="true" />
	<cfargument name="excludeHiddenFiles" default="true" required="true" />
	<cfset getBean("utility").copyDir(argumentCollection=arguments)>
</cffunction>

<cffunction name="getFreeSpace" output="false">
	<cfargument name="file">
	<cfargument name="unit" default="gb">
	<cfset var space=createObject("java", "java.io.File").init(arguments.file).getFreeSpace()>
	
	<cfif arguments.unit eq "bytes">
		<cfreturn space>
	<cfelseif arguments.unit eq "kb">
		<cfreturn space /1024 >
	<cfelseif arguments.unit eq "mb">
		<cfreturn space /1024 / 1024>
	<cfelse>
		<cfreturn space /1024 / 1024 / 1024>
	</cfif>
</cffunction>

<cffunction name="getTotalSpace" output="false">
	<cfargument name="file">
	<cfargument name="unit" default="gb">
	<cfset var space=createObject("java", "java.io.File").init(arguments.file).getTotalSpace()>
	
	<cfif arguments.unit eq "byte">
		<cfreturn space>
	<cfelseif arguments.unit eq "kb">
		<cfreturn space /1024 >
	<cfelseif arguments.unit eq "mb">
		<cfreturn space /1024 / 1024>
	<cfelse>
		<cfreturn space /1024 / 1024 / 1024>
	</cfif>
</cffunction>

<cffunction name="getUsableSpace" output="false">
	<cfargument name="file">
	<cfargument name="unit" default="gb">
	<cfset var space=createObject("java", "java.io.File").init(arguments.file).getUsableSpace()>
	
	<cfif arguments.unit eq "byte">
		<cfreturn space>
	<cfelseif arguments.unit eq "kb">
		<cfreturn space /1024 >
	<cfelseif arguments.unit eq "mb">
		<cfreturn space /1024 / 1024>
	<cfelse>
		<cfreturn space /1024 / 1024 / 1024>
	</cfif>
</cffunction>

<cffunction name="chmod" output="false">
	<cfargument name="path">
	<cfargument name="mode" required="true" default="#variables.defaultFileMode#">
	
	<cfif variables.useMode>
		<cftry>
		<cfif directoryExists(arguments.path)>
			<cfset createObject("java","java.lang.Runtime").getRuntime().exec("chmod -R #arguments.mode# #arguments.path#")>
		<cfelse>
			<cfset createObject("java","java.lang.Runtime").getRuntime().exec("chmod #arguments.mode# #arguments.path#")>
		</cfif>
		<cfcatch></cfcatch>
		</cftry>
	</cfif>
</cffunction>

</cfcomponent>