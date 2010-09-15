use strict;
use warnings;

use Module::Build;

unless($^O eq 'darwin') {
    die "OS unsupported\n";
}

my $builder = Module::Build->new(
    module_name => 'ObjectiveC',
    dist_abstract => 'Perl-ObjectiveC bridge',
    license => 'perl',
    needs_compiler => 1,
    dynamic_config => 1,
    xs_files => {
        'ObjectiveC.xs' => 'lib/ObjectiveC.xs',
    },
    c_source => 'src',
    extra_compiler_flags => ['-I.', '-x', 'objective-c'],
    extra_linker_flags => ['-lobjc', '-framework', 'Foundation'],
);

$builder->create_build_script;
