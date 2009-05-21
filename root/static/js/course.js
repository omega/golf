$(document).ready(function() {
    console.log("in ready");
    $('#new_hole').keypress(function(e) {
        console.log(e.which);
        if (e.which == 13) {
            
            if ($(this).val() == '')
                return false;
                
            // Need to take the value of this and create a new
            // input before this one, and 
            var count = $('.holes input').size();
            var label = $(this).parent().clone();

            label.contents().filter('span').text('Hole #' + count);
            label.contents().filter('input').attr('id', null);
            label.contents().filter('input').attr('name', 'holes');
            label.attr('for', null);
            label.insertBefore( $(this).parent() );
            // our new hole is hole #count
            $(this).val('').focus();
            
            return false;
        }
    });
    
});