$(document).ready ->
    $(".remove_child_menu_item").click ->
        $(this).parent().parent().find('input[name*="_destroy"]').val(1);
        $(this).parent().parent().hide(500);
