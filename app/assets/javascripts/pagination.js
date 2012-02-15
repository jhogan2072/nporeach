//use ajax to paginate lists
$('.pagination a').live('click', function () {
    $.rails.handleRemote($(this));
    return false;
});