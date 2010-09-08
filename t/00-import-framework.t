use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use ObjectiveC;

dies_ok {
    ObjectiveC->get_class('NSWindow');
};

ObjectiveC->import(qw/:framework Cocoa/);

ok(ObjectiveC->get_class('NSWindow'));

dies_ok {
    ObjectiveC->import(qw/:framework/);
};
