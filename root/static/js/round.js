$(document).ready(function() {
    $('#date').datepicker({
        'dateFormat': 'yy-mm-dd',
        'showButtonPanel': true
    });
    
    $('#course').change(function() {
        var size = $(this).children('option:selected').attr('data:size');
        var c_size = $('.scores tr').size() - 1;
        
        var p_size = $('.scores th').size() - 1;

        var delta = size - c_size;

        if (delta == 0)
            return;
        else if (delta > 0) {
            // add holes
            var ptd = '<td>__HOLE__</td>';
            if (p_size) {
                // generate a "template" in ptd
                ptd = $('.scores tr:eq(1)').html().replace(/1/g, '__HOLE__', 'g');
            }
            for (var j = 1; j <= delta; j++) {
                $('.scores tr:last').after('<tr>' 
                    +  ptd.replace(/__HOLE__/g, j + c_size, 'g')
                + '</tr>');  
            }
        } else {
            // remove holes
            $('.scores tr:gt(' + size + ')').remove();
        }
        $('.scores tr').map(function(i) {
            if (c_size == 0 && i == c_size) {
                // need to add size - c_size more holes
            }
        });
    });
    $('#course').change();
    $('.players input[type="checkbox"]').change(function() {
        var pid = $(this).val();
        if (this.checked) {
            // clone the whole row of holes
            $('.scores tr').map(function(i, elem) {
                if (i == 0) {
                    // Add a TH with the pid
                    $(this).append( '<th id="ph_' + pid + '">' + pid + '</th>');
                } else {
                    $(this).append( '<td><input type="text" name="' + i + '_' + pid + '"/ ></td>');
                }
            });
        } else {
            // Remove a colum, this gets a bit trickier
            var idx = 0;
            $('.scores th').map( function(i, elem) {
                if (elem.id == "ph_" + pid)
                    idx = i;
            });
            
            $('.scores tr').map(function(i, dom) {
                $(this).children('*:eq(' + idx + ')').remove();
            });
        }
    });
});