package MetaCPAN::Contest::Vote::Model::Pithub;

use strict;
use warnings;
use base qw(Catalyst::Model::Adaptor);

__PACKAGE__->config(
    args => {
        auto_pagination => 1,
        per_page        => 100,
    },
    class => 'Pithub'
);

sub mangle_arguments {
    my ( $self, $args ) = @_;
    return %$args;
}

=head1 NAME

MetaCPAN::Contest::Vote::Model::Pithub

=cut

1;
