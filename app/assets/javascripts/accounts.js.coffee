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
$ ->
    $("#my_links tbody").sortable({
        stop: ->
            $('#submit_button').show('blind');
    });
    $("#my_links tbody").disableSelection();