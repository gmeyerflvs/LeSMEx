
<!--- Return qrs of Educator courses that contain '_gs_' in the folder name --->
<cffunction name="showCourses" output="false" returntype="query">
<cfargument name="u" type="string">
<cfargument name="p" type="string">
<cfargument name="s" type="string">

    <cfftp action = "open" 
        username = "#arguments.u#" 
        connection = "ftpc" 
        password = "#arguments.p#" 
        server = "#arguments.s#" 
        stopOnError = "Yes"> 
        
    <cfftp action = "LISTDIR" 
        stopOnError = "Yes" 
        name = "ListFiles" 
        directory = "/" 
        connection = "ftpc">
        
    <cfftp action = "close" 
    connection = "ftpc" 
    stopOnError = "Yes">     
      
    <cfquery dbtype="query" name="courses_qrs">
        SELECT * FROM ListFiles
        WHERE IsDirectory = 'YES'
        AND name LIKE '%_gs%'
    </cfquery>  
              
<cfreturn courses_qrs>
</cffunction>


<!--- Returns struct with each module folder and query results of elegible files for processing--->
<cffunction name="getModulesFiles" output="no" returntype="struct">
<cfargument name="u" type="string">
<cfargument name="p" type="string">
<cfargument name="s" type="string">
<cfargument name="dir" type="string">

    <cfset returnStruct = structNew()>
    
    <cfftp action = "open" 
        username = "#arguments.u#" 
        connection = "ftpc" 
        password = "#arguments.p#" 
        server = "#arguments.s#" 
        stopOnError = "Yes"> 
        
    <cfftp action = "LISTDIR" 
        stopOnError = "Yes" 
        name = "ListFiles" 
        directory = "/#arguments.dir#" 
        connection = "ftpc">
        
    <!--- get folders with word 'module' in them --->    
    <cfquery dbtype="query" name="html_qrs">
        SELECT * FROM ListFiles
        WHERE IsDirectory = 'YES'
        AND name LIKE '%module%'
        ORDER BY path
    </cfquery>
    
    <cfset arrCt = 1>
    <cfloop query="html_qrs">
    	<cfset lessonsArr = arrayNew(1)>
        
        <cfftp action = "LISTDIR" 
        stopOnError = "Yes" 
        name = "modfiles_qrs" 
        directory = "#html_qrs.path#" 
        connection = "ftpc">
        
        <!--- get and sort files that end with htm or html ---> 
        <cfquery dbtype="query" name="html_qrs2">
            SELECT name,path FROM modfiles_qrs
            WHERE IsDirectory = 'NO'
            AND name LIKE '%.htm%'
            AND name NOT LIKE '%.LCK'
            order by path
        </cfquery>
        
        <cfset lessonsArr = queryToLessonsArr(html_qrs2)>
        
        <!--- <cfdump var="#lessonsArr#"> --->
		<cfset m = getMLP(html_qrs2.name,1)>
                
       <cfset returnStruct[html_qrs.name] = lessonsArr>
        <cfset arrCt++>
    </cfloop>
    
    
      
    <cfftp action = "close" 
    connection = "ftpc" 
    stopOnError = "Yes"> 

              
<cfreturn returnStruct>
</cffunction>


<!--- convert query containing all lessons into an array containing grouped lesson queries --->
<cffunction name="queryToLessonsArr" output="no" returntype="array">
<cfargument name="qrs" type="query" required="yes">

	<cfset returnArr = arrayNew(1)>
    
    <cfset lessonHolder = getMLP(arguments.qrs.name,2)>
    
    <cfset tempQRS = queryNew('name,path')>
    
    <cfloop query="arguments.qrs">
        <cfif getMLP(arguments.qrs.name,2) NEQ lessonHolder>
            <cfset lessonHolder = getMLP(arguments.qrs.name,2)>
            <cfset arrayAppend(returnArr,tempQRS)>
            <cfset tempQRS = queryNew('name,path')>
        </cfif>
        <cfset queryAddRow(tempQRS)>
        <cfset querySetCell(tempQRS,'name',arguments.qrs.name)><!--- NAME --->
        <cfset querySetCell(tempQRS,'path',arguments.qrs.path)><!--- PATH --->
        
        
    </cfloop>
    <cfset arrayAppend(returnArr,tempQRS)>
    <!--- <cfdump var="#returnArr#"> --->

