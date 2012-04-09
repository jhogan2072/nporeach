$ ->
  $('img[id*="remove_help"]').click (event) ->
    help_id = event.target.id.split("_")[2];
    alert(help_id);
