// Expands a group of filters options if one of that type is selected
$(document).ready(function() {
  showFilters();
  setupNarrowScreenFilters();
});

function showFilters() {
  var filters = $('dd.tags');

  filters.each(function(index, filter) {
    var tags = $(filter).find('input');
    var node = $(filter);
    var open_toggles = $('.' + node.attr('id') + "_open");
    var close_toggles = $('.' + node.attr('id') + "_close");

    tags.each(function(index, tag) {
      if($(tag).is(':checked')) {
        $(filter).show();
        $(open_toggles).hide();
        $(close_toggles).show();
      } //is checked
    }); //tags each
  }); //filters each 
} //showfilters

function setupNarrowScreenFilters() {
  var filters = $('form.filters');
  var outer = $('#outer');
  var show_link = $('#go_to_filters');
  var hide_link = $('#leave_filters');

  show_link.click(function(e) {
    e.preventDefault();
    filters.removeClass('narrow-hidden');
    outer.addClass('filtering');
    filters.find(':focusable').first().focus();
    filters.trap();
  });

  hide_link.click(function(e) {
    e.preventDefault();
    outer.removeClass('filtering');
    filters.addClass('narrow-hidden');
    show_link.focus();
  });
}
