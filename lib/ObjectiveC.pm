package ObjectiveC;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp qw(croak);

use namespace::clean;

require XSLoader;
XSLoader::load('ObjectiveC', $VERSION);

ObjectiveC->init_autorelease_pool;

sub import {
    shift; # remove self
    my $pkg = caller;

    my @objects;

    my $saw_framework = 0;
    foreach (@_) {
        if($_ eq ':framework') {
            $saw_framework = 1;
            next;
        }
        if($saw_framework) {
            ObjectiveC->load_framework($_);
            $saw_framework = 0;
        } else {
            push @objects, $_;
        }
    }
    if($saw_framework) {
        croak ":framework specified at end of argument list";
    }

    no strict 'refs';
    foreach (@objects) {
        my $class = ObjectiveC->get_class($_);
        *{$pkg . '::' . $_} = sub {
            return $class;
        };
    }
}

package ObjectiveC::id;

use vars qw($AUTOLOAD);

sub AUTOLOAD {
    my $self = shift;

    my $class = ref($self);
    my $method = $AUTOLOAD;
    $method =~ s/^${class}:://g;
    return unless $method =~ /[a-z]/;

    return ObjectiveC->send_to_object($self, $method, @_);
}

END {
    ObjectiveC->release_autorelease_pool;
}

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
