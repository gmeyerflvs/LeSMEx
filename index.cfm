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
</style>
    </head>
    <body>
<cfinclude template="inc_config.cfm">    
<cfinclude template="inc_functions.cfm">



<!--- PROCESS BASED ON SUBMITTED FORM --->

<cfif isDefined('form.courses_list_choice')>
    
    <cfset modulesFilesStruct = getModulesFiles(ftp_username,ftp_password,ftp_server,form.courses_list_choice)>  <!--- educator_econ_v9_gs_e11 --->
    
    <!---  <cfdump var="#modulesFilesStruct#">--->
    
    <!---  --->
    <cfset xmlOut = getSiteMapXML(modulesFilesStruct)>

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
        
        <select name="courses_list_choice" class="form-control width300">
        	<cfoutput query="courses_qrs">
				<option>#name#</option>
			</cfoutput>
        </select>
       
    </div>
        <hr>
        <h4>&nbsp;</h4>
        <div class="form-group"> </div>
        <button id="id_submit_but" type="submit" class="btn btn-default">Process!</button>
        
        <cfif isDefined('form.courses_list_choice')>
        	<textarea class="form-control width500 mheight200" id="id_sitemap" name="sitemap"><cfoutput>#HTMLEditFormat(xmlOut)#</cfoutput></textarea>
        </cfif>
            </form>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) --> 
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script> 
<!-- Include all compiled plugins (below), or include individual files as needed --> 
<script src="js/bootstrap.min.js"></script> 

</body>
</html>