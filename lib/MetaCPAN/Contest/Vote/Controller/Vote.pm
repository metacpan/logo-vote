package MetaCPAN::Contest::Vote::Controller::Vote;

use Moose;
use Params::Classify 'is_ref', 'ref_type';
use MetaCPAN::Contest::Vote::Types 'Ballot';
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

MetaCPAN::Contest::Vote::Controller::Vote - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub reject {
    my ($self, $ctx, $reason) = @_;
    $ctx->detach( $self->action_for('voting_failure'), [$reason] );
};

sub index : Chained('/authentication') PathPart('vote') Args(0) {
    my ( $self, $c ) = @_;

    $self->reject($c, 'not a POST')
        unless $c->request->method eq 'POST';

    $self->reject($c, 'no ballot supplied')
        if !exists $c->request->params->{votes};

    my $votes = $c->request->params->{votes};
    $self->reject($c, 'malformed ballot')
        if !is_ref($votes) || ref_type($votes) ne 'ARRAY';

    my $validation_error = Ballot->validate($votes);
    $self->reject($c, 'malformed ballot: ' . $validation_error)
        if defined $validation_error;

    use Data::Dumper;
    $Data::Dumper::Sortkeys = 1;
    $c->response->body( '<pre>' . Dumper( $c->request->params->{votes} ) . '</pre>' );
}

sub voting_failure : Action {
    my ($self, $ctx, $reason) = @_;

    $ctx->stash(reason => $reason);
    $ctx->response->status(400);
}

=head1 AUTHOR

Johannes Plunien

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
