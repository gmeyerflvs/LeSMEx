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

<hr><hr>
<form role="form" method="post" action="index.cfm">
        <div class="form-group">
        <label>Select Course</label>
        
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
        <button id="id_submit_but" type="submit" class="btn btn-default">Process!</button> <br>
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


<script>
var courseSubdir = "";
$(document).ready(function() {
	var base_process = $('#id_toggle_base_process');
	var url_concatlist = $('#id_toggle_url_concatlist');
	var prepend_path_container = $('#id_concatlist_prepend_path_container');
	
	base_process.click(function(){
		url_concatlist.prop( "checked", false );
		prepend_path_container.hide();
		
	});
	url_concatlist.click(function(){
		base_process.prop( "checked", false );
		if(url_concatlist.prop("checked")){
				prepend_path_container.show();
		}else{
			prepend_path_container.hide();
		}
	});
	
	
	$('#id_courses_list_choice').change(function(){
		
		var selectVal = $(this).val();
		getCourseFoldersJSON(selectVal + (courseSubdir !== '' ? '/' + courseSubdir:''));
		//reset courseSubdir value for next select box update
		$('#courses_list_choice_path_id').val(selectVal + (courseSubdir !== '' ? '/' + courseSubdir:''));
		courseSubdir = "";
	});
});

var getCourseFoldersJSON = function(course_dir){ console.log('passed course_dir into getCourseFoldersJSON:' + course_dir);
	$.getJSON( "ajax_list_course_folders.cfm?course_dir=" + course_dir, function( data ) {
	  //alert(data.DATA.NAME);
	  var items = [];
	  var checkedval = '';
	  var truncPath = '';
	  items.push("<label>Select Module Folders</label><br/>");
	  $.each( data.DATA.NAME, function( key, val ) {
		//truncPath = remFirstFolderInPath(course_dir + '/' + val);
		if(val.indexOf('module') >= 0){ checkedval = " checked";} else { checkedval = '';}
		items.push( "<input type='checkbox' name='modules_" + val + "'/> " + course_dir + "/" + val + "&nbsp;&nbsp;&nbsp;&nbsp;<a href='javascript:void(0);' onclick='courseSubdirCall(\""+ val +"\")'><--- find module folders here</a><br/>" );
	  });
	 
	  $('#id_course_folder_checkboxes').html(items.join( "\n" ));
	  
	});
	
}

var courseSubdirCall = function(course_subdir){
	courseSubdir = course_subdir;
	$('#id_courses_list_choice').change();
}

var remFirstFolderInPath = function(fPath){
	var pathArr = fPath.split('/');
	pathArr.shift();
	console.log('remFirstFolderInPath = ' + pathArr.join('/'));
	return pathArr.join('/');
}

</script>
</body>
</html>