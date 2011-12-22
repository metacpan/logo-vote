package MetaCPAN::Contest::Vote::Controller::Vote;

use Moose;
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

sub index : Chained('/authentication') PathPart('vote') Args(0) {
    my ( $self, $c ) = @_;

    use Data::Dumper;
    $Data::Dumper::Sortkeys = 1;
    $c->response->body( '<pre>' . Dumper( $c->user ) . '</pre>' );
}

=head1 AUTHOR

Johannes Plunien

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
