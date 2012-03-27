package MetaCPAN::Contest::Vote::Votes;

use Moose;
use Try::Tiny;
use JSON;
use MooseX::Types::Path::Class 'Dir';
use MooseX::Types::Common::Numeric 'PositiveInt';
use namespace::autoclean;

has vote_storage => (
    is       => 'ro',
    required => 1,
    isa      => Dir,
    coerce   => 1,
);

sub BUILD {
    my ($self) = @_;
    confess "storage directory '@{[ $self->vote_storage ]}' isn't writable"
        unless -w $self->vote_storage;
}

sub vote_for {
    my ($self, $user) = @_;
    $self->vote_storage->file($user->{id} . '.json');
}

sub has_voted {
    my ($self, $user) = @_;
    -e $self->vote_for($user);
}

sub submit_ballot {
    my ($self, $user, $ballot) = @_;

    # this is probably a bit racy, but it seems like the worst that could happen
    # is one overwriting his own vote, which doesn't seem too bad

    die "broken github user\n"
        if !exists $user->{id} || !PositiveInt->check($user->{id});

    die "you already voted\n"
        if $self->has_voted($user);

    my $vote_file = $self->vote_for($user);
    try {
        my $fh = $vote_file->openw;
        print { $fh } encode_json {
            time   => time,
            user   => $user,
            ballot => $ballot,
        } or die "failed to write ballot: $!";
        close $fh or die "failed to flush ballot: $!";
    }
    catch {
        $vote_file->remove;
        die "Failed to register vote: $_\n";
    };
}

__PACKAGE__->meta->make_immutable;

1;
