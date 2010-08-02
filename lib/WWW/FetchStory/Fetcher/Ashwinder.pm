package WWW::FetchStory::Fetcher::Ashwinder;
use strict;
use warnings;
=head1 NAME

WWW::FetchStory::Fetcher::Ashwinder - fetching module for WWW::FetchStory

=head1 DESCRIPTION

This is the Ashwinder story-fetching plugin for WWW::FetchStory.

=cut

our @ISA = qw(WWW::FetchStory::Fetcher);

=head2 priority

The priority of this fetcher.  Fetchers with higher priority
get tried first.  This is useful where there may be a generic
fetcher for a particular site, and then a more specialized fetcher
for particular sections of a site.  For example, there may be a
generic Ashwinder fetcher, and then refinements for particular
Ashwinder community, such as the sshg_exchange community.
This works as either a class function or a method.

This must be overridden by the specific fetcher class.

$priority = $self->priority();

$priority = WWW::FetchStory::Fetcher::priority($class);

=cut

sub priority {
    my $class = shift;

    return 1;
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

    return ($url =~ /ashwinder\.sycophanthex\.com/);
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
    if ($args{url} =~ m#sid=(\d+)#)
    {
	$sid = $1;
    }
    else
    {
	return $self->SUPER::parse_toc(%args);
    }

    if ($content =~ /<h4>(.*?)<\/h4>/)
    {
	$info{title} = $1;
    }
    elsif ($content =~ m#<b><a href="viewstory.php\?sid=${sid}">([^<]+)</a></b> by <b><a href="viewuser.php#s)
    {
	$info{title} = $1;
    }
    else
    {
	$info{title} = $self->parse_title(%args);
    }
    if ($content =~ m#<a href="viewuser.php\?uid=\d+">([^<]+)</a>#s)
    {
	$info{author} = $1;
    }
    else
    {
	$info{author} = $self->parse_author(%args);
    }
    if ($content =~ /<i>Summary:<\/i>\s*(.*?)\s*$/m)
    {
	$info{summary} = $1;
    }
    # if this is a single-chapter story, the summary is on the author page
    elsif ($content =~ m#<a href="viewuser.php\?uid=(\d+)">#s)
    {
	my $auth_url = sprintf("http://ashwinder.sycophanthex.com/viewuser.php?uid=%d", $1);
	my $auth_page = $self->get_page($auth_url);
	if ($auth_page =~ m#<a href="viewstory.php\?sid=${sid}">.*?<br>\s*([^<]+)\s*<br>#s)
	{
	    $info{summary} = $1;
	}
    }
    $info{characters} = 'Hermione Granger, Severus Snape';
    $info{universe} = 'Harry Potter';


    # Ashwinder does not have a sane chapter system
    my $fmt = 'http://ashwinder.sycophanthex.com/viewstory.php?action=printable&sid=%d';
    if ($content =~ m#&i=1"#s)
    {
	while ($content =~ m#<a href="viewstory.php\?sid=(\d+)&i=1">#sg)
	{
	    my $ch_sid = $1;
	    my $ch_url = sprintf($fmt, $ch_sid);
	    warn "chapter=$ch_url\n" if $self->{verbose};
	    push @chapters, $ch_url;
	}
    }
    else
    {
	@chapters = (sprintf($fmt, $sid));
    }
    $info{chapters} = \@chapters;

    return %info;
} # parse_toc

1; # End of WWW::FetchStory::Fetcher::Ashwinder
__END__