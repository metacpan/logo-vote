package MetaCPAN::Contest::Vote::Model::Authentication;

use Moose;
use JSON;
use Catalyst::Exception;
use MooseX::Types::Path::Class 'File';
use namespace::autoclean;

extends 'Catalyst::Model';

has contributors_file => (
    is       => 'ro',
    isa      => File,
    coerce   => 1,
    required => 1,
);

has contributors => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef[HashRef]', # keyed by numeric github id
    lazy    => 1,
    builder => '_build_contributors',
    handles => {
        _has_contributor => 'exists',
    },
);

after BUILD => sub {
    my ($self) = @_;
    use Data::Dump 'pp';
    pp $self->contributors;
    ();
};

sub _build_contributors {
    my ($self) = @_;

    my @contributors_list = @{ decode_json $self->contributors_file->slurp };

    return {
        map {
            ($_->{id} => $_)
        } @contributors_list,
    };
}

sub auth {
    my ( $self, $c, $userinfo ) = @_;

    if ( my $code = $userinfo->{code} ) {
        my $uri = $c->uri_for_github( access_token => $code );
        my $token = $self->get_token($uri);
        $c->model('Pithub')->token($token);
        my $user = $self->get_user($c);
        unless ( $self->is_contributor( $c, $user ) ) {
            Catalyst::Exception->throw(
                sprintf 'The user %s is not a contributor of '
                    . 'CPAN-API/cpan-api or CPAN-API/metacpan-web',
                $user->{login}
            );
        }
        $user->{token} = $token;
        return { github_user => $user };
    }

    # If we restore the user from the session, we do not need to
    # check again if he is a contributor.
    elsif ( my $token = $userinfo->{token} ) {
        $c->model('Pithub')->token($token);
        my $user = $self->get_user($c);
        return { github_user => $user };
    }
}

sub get_token {
    my ( $self, $uri ) = @_;
    my $ua  = LWP::UserAgent->new;
    my $res = $ua->post($uri);
    my ($error) = $res->decoded_content =~ qr{error=(.*?)$};
    if ( !$res->is_success || $error ) {
        $error ||= 'Unknown error';
        Catalyst::Exception->throw($error);
    }
    my ($token) = $res->decoded_content =~ qr{access_token=([^&]+)};
    unless ($token) {
        Catalyst::Exception->throw(
            'Github response did not contain the OAuth token');
    }
    return $token;
}

sub get_user {
    my ( $self, $c ) = @_;
    my $result = $c->model('Pithub')->users->get;
    unless ( $result->success ) {
        Catalyst::Exception->throw('Could not fetch user from Github');
    }
    return $result->content;
}

sub is_contributor {
    my ( $self, $c, $user ) = @_;
    return $self->_has_contributor($user->{id});
}

=head1 NAME

MetaCPAN::Contest::Vote::Model::Authentication

=cut

1;
