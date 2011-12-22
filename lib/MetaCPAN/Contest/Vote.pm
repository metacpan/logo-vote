package MetaCPAN::Contest::Vote;

use Moose;
use Catalyst::Exception;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
    Authentication
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    /;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in metacpan_contest_vote.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    default_view => 'HTML',

    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,

    enable_catalyst_header => 1,    # Send X-Catalyst header

    github => {
        url => {
            access_token =>
                'https://github.com/login/oauth/access_token?client_id=%s&client_secret=%s&code=%s',
            authorize =>
                'https://github.com/login/oauth/authorize?client_id=%s&redirect_uri=%s',
        },
    },

    name => 'MetaCPAN::Contest::Vote',

    'Plugin::Authentication' => {
        default_realm => 'github',
        github        => {
            credential => {
                class         => 'Password',
                password_type => 'none',
            },
            store => {
                class       => 'FromSub',
                user_type   => 'Hash',
                model_class => 'Authentication',
            }
        },
    },

    'View::HTML' => {
        AUTO_FILTER        => 'html',
        ENCODING           => 'utf8',
        INCLUDE_PATH       => 'root/templates/',
        STAT_TTL           => '1',
        TAG_STYLE          => 'asp',
        TEMPLATE_EXTENSION => '.html',
        WRAPPER            => 'page.html',
    },
);

# Start the application
__PACKAGE__->setup();

sub uri_for_github {
    my ( $c, $type, $code ) = @_;
    if ( $type eq 'authorize' ) {
        return sprintf
            $c->config->{github}{url}{$type},
            $c->config->{github}{client_id},
            $c->uri_for( $c->request->uri->path );
    }
    elsif ( $type eq 'access_token' ) {
        return sprintf
            $c->config->{github}{url}{$type},
            $c->config->{github}{client_id},
            $c->config->{github}{client_secret},
            $code;
    }
    Catalyst::Exception->throw("Unknown uri type: $type");
}

=head1 NAME

MetaCPAN::Contest::Vote - Catalyst based application

=head1 SYNOPSIS

    script/metacpan_contest_vote_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<MetaCPAN::Contest::Vote::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Johannes Plunien

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
