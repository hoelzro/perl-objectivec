use strict;
use warnings;

use Test::More tests => 4;
use Test::Exception;

use ObjectiveC;

ok(! __PACKAGE__->can('Object'));
ObjectiveC->import('Object');
ok(__PACKAGE__->can('Object'));
my $object = Object();
is(ref($object), 'ObjectiveC::id');
dies_ok {
    ObjectiveC->import('ThisClassShouldNotExist');
};

__DATA__

- unimport?
