# Return::MultiLevel ![static](https://github.com/uperl/Return-MultiLevel/workflows/static/badge.svg) ![linux](https://github.com/uperl/Return-MultiLevel/workflows/linux/badge.svg)

Return across multiple call levels

# SYNOPSIS

```perl
use Return::MultiLevel qw(with_return);

sub inner {
  my ($f) = @_;
  $f->(42);  # implicitly return from 'with_return' below
  print "You don't see this\n";
}

sub outer {
  my ($f) = @_;
  inner($f);
  print "You don't see this either\n";
}

my $result = with_return {
  my ($return) = @_;
  outer($return);
  die "Not reached";
};
print $result, "\n";  # 42
```

# DESCRIPTION

This module provides a way to return immediately from a deeply nested call
stack. This is similar to exceptions, but exceptions don't stop automatically
at a target frame (and they can be caught by intermediate stack frames using
[`eval`](https://metacpan.org/pod/perlfunc#eval-EXPR)). In other words, this is more like
[setjmp(3)](http://man.he.net/man3/setjmp)/[longjmp(3)](http://man.he.net/man3/longjmp) than [`die`](https://metacpan.org/pod/perlfunc#die-LIST).

Another way to think about it is that the "multi-level return" coderef
represents a single-use/upward-only continuation.

## Functions

The following functions are available (and can be imported on demand).

- with\_return BLOCK

    Executes _BLOCK_, passing it a code reference (called `$return` in this
    description) as a single argument. Returns whatever _BLOCK_ returns.

    If `$return` is called, it causes an immediate return from `with_return`. Any
    arguments passed to `$return` become `with_return`'s return value (if
    `with_return` is in scalar context, it will return the last argument passed to
    `$return`).

    It is an error to invoke `$return` after its surrounding _BLOCK_ has finished
    executing. In particular, it is an error to call `$return` twice.

# DEBUGGING

This module uses [`unwind`](https://metacpan.org/pod/Scope::Upper#unwind) from
[`Scope::Upper`](https://metacpan.org/pod/Scope::Upper) to do its work. If
[`Scope::Upper`](https://metacpan.org/pod/Scope::Upper) is not available, it substitutes its own pure
Perl implementation. You can force the pure Perl version to be used regardless
by setting the environment variable `RETURN_MULTILEVEL_PP` to 1.

If you get the error message `Attempt to re-enter dead call frame`, that means
something has called a `$return` from outside of its `with_return { ... }`
block. You can get a stack trace of where that `with_return` was by setting
the environment variable `RETURN_MULTILEVEL_DEBUG` to 1.

# CAVEATS

You can't use this module to return across implicit function calls, such as
signal handlers (like `$SIG{ALRM}`) or destructors (`sub DESTROY { ... }`).
These are invoked automatically by perl and not part of the normal call chain.

# AUTHORS

- Lukas Mai
- Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013,2014,2021 by Lukas Mai.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
