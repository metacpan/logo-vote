use strict;
use warnings;
use Test::More;


use Catalyst::Test 'MetaCPAN::Contest::Vote';
use MetaCPAN::Contest::Vote::Controller::Vote;

ok( request('/vote')->is_success, 'Request should succeed' );
done_testing();
