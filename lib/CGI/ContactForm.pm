package CGI::ContactForm;

# $Id: ContactForm.pm,v 1.8 2003/02/09 06:42:29 Gunnar Hjalmarsson Exp $

=head1 NAME

CGI::ContactForm - Perl extension for generating a web contact form

=head1 SYNOPSIS

    #!/usr/bin/perl
    use lib '/path/to/lib';  (For the case this module, or any
                              module it's dependent on, is installed
                              in a local library.)
    use CGI::ContactForm;

    contactform (
        recname        => 'John Smith',              \
        recmail        => 'john.smith@domain.com',    } Compulsory
        smtp           => 'smtp.domain.com',         /

        styleurl       => '/style/ContactForm.css',  \
        returnlinktext => 'Back',                     } Optional
        returnlinkurl  => '/some/url',               /
    );

=head1 DESCRIPTION

This module generates a contact form for the web when the routine C<contactform()>
is called from a CGI script. The CGI script shall consist of just a few lines of
code like in the example under SYNOPSIS above. The arguments are passed to the
module as a list of key/value pairs.

C<CGI::ContactForm> sends a well formated (plain text format=flowed in accordance
with RFC 2646) email message, with the sender's address in the C<From:> header, and
the sender gets a C<bcc> copy. If the email address stated by the sender is invalid,
the failure message is sent to the recipient address, through which you know that
you don't need to bother with a reply, at least not to that address...

=head1 INSTALLATION

=head2 Installation with Makefile.PL

Type the following:

    perl Makefile.PL
    make
    make test
    make install

=head2 Manual Installation

=over 4

=item *

Download and extract the distribution file.

=item *

Designate a directory as your local library for Perl modules, for instance

    /cgi-bin/lib

=item *

Create the directory C</cgi-bin/lib/CGI>, and upload C<ContactForm.pm> to that
directory.

=back

If C<Mail::Sender> and C<Text::Flowed> (see DEPENDENCIES below) need to be
installed manually, you shall create C</cgi-bin/lib/Mail> and C</cgi-bin/lib/Text>
and upload C<Sender.pm> respective C<Flowed.pm> to those directories.

=head1 DEPENDENCIES

C<CGI::ContactForm> requires these modules, available at CPAN:

    Mail::Sender
    Text::Flowed

It also requires direct access to an SMTP server.

=head1 EXAMPLES

An example CGI script (C<contact.pl>) and a style sheet (C<ContactForm.css>) are
included in the distribution. Note that the style sheet typically needs to be
located somewhere outside the cgi-bin.

=head1 VERSION HISTORY

=over 4

=item v0.4 (Feb 9, 2003)

Error alert message added. Also C<ContactForm.css> was modified for this reason.

Test script included in the distribution.

=item v0.3 (Feb 7, 2003)

Check of email syntax modified (hopefully now closer to RFC 822).

Better structured code.

=item v0.2 (Feb 5, 2003)

Referer check in order to only accept data input from the generated form.

Improved email validation.

=item v0.1 (Feb 3, 2003)

Initial release.

=back

=head1 LATEST VERSION

The latest version of C<CGI::ContactForm> is available at:
http://search.cpan.org/author/GUNNAR/ and http://www.gunnar.cc/contactform/

=head1 AUTHOR, COPYRIGHT AND LICENSE

  Copyright © 2003 Gunnar Hjalmarsson
  http://www.gunnar.cc/cgi-bin/contact.pl

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

use strict;
my (%args, %in, %error);
use vars qw($VERSION @ISA @EXPORT);

$VERSION = 0.4;

use Exporter;
@ISA = 'Exporter';
@EXPORT = 'contactform';

sub contactform {
    print "Content-type: text/html; charset=iso-8859-1\n\n";
    arguments (@_);
    if ($ENV{'REQUEST_METHOD'} eq 'POST') {
        referercheck();
        readform();
    }
    if (formcheck() eq 'OK') {
        eval { mailsend() };
        if ($@) {
            htmlize (my $err = $@);
            $err =~ s/\n/<br>\n/g;
            exit (print "<h1>Error</h1>\n<tt>", $err);
        }
    } else {
        formprint();
    }
}

