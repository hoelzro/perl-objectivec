use strict;
use warnings;

use Test::More tests => 4;
use Test::Exception;

use ObjectiveC;

ok(! __PACKAGE__->can('NSObject'));
ObjectiveC->import('NSObject');
ok(__PACKAGE__->can('NSObject'));
my $object = NSObject();
is(ref($object), 'ObjectiveC::id');
dies_ok {
    ObjectiveC->import('ThisClassShouldNotExist');
};

__DATA__

- unimport?
