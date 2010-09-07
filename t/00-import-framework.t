use strict;
use warnings;

use Test::More;
use Test::Exception;

if($^O eq 'darwin') {
    plan tests => 3;
} else {
    plan skip_all => 'You need to be running Mac OS X to test framework loading!';
}

use ObjectiveC;

dies_ok {
    ObjectiveC->get_class('NSString');
};

ObjectiveC->import(qw/:framework Foundation/);

ok(ObjectiveC->get_class('NSString'));

dies_ok {
    ObjectiveC->import(qw/:framework/);
};
