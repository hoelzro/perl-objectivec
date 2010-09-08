use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use ObjectiveC;

dies_ok {
    ObjectiveC->get_class('NSString');
};

ObjectiveC->import(qw/:framework Foundation/);

ok(ObjectiveC->get_class('NSString'));

dies_ok {
    ObjectiveC->import(qw/:framework/);
};