<cfreturn returnArr>
</cffunction>


<!--- Create XML output --->
<cffunction name="getSiteMapXML" output="yes" returntype="string">
<cfargument name="modulesFilesStruct" type="struct" required="yes">

<cfset tb1 = "     ">
<cfset tb2 = tb1 & tb1>
<cfset tb3 = tb1 & tb1 & tb1>
<cfset stringArr = arrayNew(1)>

<cfset arrayAppend(stringArr,'<?xml version="1.0" encoding="utf-8"?>')>
<cfset arrayAppend(stringArr,'<sitemap>')>

<cfloop collection="#arguments.modulesFilesStruct#" item="m">
	<cfset arrayAppend(stringArr, tb1 & '<module  title="#m#" visible="true" indexpage="false" icon="" bg="">')>
    	<cfset lessonArr = arguments.modulesFilesStruct[m]>
        
        <cfset lcount = 0>
    	<cfloop from="1" to="#arrayLen(lessonArr)#" index="i">
        		<cfset qrs = lessonArr[i]>
				<cfset arrayAppend(stringArr,tb2 & '<lesson title="Lesson #lcount#" num="#getModNumFromPage(qrs.name)#.#get2Dig(lcount)#" time="45" points="1">')>
            	
                <cfset pcount = 1>
                <cfloop query="qrs">
                	<cfset arrayAppend(stringArr,tb3 & '<page href="../#m#/#qrs.name#" title="Page #get2Dig(lcount)#.#get2Dig(pcount)#"/>')>
                	<cfset pcount++>
                </cfloop>
            <cfset arrayAppend(stringArr,tb2 & '</lesson>')>
            <cfset lcount++>
        </cfloop>
    
    <cfset arrayAppend(stringArr,tb1 & '</module>')>
</cfloop> 

<cfset arrayAppend(stringArr,'</sitemap>')>

<cfreturn arrayToList(stringArr,chr(10))>
</cffunction>


<!--- Return either module, lesson or page --->
<cffunction name="getMLP" output="no" returntype="string">
<cfargument name="filename" required="yes" type="string">
<cfargument name="position" required="yes" type="numeric"><!---  1 = module, 2 = lesson, 3 = page--->

	<cfset rawTempArr = listToArray(arguments.filename,'_',false)>
    <cfset tempArr = arrayNew(1)>
    <cfloop from="1" to="#arraylen(rawTempArr)#" index="i">
        <cfset tempArr[i] = left(rawTempArr[i],2)>
    </cfloop>


<cfreturn tempArr[position]>
</cffunction>

<!--- Return module.lesson for lesson num attribute --->
<cffunction name="getModLessNum" output="no" returntype="string">
<cfargument name="filename" required="yes" type="string">

	<cfset rawTempArr = listToArray(arguments.filename,'_',false)>
    <cfset returnString = arrayNew(1)>
    <cfloop from="1" to="#arraylen(rawTempArr)#" index="i">
        <cfset tempArr[i] = left(rawTempArr[i],2)>
    </cfloop>
    <cfset returnString = right(tempArr[1],1) & "." & tempArr[2]>


<cfreturn returnString>
</cffunction>

<!--- Return module from page name  --->
<cffunction name="getModNumFromPage" output="no" returntype="string">
<cfargument name="filename" required="yes" type="string">

	<cfset rawTempArr = listToArray(arguments.filename,'_',false)>
    <cfset returnString = arrayNew(1)>
    <cfloop from="1" to="#arraylen(rawTempArr)#" index="i">
        <cfset tempArr[i] = left(rawTempArr[i],2)>
    </cfloop>
    <cfset returnString = right(tempArr[1],1)>


<cfreturn returnString>
</cffunction>

<!--- Return number as string with 2 placeholders: e.g. returns '01' but 10 returns '10' --->
<cffunction name="get2Dig" output="no" returntype="string">
<cfargument name="num" required="yes" type="numeric">

<cfset s = toString(arguments.num)>
<cfif len(s) LT 2>
	<cfset returnStr = '0' & s>
<cfelse>
	<cfset returnStr = s>
</cfif>
<cfreturn returnStr>
</cffunction>


