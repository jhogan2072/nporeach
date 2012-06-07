$ -> $('.date').datepicker({changeMonth: true; changeYear: true; yearRange: "1960:2010"})
$ ->
    $('#student_chk').click ->
        $('#student_info').toggle('blind', 1000);
    $('#toggle_contact').click ->
        $('#contact_info').toggle('blind', 500);
