
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
        AND name NOT LIKE '%Documents%'
    </cfquery>  
              
<cfreturn courses_qrs>
</cffunction>

<!--- Return qrs of Educator course folder names --->
<cffunction name="showCourseFolders" output="false" returntype="string">
<cfargument name="u" type="string">
<cfargument name="p" type="string">
<cfargument name="s" type="string">
<cfargument name="dir" type="string">

    <cfftp action = "open" 
        username = "#arguments.u#" 
        connection = "ftpc" 
        password = "#arguments.p#" 
        server = "#arguments.s#" 
        stopOnError = "Yes"> 
        
    <cfftp action = "LISTDIR" 
        stopOnError = "Yes" 
        name = "ListFiles" 
        directory = "#arguments.dir#" 
        connection = "ftpc">
        
    <cfftp action = "close" 
    connection = "ftpc" 
    stopOnError = "Yes">     
      
    <cfquery dbtype="query" name="course_folders_qrs">
        SELECT * FROM ListFiles
        WHERE IsDirectory = 'YES'
        AND name NOT LIKE 'docs'
        AND name NOT LIKE 'image'
        AND name NOT LIKE 'images'
        AND name NOT LIKE 'swf'
        AND name NOT LIKE 'flash'
        AND name NOT LIKE 'glossary'
        AND name NOT LIKE 'media'
        AND name NOT LIKE '_notes'
        AND name NOT LIKE 'welcome_%'
        AND name NOT LIKE '%java%'
        AND name NOT LIKE 'imgs'
        AND name NOT LIKE 'global'
        AND name NOT LIKE 'Library'
        AND name NOT LIKE 'Scripts'
        AND name NOT LIKE 'scripts'
        AND name NOT LIKE 'Templates'
        AND name NOT LIKE 'source'
        AND name NOT LIKE 'style'
        AND name NOT LIKE 'styles'
        AND name NOT LIKE 'cheatsheet'
        AND name NOT LIKE 'gendocs'
        AND name NOT LIKE 'genimage'
        AND name NOT LIKE 'genimages'
    </cfquery>  
              
<cfreturn SerializeJSON(course_folders_qrs,true)>
</cffunction>


<!--- Returns a query WHERE IN statement from selected folder name checkboxes --->
<cffunction name="onlyTheseFolders" output="true" returntype="string">
<cfargument name="f" type="struct" required="yes">

    <cfset outputStatement = "AND name IN (">
    <cfset ct = structCount(arguments.f)>
    <cfset tempArr = arrayNew(1)>
    <cfloop collection="#arguments.f#" item="i">
    	<cfif i CONTAINS "modules_">
        	<cfset arrayAppend(tempArr,"'" & removechars(i,1,8) & "'")>
        </cfif>
    </cfloop>
    <cfset outputStatement &= arrayToList(tempArr,',')>  
    <cfset outputStatement &= ")"> 
    <cfif NOT arrayLen(tempArr)>
    	<cfset outputStatement = "">
    </cfif> 
             
<cfreturn outputStatement>
</cffunction>
  
        
<!--- Returns string list of html files with prepended paths concatenated with resulting html page names --->
<cffunction name="modulesFilesPathList" output="no" returntype="string">
<cfargument name="u" type="string">
<cfargument name="p" type="string">
<cfargument name="s" type="string">
<cfargument name="dir" type="string">
<cfargument name="url_concatlist_prepend_path" type="string" required="no" default="">
<cfargument name="only_these_folders" type="string" required="no" default="">


    <cfset returnStr = "">
    
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
        <cfif arguments.only_these_folders NEQ ''>AND name LIKE '%module%'<cfelse>#arguments.only_these_folders#</cfif>
        ORDER BY path
    </cfquery>
    
    <cfset arrCt = 1>
    <cfloop query="html_qrs">
        
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
        
        <cfloop query="html_qrs2">
        	<cfset module = listGetAt(html_qrs2.path,listlen(html_qrs2.path,'/') -1,'/')>
			
			<cfset returnStr &= arguments.url_concatlist_prepend_path & module & '/' & html_qrs2.name & chr(10)>
        </cfloop>
        
        <cfset arrCt++>
    </cfloop>
    
    
      
    <cfftp action = "close" 
    connection = "ftpc" 
    stopOnError = "Yes"> 

              
