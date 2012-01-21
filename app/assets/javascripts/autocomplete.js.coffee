# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
         $('#account_owner_full_name').autocomplete
                 source: "/autocomplete/users"
                 select: (event,ui) -> $("#account_owner_id").val(ui.item.id)