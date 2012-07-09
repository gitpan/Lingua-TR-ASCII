use Build::Spec qw( mm_spec );
use ExtUtils::MakeMaker;

my %spec = mm_spec;

if ([%HAS_HOOK%]) {
    my $eok = eval <<'THIS_IS_SOME_IDENTIFIER';
[%HOOK%]
THIS_IS_SOME_IDENTIFIER

    die "Error compiling initialization_hook: $@\n" if $@;
}

WriteMakefile(
    NAME         => $spec{module_name},
    VERSION_FROM => $spec{VERSION_FROM},
    PREREQ_PM    => $spec{PREREQ_PM},
    PL_FILES     => {},
    ($] >= 5.005 ? (
    AUTHOR       => $spec{dist_author},
    ABSTRACT     => $spec{ABSTRACT},
    EXE_FILES    => $spec{EXE_FILES},
    ) : ()),
);