<cfreturn returnStr>
</cffunction>


<!--- Returns struct with each module folder and query results of elegible files for processing--->
<cffunction name="getModulesFiles" output="no" returntype="struct">
<cfargument name="u" type="string">
<cfargument name="p" type="string">
<cfargument name="s" type="string">
<cfargument name="dir" type="string">
<cfargument name="bool_base_process" type="boolean" required="no" default="false">
<cfargument name="only_these_folders" type="string" required="no" default="">

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
        <cfif arguments.only_these_folders NEQ ''>AND name LIKE '%module%'<cfelse>#arguments.only_these_folders#</cfif>
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
        
        <cfif arguments.bool_base_process>
        	<cfset lessonsArr = arrayNew(1)>
            <cfset lessonsArr[1] = html_qrs2>
        <cfelse>
        	<cfset lessonsArr = queryToLessonsArr(html_qrs2)>
        </cfif>
        
        
        <!--- <cfdump var="#lessonsArr#"> --->
		<cfset m = getMLP(html_qrs2.name,1)>
                
       <cfset returnStruct[html_qrs.name] = lessonsArr>
        <cfset arrCt++>
    </cfloop>
    
    
      
    <cfftp action = "close" 
    connection = "ftpc" 
    stopOnError = "Yes"> 

<!--- <cfdump var="#returnStruct#"><cfabort> --->
              
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
<cfargument name="bool_base_process" type="boolean" required="no" default="false">

<cfset tb1 = "     ">
<cfset tb2 = tb1 & tb1>
<cfset tb3 = tb1 & tb1 & tb1>
<cfset stringArr = arrayNew(1)>

<cfset arrayAppend(stringArr,'<?xml version="1.0" encoding="utf-8"?>')>
<cfset arrayAppend(stringArr,'<sitemap>')>



<cfloop list="#ListSort(StructKeyList(arguments.modulesFilesStruct,','), "text", "ASC")#" index="m">
	<cfset arrayAppend(stringArr, tb1 & '<module title="#m#" visible="true" indexpage="false" icon="" bg="">')>
    	
			<cfset lessonArr = arguments.modulesFilesStruct[m]>
            
            <cfset lcount = 0>
            <cfif arguments.bool_base_process>
            	<cfloop from="1" to="#arrayLen(lessonArr)#" index="i">
                        <cfset qrs = lessonArr[i]>
                        <cfset pcount = 1>
                        <cfloop query="qrs">
                            <cfset arrayAppend(stringArr,tb3 & '<page href="../#m#/#qrs.name#" title="??.??: Page #pcount#"/>')>
                            <cfset pcount++>
                        </cfloop>
                    
                    <cfset lcount++>
                </cfloop>
            <cfelse>
                <cfloop from="1" to="#arrayLen(lessonArr)#" index="i">
                        <cfset qrs = lessonArr[i]>
                        <cfset moduleDigits = getModNumFromPage(qrs.name)>
                        <cfset arrayAppend(stringArr,tb2 & '<lesson title="#get2Dig(moduleDigits)#.#get2Dig(lcount)# " num="#moduleDigits#.#get2Dig(lcount)#" time="45" points="1">')>
                        
                        <cfset pcount = 1>
                        <cfloop query="qrs">
                            <cfset arrayAppend(stringArr,tb3 & '<page href="../#m#/#qrs.name#" title="#get2Dig(moduleDigits)#.#get2Dig(lcount)#: Page #pcount#"/>')>
                            <cfset pcount++>
                        </cfloop>
                    <cfset arrayAppend(stringArr,tb2 & '</lesson>')>
                    <cfset lcount++>
                </cfloop>
    	 	</cfif>
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


