use strict;
use warnings;

use Test::More tests => 2;
use Test::Exception;

use ObjectiveC;

dies_ok {
    ObjectiveC->get_class('NSWindow');
};

ObjectiveC->load_framework('Cocoa');

ok(ObjectiveC->get_class('NSWindow'));
