  function getLastTimeEntryDate() {
    if ($('.spent_on').size() > 0) {
      return $('.spent_on').last().val();
    } else {
      return null;
    } 
  }

$(function() {
  
  $("select[data-project-selector]").live('change',function() {
    var entry_id = $(this).data('project-selector');
    var project_id = this.value;

    $.ajax({
      url: "/bulk_time_entries/load_assigned_issues",
      type:'post',
      data: { 'project_id':project_id, 'entry_id': entry_id }
      }
    )
    .error(function(xhr, ajaxOptions, data){console.error("Error while get issues: "); console.debug(data);});
  });
  
  $("a#add_entry").click(function(evt){
    evt.preventDefault();
    var d = getLastTimeEntryDate();
    $.ajax({
	url: "/bulk_time_entries/add_entry",
	type: 'post',
	data: { 'date': d },
	error:function(datda,object){
	    console.debug("error while get new entry");
	    console.debug(data);
	},
	complete : function(){
	    $('html, body').animate({
		scrollTop: $("div#entries .box:last").offset().top
	    }, 300);
	}
    });
  });
});
