package ObjectiveC;

use strict;
use warnings;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('ObjectiveC', $VERSION);

1;
__END__
=head1 NAME

ObjectiveC - Perl-Objective C bridge

=head1 SYNOPSIS

  use ObjectiveC;

=head1 DESCRIPTION

The ObjectiveC module allows users to manipulate Objective C framework
objects as if they were Perl objects.

=head1 AUTHOR

Rob Hoelz, E<lt>rob@hoelz.roE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Rob Hoelz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
