use strict;
use warnings;

use Test::More tests => 3;

use ObjectiveC qw(NSString :framework Foundation);

ok(__PACKAGE__->can('NSString'));
my $string = NSString;
is(ref($string), 'ObjectiveC::Class');
