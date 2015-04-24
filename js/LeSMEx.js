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
		//console.log('change triggered on select box...');
		var selectVal = $(this).val();
		getCourseFoldersJSON(selectVal + (courseSubdir !== '' ? '/' + courseSubdir:''));
		//reset courseSubdir value for next select box update
		$('#courses_list_choice_path_id').val(selectVal + (courseSubdir !== '' ? '/' + courseSubdir:''));
		courseSubdir = "";
	});
});

var getCourseFoldersJSON = function(course_dir){ 
	//console.log('passed course_dir into getCourseFoldersJSON:' + course_dir);
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
	//console.log('remFirstFolderInPath = ' + pathArr.join('/'));
	return pathArr.join('/');
}