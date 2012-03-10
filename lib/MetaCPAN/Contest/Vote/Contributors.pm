package MetaCPAN::Contest::Vote::Contributors;

use Moose;
use MooseX::Types::Path::Class;
use File::Slurp;
use FindBin;
use JSON;
use Pithub;
use namespace::autoclean;

=head1 NAME

MetaCPAN::Contest::Vote::Contributors

=cut

has '_file' => (
    coerce  => 1,
    default => "$FindBin::Bin/../data/contributors.json",
    is      => 'ro',
    isa     => 'Path::Class::File',
);

has '_json' => (
    handles => {
        _decode => 'decode',
        _encode => 'encode',
    },
    is         => 'ro',
    isa        => 'JSON',
    lazy_build => 1,
);

has '_pithub' => (
    is         => 'ro',
    isa        => 'Pithub',
    lazy_build => 1,
);

has '_repos' => (
    handles    => { repos => 'elements', },
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    lazy_build => 1,
    traits     => [qw(Array)],
);

=head1 METHODS

=cut

sub _build__json {
    return JSON->new;
}

sub _build__pithub {
    my ($self) = @_;
    return Pithub->new(
        auto_pagination => 1,
        per_page        => 100,
    );
}

sub _build__repos {
    return [qw(CPAN-API/metacpan-web CPAN-API/cpan-api)];
}

sub _contributors {
    return shift->_pithub->repos->contributors(@_);
}

sub _user {
    return shift->_pithub->users->get(@_);
}

=head2 fetch

Returns an arrayref of hashrefs, containing all contributors to the
CPAN-API/metacpan-web and CPAN-API/cpan-api repositories. The
hashrefs look like:

    [{
      'email' => 'plu@pqpq.de',
      'name' => 'Johannes Plunien',
      'id' => '31597',
      'login' => 'plu'
    },
    {
      'email' => undef,
      'name' => undef,
      'id' => '144096',
      'login' => 'reneeb'
    }]

The only field being guaranteed to be set is C<login>, sadly. It
uses the Github API to fetch the data.

=cut

sub fetch {
    my ($self) = @_;
    my %result;
    foreach my $urn ( $self->repos ) {
        my ( $repo_user, $repo_name ) = split '/', $urn;
        my $contributors_rs = $self->_contributors(
            user => $repo_user,
            repo => $repo_name,
        );
        while ( my $contributor = $contributors_rs->next ) {
            my $user_rs = $self->_user( user => $contributor->{login} );
            my $user = $user_rs->content;
            $result{ $user->{id} } ||= {
                email => $user->{email},
                id    => $user->{id},
                login => $user->{login},
                name  => $user->{name},
            };
        }
    }
    return [ values %result ];
}

=head2 load

Loads the (previously) stored contributors from a JSON file. Returns
the same data format like L</fetch>.

=cut

sub load {
    my ($self) = @_;
    my $file   = $self->_file->stringify;
    my $json   = read_file $file;
    return $self->_decode($json);
}

=head2 store

This writes the contributors fetched by L</fetch> to a file in the
JSON format. The path to the file can be given as a parameter to
this function.

=cut

sub store {
    my ($self) = @_;
    my $data   = $self->fetch;
    my $json   = $self->_encode($data);
    my $file   = $self->_file->stringify;
    write_file $file, $json;
}

__PACKAGE__->meta->make_immutable;

1;
