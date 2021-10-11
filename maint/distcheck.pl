use strict;
use warnings;

sub slurp {
    my ($file) = @_;
    open my $fh, '<', $file or die "$0: $file: $!\n";
    local $/;
    readline $fh
}

my $version = shift @ARGV;
my @modules = split ' ', shift @ARGV;

my @errors;

my $version_suffix = '';
if ($version =~ /(-TRIAL[0-9]*)\z/) {
    $version_suffix = $1;
} 

for my $module (@modules) {
    my $contents = slurp $module;
    my $pkg = $module;
    $pkg =~ s/\.pm\z//;
    $pkg =~ s![/\\]!::!g;
    $pkg =~ s/^lib:://;

    $contents =~ m{
        ^ [ \t]* (?: our [ \t]+ )?
        \$ (?: \Q$pkg\E :: )? VERSION [ \t]* = [ \t]*
        ( \d+ (?: \. \d+ )? | '([^'\\]+)' ) ;
    }xm or do {
        push @errors, "$module doesn't contain a parsable VERSION declaration";
        next;
    };
    my $v = $+;

    $v eq $version || "$v$version_suffix" eq $version
        or push @errors, "$module version '$v' doesn't match distribution version '$version'";
}

if (@errors) {
    print STDERR map "$0: $_\n", @errors;
    exit 1;
}
