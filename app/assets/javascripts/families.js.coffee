# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $('#is_individual').click ->
        if ($('#is_individual').attr('checked'))
            $('#last_name').val($('#family_name').val())
    $('#family_name').change ->
        if !($('#mailing_greeting').val())
            $('#mailing_greeting').val('The ' + $('#family_name').val() + ' Family')
    $('#toggle_contact').click ->
        if $('#contact_info').is(":hidden")
            $('#contact_info').show('blind', 1000);
        else 
            $('#contact_info').hide('blind', 1000);
    $('#menu_icon').click ->
        if $('#sliding_menu').is(":hidden")
            $('#sliding_menu').show('slide', 500);
        else
            $('#sliding_menu').hide('slide', 500);
