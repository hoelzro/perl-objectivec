use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

use ObjectiveC;

dies_ok {
    ObjectiveC->get_class('NSString');
};

ObjectiveC->load_framework('Foundation');

ok(ObjectiveC->get_class('NSString'));
