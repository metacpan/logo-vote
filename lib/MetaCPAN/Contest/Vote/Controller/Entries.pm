package MetaCPAN::Contest::Vote::Controller::Entries;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

has vote_storage => (
    is       => 'ro',
    required => 1,
    isa      => 'MetaCPAN::Contest::Vote::Votes',
    handles  => ['has_voted'],
);

=head1 NAME

MetaCPAN::Contest::Vote::Controller::Entries - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        entries   => $c->model('Entries')->list,
        can_vote  => $c->user_exists && !$self->has_voted($c->user->{github_user}),
    );
}

=head1 AUTHOR

Johannes Plunien

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
