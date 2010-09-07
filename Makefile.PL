use strict;
use warnings;
use ExtUtils::MakeMaker;

unless($^O eq 'darwin') {
    die "OS unsupported\n";
}

WriteMakefile(
    NAME              => 'ObjectiveC',
    VERSION_FROM      => 'lib/ObjectiveC.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/ObjectiveC.pm', # retrieve abstract from module
       AUTHOR         => 'Rob Hoelz <rob@hoelz.ro>') : ()),
    LIBS              => ['-lobjc'], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I.', # e.g., '-I. -I/usr/include/other'
);
