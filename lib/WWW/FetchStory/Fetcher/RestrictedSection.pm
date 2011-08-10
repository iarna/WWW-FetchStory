package WWW::FetchStory::Fetcher::RestrictedSection;
use strict;
use warnings;
=head1 NAME

WWW::FetchStory::Fetcher::RestrictedSection - fetching module for WWW::FetchStory

=head1 DESCRIPTION

This is the RestrictedSection story-fetching plugin for WWW::FetchStory.

=cut

our @ISA = qw(WWW::FetchStory::Fetcher);

=head1 METHODS

=head2 info

Information about the fetcher.

$info = $self->info();

=cut

sub info {
    my $self = shift;
    
    my $info = "(http://restrictedsection.org) An adult Harry Potter fiction archive.";

    return $info;
} # info

=head2 priority

The priority of this fetcher.  Fetchers with higher priority
get tried first.  This is useful where there may be a generic
fetcher for a particular site, and then a more specialized fetcher
for particular sections of a site.

This must be overridden by the specific fetcher class.

$priority = $self->priority();

$priority = WWW::FetchStory::Fetcher::priority($class);

=cut

sub priority {
    my $class = shift;

    return 2;
} # priority

=head2 allow

If this fetcher can be used for the given URL, then this returns
true.
This must be overridden by the specific fetcher class.

    if ($obj->allow($url))
    {
	....
    }

=cut

sub allow {
    my $self = shift;
    my $url = shift;

    return ($url =~ /restrictedsection\.org/);
} # allow

=head1 Private Methods

=head2 parse_toc

Parse the table-of-contents file.

    %info = $self->parse_toc(content=>$content,
			 url=>$url);

This should return a hash containing:

=over

=item chapters

An array of URLs for the chapters of the story.  (In the case where the
story only takes one page, that will be the chapter).

=item title

The title of the story.

=back

It may also return additional information, such as Summary.

=cut

sub parse_toc {
    my $self = shift;
    my %args = (
	url=>'',
	content=>'',
	@_
    );

    my %info = ();
    my $content = $args{content};

    my @chapters = ();
    $info{url} = $args{url};
    my $sid='';
    if ($args{url} =~ m#file=(\d+)#)
    {
	$sid = $1;
    }
    elsif ($args{url} =~ m#story=(\d+)#)
    {
	$sid = $1;
    }
    else
    {
	return $self->SUPER::parse_toc(%args);
    }
    $info{title} = $self->parse_title(%args);
    $info{author} = $self->parse_author(%args);
    $info{summary} = $self->parse_summary(%args);
    $info{characters} = $self->parse_characters(%args);
    $info{universe} = 'Harry Potter';
    $info{category} = $self->parse_category(%args);
    $info{rating} = 'Adult';

    if ($args{url} =~ /file.php/) # a single file
    {
	@chapters = ($args{url});
    }
    else
    {
	my $fmt = 'http://www.restrictedsection.org/file.php?file=%d';
	while ($content =~ m#file\.php\?file=(\d+)'#gs)
	{
	    my $ch = $1;
	    my $ch_url = sprintf($fmt, $ch);
	    warn "chapter=$ch_url\n" if $self->{verbose};
	    push @chapters, $ch_url;
	}
    }
    $info{chapters} = \@chapters;
    warn "This interface is incomplete.\n";

    return %info;
} # parse_toc

=head2 parse_title

Get the title from the content

=cut
sub parse_title {
    my $self = shift;
    my %args = (
	url=>'',
	content=>'',
	@_
    );

    my $content = $args{content};
    my $title = '';
    if ($content =~ m#<a href="story\.php\?story=\d+">([^<]+)</a>#m)
    {
	$title = $1;
    }
    elsif ($content =~ m#<title>\s*RestrictedSection\.org\s*-\s*Story Info\s*-\s*([^<]+)\s*</title>#is)
    {
	$title = $1;
    }
    elsif ($content =~ m#<title>\s*RestrictedSection\.org\s*-\s*([^<]+)\s*</title>#is)
    {
	$title = $1;
    }
    else
    {
	$title = $self->SUPER::parse_title(%args);
    }
    return $title;
} # parse_title

=head2 parse_author

Get the author from the content

=cut
sub parse_author {
    my $self = shift;
    my %args = (
	url=>'',
	content=>'',
	@_
    );

    my $content = $args{content};
    my $author = '';
    if ($content =~ m#<a href="author\.php\?author=\d+">([^<]+)</a>#)
    {
	$author = $1;
    }
    else
    {
	$author = $self->SUPER::parse_author(%args);
    }
    return $author;
} # parse_author

1; # End of WWW::FetchStory::Fetcher::RestrictedSection
__END__
