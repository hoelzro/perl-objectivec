use strict;
use warnings;

use Test::More;

if($^O eq 'darwin') {
    plan tests => 2;
} else {
    plan skip_all => 'You need to be running Mac OS X to test framework loading!';
}

use ObjectiveC;

ok(! ObjectiveC->get_class('NSString'));

ObjectiveC->load_framework('Foundation');

ok(ObjectiveC->get_class('NSString'));
