use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Golf' }
BEGIN { use_ok 'Golf::Controller::Round' }

ok( request('/round')->is_success, 'Request should succeed' );


