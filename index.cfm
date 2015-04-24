<!DOCTYPE html>
<html lang="en">
    <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>LeSMEx: Legacy Site Map Extractor</title>

    <!-- Bootstrap -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
    <style>
body {
	margin-left: 40px;
	margin-top:40px;
}
.width300 {
	width: 300px;
}
.width500 {
	width: 500px;
}
.mheight200 {
	min-height: 200px;
}
textarea { width:500px; height:500px;}

}
</style>
    </head>
    <body>
<cfinclude template="inc_config.cfm">    
<cfinclude template="inc_functions_template.cfm">



<!--- PROCESS BASED ON SUBMITTED FORM --->

<cfif isDefined('form.courses_list_choice')>
    
   
	<cfif isDefined('form.toggle_base_process')>
    	<cfset bool_base_process = true>
    <cfelse> 
    	<cfset bool_base_process = false>
    </cfif>
    
    <cfif isDefined('form.toggle_url_concatlist')>
    	<cfset bool_url_concatlist = true>
    <cfelse>
    	<cfset bool_url_concatlist = false>
    </cfif>
    
    
    <cfif isDefined('form.toggle_url_concatlist')>
    	<cfset stringout = modulesFilesPathList(ftp_username,ftp_password,ftp_server,form.courses_list_choice,form.url_concatlist_prepend_path,LCase(onlyTheseFolders(form)))>
    
    <cfelse>
    
    	<cfset modulesFilesStruct = getModulesFiles(ftp_username,ftp_password,ftp_server,form.courses_list_choice_path,bool_base_process,LCase(onlyTheseFolders(form)))> 
		<cfset stringOut = getSiteMapXML(modulesFilesStruct,bool_base_process)> 
    </cfif>
	
    

</cfif>







<cfset courses_qrs = showCourses(ftp_username,ftp_password,ftp_server)>



<p>
<img src="img/lesmex_logo_ol.png">
<br>
    <em>What it does: finds the html files in the root folder of each module for the selected course and creates a Course Framework 4.x Site Map. </em><br>
</p>
<hr>
<p class="help-block">Directions: Select the Course Folder from which you want to extract a CF4 Site Map</p>

<hr>
<form role="form" method="post" action="index.cfm">
        <div class="form-group">
        <label>Select Course</label>
        <p class="help-block small">Select course based on Educator folder name</p>
        <select name="courses_list_choice" class="form-control width300" id="id_courses_list_choice">
        		<cfif isDefined('form.courses_list_choice')>
                <cfoutput><option selected="selected">#form.courses_list_choice#</option></cfoutput>
                </cfif>
			<cfoutput query="courses_qrs">
				
                <option>#name#</option>
			</cfoutput>
        </select>
        
        <input type="hidden" id="courses_list_choice_path_id" name="courses_list_choice_path"/>
        
       
    </div>
        <div id="id_course_folder_checkboxes"></div>
        <hr>
        <h4>&nbsp;</h4>
        <div class="form-group"> </div>
        <button id="id_submit_but" type="submit" class="btn btn-primary">Process!</button> &nbsp;&nbsp; <a class="btn btn-warning" href="javascript:void(0);" onclick="window.location.reload();">START OVER</a><br>
        <input type="checkbox" name="toggle_base_process" id="id_toggle_base_process"/> Ignore File Naming Convention (sitemap w/o lessons)<br>
         <input type="checkbox" name="toggle_url_concatlist" id="id_toggle_url_concatlist"/> Create html page list with prepended url path<br>
         <span id="id_concatlist_prepend_path_container" style="display:none;"> 
         	URL Prepend Path: <input class="width500" type="text" name="url_concatlist_prepend_path" id="id_concatlist_prepend_path" placeholder="http://domain.com/path/to/page/"/>
         </span>
         
         
        
        <cfif isDefined('form.courses_list_choice')>
        	<textarea class="form-control width500 mheight200" id="id_sitemap" name="sitemap"><cfoutput>#HTMLEditFormat(stringOut)#</cfoutput></textarea>
        </cfif>
            </form>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) --> 
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> 
<!-- Include all compiled plugins (below), or include individual files as needed --> 
<script src="js/bootstrap.min.js"></script> 


<script src="js/LeSMEx.js" type="text/javascript"></script>



</body>
</html>