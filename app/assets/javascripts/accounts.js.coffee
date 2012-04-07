$(document).ready ->
  $dialog = $('#help_message')
    .dialog({
      autoOpen: false,
      title: 'Managing Favorites',
      show: 'clip',
      width: 600
    });
    $('#help_icon').click ->
      $dialog.dialog('open');
      return false;
    $(".remove_link").click ->
      $(this).parent().parent().hide();
      $("user_user_preferences_attributes_" + 1 + "__destroy").prop("checked", true);
      #$(this).siblings().parent().remove();
      if $('#submit_button').is(":hidden") then $('#submit_button').show('blind');
      result = $('#my_links tbody').sortable('toArray');
      setImageSortOrder(result);


setImageSortOrder = (sortOrder) ->
  for token,i in sortOrder
    $("#user_user_preferences_attributes_" + token.split("row")[1] + "_seq_no").val(i)

$ ->
  $("#my_links tbody").sortable({
    stop: ->
      if $('#submit_button').is(":hidden") then $('#submit_button').show('blind');
      result = $('#my_links tbody').sortable('toArray');
      setImageSortOrder(result);
    });
  $("#my_links tbody").disableSelection();