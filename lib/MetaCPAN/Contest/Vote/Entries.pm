package MetaCPAN::Contest::Vote::Entries;

use Moose;
use MooseX::Types::URI qw(Uri);
use HTTP::Request;
use LWP::UserAgent;
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
        'http://entries.contest.metacpan.org/feeds/posts/default?alt=rss&max-results=500',
    is  => 'ro',
    isa => Uri,
);

has 'last_modified' => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_last_modified',
);

has 'ua' => (
    is         => 'ro',
    isa        => 'LWP::UserAgent',
    lazy_build => 1,
);

=head1 METHODS

=cut

sub _build_feed {
    my ($self) = @_;
    my $rss = $self->fetch_feed;
    my $feed = XML::Feed->parse( \$rss ) or die XML::Feed->errstr;
    return $feed;
}

sub _build_ua {
    my ($self) = @_;
    return LWP::UserAgent->new;
}

=head2 fetch_feed

Fetches the feed from C<feed_url>, using the HTTP headers
Last-Modified and If-Modified-Since (mst++). Returns undef
if the RSS feed was not modified. It also handles setting
the C<last_modified> attribute.

=cut

sub fetch_feed {
    my ($self) = @_;
    my $request = HTTP::Request->new( GET => $self->feed_url );
    if ( $self->has_last_modified ) {
        $request->header( 'If-Modified-Since' => $self->last_modified );
    }
    my $response = $self->ua->request($request);
    if ( $response->is_success ) {
        $self->{last_modified} = $response->header('Last-Modified');
        return $response->decoded_content;
    }
}

=head2 images

Reads the RSS feed and parses the description field for img tags. It
returns an arrayref of hashrefs containing a list of image URLs as
well as the title of the blog post.

    [
        {   'images' => [
                {   'height' => '16',
                    'src' =>
                        'http://4.bp.blogspot.com/-PziLcYtp3Fw/TvHpoZLbRgI/AAAAAAAAAHQ/ErAM6rEThG8/s400/au-icon-small.png',
                    'width' => 16
                },
                {   'height' => '300',
                    'src' =>
                        'http://4.bp.blogspot.com/-JjWg5DKfnqY/TvHpogPS3oI/AAAAAAAAAHc/HhQfw7IxZC4/s400/au-icon.png',
                    'width' => 300
                },
                {   'height' => '149',
                    'src' =>
                        'http://1.bp.blogspot.com/-aWUfuJ2S4Lg/TvHpo4b2r5I/AAAAAAAAAHo/ZmQogctdJGw/s400/metaCPANprotocol.png',
                    'width' => 300
                }
            ],
            'title' => 'Audrey Tang - The meta->CPAN protocol'
        },
        {   'images' => [
                {   'height' => '16',
                    'src' =>
                        'http://1.bp.blogspot.com/-AtBjwgh-IDY/TvDs6tZIXEI/AAAAAAAAAG4/oRZCT11A3P0/s400/barry.arthur%2540gmail.com-horus_eye_of_cpan_version_3-111220.png',
                    'width' => 16
                },
                {   'height' => '350',
                    'src' =>
                        'http://2.bp.blogspot.com/-YKrSEUANo9c/TvDtHg6JdFI/AAAAAAAAAHE/ois81zHFp7M/s400/barry.png',
                    'width' => 350
                }
            ],
            'title' => 'Barry Arthur - Horus Eye of CPAN'
        },
        ...
    ]

=cut

sub list {
    my ($self) = @_;
    $self->refresh;
    my @result;
    foreach my $entry ( $self->entries ) {
        my $dom = Mojo::DOM->new( $entry->content->body );
        my @images;
        $dom->find('img')->each(
            sub {
                my ($img) = @_;
                return if exists $img->{width}  && $img->{width}  == 1
                       && exists $img->{height} && $img->{height} == 1;
                push @images,
                    {
                    height => $img->{height},
                    src    => $img->{src},
                    width  => $img->{width},
                    };
            }
        );
        next unless @images;
        push @result,
            {
            images => [ sort { $a->{height} <=> $b->{height} } @images ],
            link  => $entry->link,
            title => $entry->title,
            };
    }
    return [reverse @result];
}

=head2 refresh

Refresh the data from the RSS feed.

=cut

sub refresh {
    my ($self) = @_;
    if ( my $rss = $self->fetch_feed ) {
        $self->{feed} = XML::Feed->parse( \$rss ) or die XML::Feed->errstr;
    }
}

__PACKAGE__->meta->make_immutable;

1;
