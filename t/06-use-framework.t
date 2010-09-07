use strict;
use warnings;

use Test::More;

BEGIN {
    if($^O eq 'darwin') {
        plan tests => 3;
    } else {
        plan skip_all => 'You need to be running Mac OS X to test framework loading!';
    }
}

use ObjectiveC qw(NSString :framework Foundation);

ok(__PACKAGE__->can('NSString'));
my $string = NSString;
is(ref($string), 'ObjectiveC::Class');