sub arguments {
    my @error = ();
    {
        # Grabs the key/value pairs and checks that the number of elements isn't odd
        local $^W = 1;
        local $SIG{__WARN__} = sub { die $_[0] };
        eval {
            %args = (
                returnlinktext => 'Main Page',  # default argument
                returnlinkurl  => '/',          # "-
                @_                              # arguments passed from CGI script
            )
        };
        push @error, $@, "The module expects a number of key/value pairs.\n" if $@;
    }
    for (qw/recname recmail smtp/) {
        push @error, "The compulsory argument '$_' is missing.\n" unless $args{$_};
    }
    if ($args{'recmail'} and emailsyntax ($args{'recmail'}) eq 'ERR') {
        push @error, "'$args{'recmail'}' is not a valid email address.\n";
    }
    if (@error) {
        print "<h1>Error</h1>\n<pre>";
        for (@error) { print }

        print <<EXAMPLE;

Example:

    contactform (
        recname => 'John Smith',
        recmail => 'john.smith\@domain.com',
        smtp    => 'smtp.domain.com',
    );
EXAMPLE

        exit;
    }
}

sub referercheck {
    return if $ENV{'HTTP_REFERER'} =~ /$ENV{'HTTP_HOST'}$ENV{'REQUEST_URI'}/i;
    print "<h1>Error</h1>\n",
          "<p>This script only permits data input from its self generated form.\n",
          "<p><a href=\"$ENV{'REQUEST_URI'}\">Try again</a>";
    exit;
}

sub readform {
    %in = ();
    read (STDIN, $in{'raw'}, $ENV{'CONTENT_LENGTH'});
    $in{'raw'} =~ s/\+/ /g;
    for (split(/&/, $in{'raw'}))	{
        my ($name, $value) = split(/=/);
        $value =~ s/%(..)/pack("c",hex($1))/ge;
        $in{$name} = $value;
    }

    # trim whitespace
    for (qw/name email subject/) {
        $in{$_} =~ s/^\s+//;
        $in{$_} =~ s/\s+$//;
        $in{$_} =~ s/\s+/ /g;
    }

    # Windows fix
    $in{'message'} =~ s/\r\n/\n/g;
}

sub formcheck {
    return '' unless $in{'raw'};
    %error = ();
    for (qw/name subject message/) {
        $error{$_} = ' class="error"' unless $in{$_};
    }
    $error{'email'} = ' class="error"' if emailsyntax ($in{'email'}) eq 'ERR';
    return %error ? '' : 'OK';
}

sub emailsyntax {
    return 'ERR' unless (my $localpart = shift) =~ s/^(.+)@(.+)/$1/;
    my $domain = $2;
    my $char = '[^()<>@,;:\/\s"\'&|.]';
    return 'ERR' unless $localpart =~ /^$char+(?:\.$char+)*$/ or $localpart =~ /^"[^",]+"$/;
    return $domain =~ /^$char+(?:\.$char+)+$/ ? '' : 'ERR';
}

