$ -> $('.date').datepicker({changeMonth: true; changeYear: true})
$ ->
    $('#student_chk').click ->
        if $('#student_info').is(":hidden")
            $('#student_info').show('blind', 1000);
        else
            $('#student_info').hide('blind', 1000);
