// To be included only where needed, currently tag_wranglings/index and tags/wrangle

$(document).ready(function(){
  $("#wrangle_all_select").click(function() {
    $("#wrangulator").find(":checkbox[name='selected_tags[]']").each(function(index, ticky) {
        $(ticky).prop("checked", true);
      });
  });
  $("#wrangle_all_deselect").click(function() {
    $("#wrangulator").find(":checkbox[name='selected_tags[]']").each(function(index, ticky) {
        $(ticky).prop("checked", false);
      });
  });
  $("#canonize_all_select").click(function() {
    $("#wrangulator").find(":checkbox[name='canonicals[]']").each(function(index, ticky) {
        $(ticky).prop("checked", true);
      });
  });
  $("#canonize_all_deselect").click(function() {
    $("#wrangulator").find(":checkbox[name='canonicals[]']").each(function(index, ticky) {
        $(ticky).prop("checked", false);
      });
  });
})
