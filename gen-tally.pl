use 5.010;
use strict;
use warnings;
use Path::Class;
use JSON;
use Cond::Expr;
use Data::Dump 'pp';

my @ballots = map {
    [sort { $a->{id} <=> $b->{id} } @$_]
} map {
    my $i = 1;
    my $p = $_->[0]->{score};
    for my $c (@$_) {
        $c->{pos} = cond
            (!length $c->{score}) {  '-' }
            ($c->{score} == $p)   {   $i }
            otherwise             { ++$i };

        $p = $c->{score};
    }

    $_;
} map {
    [sort {
        cond (!length $a->{score}) {  1 }
             (!length $b->{score}) { -1 }
             otherwise             { $a->{score} <=> $b->{score} }
        } @$_]
} map {
    $_->{ballot}
} map {
    decode_json $_->slurp
} dir('votes')->children;

for my $b (@ballots) {
    say "V: ". join "|" => map { $_->{pos} } @$b
}
