# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $("#privilege_controller").change ->
        controller = $('select#privilege_controller :selected').val();
        $.ajax '/admin/privileges/update_actions'
         type: 'POST'
         data: 'name=' + controller
         datatype: 'text'
         success: (data) ->
            $("#privilege_actions").html(data);