sub mailsend {
    # Extra headers
    my @extras = ();
    push @extras, "X-Mailer: CGI::ContactForm $VERSION at $ENV{'HTTP_HOST'}";
    push @extras, "X-Originating-IP: [$ENV{'REMOTE_ADDR'}]" if $ENV{'REMOTE_ADDR'};

    # Make message format=flowed (RFC 2646)
    require Text::Flowed;
    import Text::Flowed 'reformat';
    $in{'message'} = reformat ($in{'message'}, { max_length => 66, opt_length => 66 });
    push @extras, 'MIME-Version: 1.0';
    push @extras, 'Content-type: text/plain; charset=iso-8859-1; format=flowed';

    # Send message
    require Mail::Sender;
    $Mail::Sender::NO_X_MAILER = 1;
    $Mail::Sender::SITE_HEADERS = join ("\r\n", @extras);
    (new Mail::Sender) -> MailMsg ({
        smtp      => $args{'smtp'},
        from      => $args{'recmail'},
        fake_from => namefix ($in{'name'}) . " <$in{'email'}>",
        to        => namefix ($args{'recname'}) . " <$args{'recmail'}>",
        bcc       => $in{'email'},
        subject   => $in{'subject'},
        msg       => $in{'message'},
      }) or die "Error: $Mail::Sender::Error\n$!";

    # Print resulting page
    htmlize ($in{'email'});
    headprint();

    print <<RESULT;
<h3>Thanks for your message!</h3>
<p>The message was sent to <b>$args{'recname'}</b> with a copy to <b>$in{'email'}</b>.</p>
<p class="returnlink"><a href="$args{'returnlinkurl'}">$args{'returnlinktext'}</a></p>
</body>
</html>
RESULT
}

sub formprint {
    (my $scriptname = $0 ? $0 : $ENV{'SCRIPT_FILENAME'}) =~ s/.*[\/\\]//;
    my $erroralert = %error ? "<tr>\n"
      . '<td colspan="4"><p class="center">Fields with <span class="error">'
      . "\nmarked labels</span> need to be filled or corrected!</p></td>\n</tr>" : '';
    for (qw/name email subject message/) {
        if ($in{$_}) {
            htmlize ($in{$_});
        } else {
            $in{$_} = '';
        }
        $error{$_} = '' unless $error{$_};
    }
    headprint();

    # Prevent horizontal scrolling in NS4
    my $softwrap = ($ENV{'HTTP_USER_AGENT'} =~ /Mozilla\/[34]/
      and $ENV{'HTTP_USER_AGENT'} !~ /MSIE|Opera/) ? ' wrap="soft"' : '';

    print <<FORM;
<form action="$scriptname" method="post">
<table cellpadding="3">
<tr>
<td colspan="4"><h3 class="center">Send email to $args{'recname'}</h3></td>
</tr><tr>
<td><p$error{'name'}>Your&nbsp;name:</p></td><td><input type="text" name="name"
 value="$in{'name'}" size="20" />&nbsp;</td>
<td><p$error{'email'}>Your&nbsp;email:</p></td><td><input type="text" name="email"
 value="$in{'email'}" size="20" /></td>
</tr><tr>
<td><p$error{'subject'}>Subject:</p></td>
<td colspan="3"><input type="text" name="subject" value="$in{'subject'}" size="55" /></td>
</tr><tr>
<td colspan="4"><p$error{'message'}>Message:</p></td>
</tr><tr>
<td colspan="4">
<textarea name="message" rows="8" cols="65"$softwrap>$in{'message'}</textarea>
</td>
</tr>$erroralert<tr>
<td colspan="4" class="center">
<input class="button" type="reset" value="Reset" />&nbsp;&nbsp;
<input class="button" type="submit" value="Send" /></td>
</tr><tr>
<td colspan="4"><p class="returnlink"><a href="$args{'returnlinkurl'}">
$args{'returnlinktext'}</a></p></td>
</tr>
</table>
</form>
</body>
</html>
FORM
}

sub headprint {
    my $style = $args{'styleurl'} ?
      "<link rel=\"stylesheet\" type=\"text/css\" href=\"$args{'styleurl'}\" />" : '';

    print <<HEAD;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
                      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Send email to $args{'recname'}</title>
$style
</head>
<body>
HEAD
}

sub htmlize {
    $_[0] =~ s/&/&amp;/g;
    $_[0] =~ s/"/&quot;/g;
    $_[0] =~ s/</&lt;/g;
    $_[0] =~ s/>/&gt;/g;
}

sub namefix {
    my $name = shift;
    if ($name =~ /[^ \w]/) {
        $name =~ tr/"/'/;
        $name = qq{"$name"};
    }
    $name
}

1;

