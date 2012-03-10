package MetaCPAN::Contest::Vote::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=head1 NAME

MetaCPAN::Contest::Vote::Controller::Root - Root Controller for MetaCPAN::Contest::Vote

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

Redirect to /entries.

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->response->redirect(
        $c->uri_for_action( $c->controller('Entries')->action_for('index') )
    );
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->body('Page not found');
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
}

=head2 authentication

Make sure the chain of this action if you want to restrict some
action to a logged in user. The user will be logged in via
Github. We also make sure that he is a contributor to the
CPAN-API/cpan-api or the CPAN-API/metacpan-web repo.

=cut

sub authentication : Chained('/') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # This may be set if the user could not be restored from the
    # session and we made a redirect to the Github OAuth endpoint.
    # Github will redirect back then and set the code parameter.
    if ( my $code = $c->request->param('code') ) {
        eval { $c->authenticate( { code => $code } ) };
        if ($@) {
            $c->detach( 'authentication_error', [$@] );
        }
        $c->response->redirect( $c->uri_for( $c->request->uri->path ) );
    }

    if ( !$c->user_exists ) {
        $c->response->redirect( $c->uri_for_github('authorize') );
        $c->log->debug("Redirecting to Github for authorization");
        return;
    }
}

sub login : Chained('/authentication') Args(0) {
    my ($self, $ctx) = @_;

    $ctx->response->redirect( $ctx->uri_for('/') )
        if $ctx->user_exists;
}

=head2 authentication_error

In case something goes wrong during the authentication, this action
gets called and shows an error template.

=cut

sub authentication_error : Private {
    my ( $self, $c, $error ) = @_;
    $c->stash->{error}    = "$error";
    $c->stash->{template} = 'authentication/error.html';
}

=head1 AUTHOR

Johannes Plunien

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
