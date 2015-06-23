<!DOCTYPE html>
<html lang="en">
    <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Course Framework Identifier</title>

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

<cfsetting requestTimeOut = "1000000000000000" >




<cfset courses_qrs = showCourses(ftp_username,ftp_password,ftp_server)>



<p>

    <em>What it does: looks in all the educator course folders, finds out which framework is being used. </em><br>
</p>
<style>
table td {1px solid charcoal; border-collapse:collapse; padding:8px;}
</style>

<hr>
<table class="table-bordered">
<cfoutput query="courses_qrs">
<cftry>
<cfset courseInfoStruct = courseFolderFWinfo(ftp_username,ftp_password,ftp_server,path)>
<tr>
<td>Course Folder:</td><td>#name#</td><td>Version:</td><td>
<cfif returnStruct.isFramework>
	<cfif returnStruct.FW_version NEQ false>
    #returnStruct.FW_version#
    <cfelse>
    FW 1.x
    </cfif>
<cfelse>
	NONE
</cfif>
</td>

</tr>
<cfcatch type="any">Course Folder:#name#</cfcatch>
</cftry>
<cfflush> 
</cfoutput>
</table>






</body>
</html>