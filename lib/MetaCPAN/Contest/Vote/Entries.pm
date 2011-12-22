package MetaCPAN::Contest::Vote::Entries;

use Moose;
use MooseX::Types::URI qw(Uri);
use Mojo::DOM;
use URI;
use XML::Feed;
use namespace::autoclean;

=head1 NAME

MetaCPAN::Contest::Vote::Entries

=cut

has 'feed' => (
    handles    => [qw(entries)],
    is         => 'ro',
    isa        => 'XML::Feed',
    lazy_build => 1,
);

has 'feed_url' => (
    coerce => 1,
    default =>
        'http://entries.contest.metacpan.org/feeds/posts/default?alt=rss',
    is  => 'ro',
    isa => Uri,
);

=head1 METHODS

=cut

sub _build_feed {
    my ($self) = @_;
    my $feed = XML::Feed->parse( $self->feed_url )
        or die XML::Feed->errstr;
    return $feed;
}

=head2 images

Fetches the RSS feed, parses the description field for img tags. It
returns an arrayref of hashrefs containing a list of image URLs as
well as the title of the blog post.

    $VAR1 = [
        {   'images' => [
                'http://4.bp.blogspot.com/-PziLcYtp3Fw/TvHpoZLbRgI/AAAAAAAAAHQ/ErAM6rEThG8/s400/au-icon-small.png',
                'http://4.bp.blogspot.com/-JjWg5DKfnqY/TvHpogPS3oI/AAAAAAAAAHc/HhQfw7IxZC4/s400/au-icon.png',
                'http://1.bp.blogspot.com/-aWUfuJ2S4Lg/TvHpo4b2r5I/AAAAAAAAAHo/ZmQogctdJGw/s400/metaCPANprotocol.png'
            ],
            'title' => 'Audrey Tang - The meta->CPAN protocol'
        },
        {   'images' => [
                'http://1.bp.blogspot.com/-AtBjwgh-IDY/TvDs6tZIXEI/AAAAAAAAAG4/oRZCT11A3P0/s400/barry.arthur%2540gmail.com-horus_eye_of_cpan_version_3-111220.png',
                'http://2.bp.blogspot.com/-YKrSEUANo9c/TvDtHg6JdFI/AAAAAAAAAHE/ois81zHFp7M/s400/barry.png'
            ],
            'title' => 'Barry Arthur - Horus Eye of CPAN'
        },
        ...
    ];

=cut

sub list {
    my ($self) = @_;
    my @result;
    foreach my $entry ( $self->entries ) {
        my $dom = Mojo::DOM->new( $entry->content->body );
        my @images;
        $dom->find('img')->each(
            sub {
                my ($img) = @_;
                return if $img->{width} == 1 && $img->{height} == 1;
                push @images, $img->{src};
            }
        );
        next unless @images;
        push @result, {
            title => $entry->title,
            images => \@images,
        };
    }
    return \@result;
}

__PACKAGE__->meta->make_immutable;

1;
