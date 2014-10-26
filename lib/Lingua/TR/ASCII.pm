package Lingua::TR::ASCII;
use strict;
use warnings;
use utf8;
use base qw( Exporter );
use Lingua::TR::ASCII::Data;

our $VERSION = '0.11';
our @EXPORT  = qw( ascii_to_turkish turkish_to_ascii );

sub ascii_to_turkish {
    my($str) = @_;
    return $str if ! $str;
    return __PACKAGE__->_new( $str )->_deasciify;
}

sub turkish_to_ascii {
    die "Unimplemented\n";
}

sub _new {
    my($class, $input) = @_;
    my $self = {
        input   => $input,
        length  => length $input,
        turkish => $input,
    };
    bless $self, $class;
    return $self;
}

# Convert a string with ASCII-only letters into one with Turkish letters.
sub _deasciify {
    my($self) = @_;
    my $s     = \$self->{turkish};
    my @chars = split m{}xms, ${$s};

    for my $i ( 0 .. $#chars ) {
        my $c = $chars[$i];
        next if ! $self->_needs_correction( $c, $i );
        substr ${$s}, $i, 1, $TOGGLE_ACCENT->{ $c } || $c;
    }

    return ${$s};
}

# Determine if char at cursor needs correction.
sub _needs_correction {
    my($self, $ch, $point) = @_;
    my $tr = $ASCIIFY->{ $ch } || $ch;
    my $pl = $PATTERN->{ lc $tr };
    my $m  = $pl ? $self->_matches( $pl, $point || 0 ) : 0;

    return $tr eq 'I' ? ( $ch eq $tr ? ! $m :   $m )
                      : ( $ch eq $tr ?   $m : ! $m );
}

# Check if the pattern is in the pattern table.
sub _matches {
    my($self, $dlist, $point) = @_;
    my $str  = $self->_get_context( $point || 0 );
    my $rank = 2 * keys %{ $dlist };
    my $len  = length $str;
    my($start, $end);

    while ( $start++ <= CONTEXT_SIZE ) {
        $end = CONTEXT_SIZE;
        while ( ++$end <= $len ) {
            my $s = substr $str, $start, $end - $start;
            my $r = $dlist->{ $s } || next;
            $rank = $r if abs $r < abs $rank;
        }
    }

    return $rank > 0;
}

sub _get_context {
    my($self, $point, $size) = @_;
    $size ||= CONTEXT_SIZE;
    my($s, $i, $space, $index);

    my $morph = sub {
        my($next, $lookup) = @_;
        $space = 0;
        while ( $next->() ) {
            my $char = substr $self->{turkish}, $index, 1;
            my $x    = $lookup->{ $char };
            if ( $x ) {
                substr $s, abs $i, 1, $x;
                $space = 0;
                $i++;
                next;
            }
            next if $space;
            $space = 1;
            $i++;
        }
    };

    $s     = q{ } x ( 1 + ( 2 * $size ) );
    $i     = 1 + $size;
    $index = $point;
    substr $s, $size, 1, 'X';

    $morph->(
        sub { $i < length $s && ! $space && ++$index < $self->{length} },
        $DOWNCASE_ASCIIFY
    );

    $s     = substr $s, 0, $i;
    $i     = 0 - --$size;
    $index = $point;

    $morph->(
        sub { $i <= 0 && --$index >= 0 },
        $UPCASE_ACCENTS
    );

    return $s;
}

1;

__END__

=pod

=head1 NAME

Lingua::TR::ASCII - (De)asciify Turkish texts.

=head1 SYNOPSIS

    use Lingua::TR::ASCII;
    print ascii_to_turkish(
        'Acimasizca acelya gorunen bir sacmaliktansa acilip sacilmak...'
    );

=head1 DESCRIPTION

This document describes version C<0.11> of C<Lingua::TR::ASCII>
released on C<21 January 2011>.

If you try to write Turkish with a non-Turkish keyboard (assuming you
can't change the layout or can't touch-type) this'll result with the
ascii-fication of the Turkish characters and this actually results
with bogus text since the text you wrote is not literally Turkish anymore
(although the Turkish speaking people and search engines will most
likely understand it). And in some cases, ascii-fication of some sentences
might result with funny words. This module tries to mitigate this problem
with a wrapper around a pre-compiled decison list.

The original creator of the decision list states that it was "created based
on 1 million words of Turkish news text using the GPA algorithm". See
the links below for more information.

This module is based on the previous Python and Ruby implementations.

=head1 FUNCTIONS

=head2 ascii_to_turkish

Converts (corrects) the supplied string into Turkish.

=head2 turkish_to_ascii

Not yet implemented.

=head1 SEE ALSO

L<Lingua::DE::ASCII>,
L<http://ileriseviye.org/blog/?tag=turkish-deasciifier>,
L<http://www.denizyuret.com/2006/11/emacs-turkish-mode.html>.

=head2 OTHER IMPLEMENTATIONS

=head3 Languages

=over 4

=item Java

L<http://code.google.com/p/turkish-deasciifier>

=item JavaScript

L<http://turkce-karakter.appspot.com>

=item Python

L<https://github.com/emres/turkish-deasciifier>

=item Ruby

L<https://github.com/berkerpeksag/ruby-turkish-deasciifier>.

=back

=head3 Tools

=over 4

=item Firefox Add-on

L<https://addons.mozilla.org/en-US/firefox/addon/turkish-deasciifier>.

=back

=head1 AUTHOR

Burak Gursoy <burak@cpan.org>.

=head1 COPYRIGHT

Copyright 2011 Burak Gursoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself, either Perl version 5.12.1 or, 
at your option, any later version of Perl 5 you may have available.

=cut
