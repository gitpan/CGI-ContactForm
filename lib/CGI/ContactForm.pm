package CGI::ContactForm;

# $Id: ContactForm.pm,v 1.30 2003/08/24 11:07:00 Gunnar Hjalmarsson Exp $

=head1 NAME

CGI::ContactForm - Perl extension for generating a web contact form

=head1 SYNOPSIS

    use CGI::ContactForm;

    contactform (
        recname        => 'John Smith',
        recmail        => 'john.smith@domain.com',
        smtp           => 'smtp.domain.com',
        styleurl       => '/style/ContactForm.css',
    );

=head1 DESCRIPTION

This module generates a contact form for the web when the routine C<contactform()>
is called from a CGI script. Arguments are passed to the module as a list of
key/value pairs.

C<CGI::ContactForm> sends a well formated (plain text format=flowed in accordance
with RFC 2646) email message, with the sender's address in the C<From:> header, and
the sender gets a C<bcc> copy. If the email address stated by the sender is invalid,
the failure message is sent to the recipient address, through which you know that
you don't need to bother with a reply, at least not to that address...

=head2 Arguments

C<CGI::ContactForm> takes the following arguments:

                        Default value
                        =============
    Compulsory
    ----------
    recname             (none)
    recmail             (none)
    smtp                (none)

    Optional
    --------
    styleurl            (none)
    returnlinktext      'Main Page'
    returnlinkurl       '/'
    formtmplpath        (none)
    resulttmplpath      (none)
    maxsize             100 (KiB)

    Additional arguments, intended for forms at non-English sites
    -------------------------------------------------------------
    title               'Send email to'
    namelabel           'Your name:'
    emaillabel          'Your email:'
    subjectlabel        'Subject:'
    msglabel            'Message:'
    reset               'Reset'
    send                'Send'
    erroralert          'Fields with %s need to be filled or corrected.'
    marked              'marked labels'
    thanks              'Thanks for your message!'
    sent_to             'The message was sent to %s with a copy to %s.'
    encoding            'iso-8859-1'

=head2 Customization

There are only three compulsory arguments. The example CGI script
C<contact.pl>, that is included in the distribution, also sets the C<styleurl>
argument, assuming the use of the enclosed style sheet C<ContactForm.css>.
That results in a decently styled form with a minimum of effort.

As you can see from the list over available arguments, all the text strings
can be changed, and as regards the presentation, you can of course edit the
style sheet to your liking.

If you want to modify the HTML markup, you can have C<CGI::ContactForm> make
use of one or two templates. The enclosed example templates
C<ContactForm_form.tmpl> and C<ContactForm_result.tmpl> can be activated via
the C<formtmplpath> respective C<resulttmplpath> arguments, and used as a
starting point for a customized markup.

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

Download the distribution file and extract the contents.

=item *

Designate a directory as your local library for Perl modules, for instance

    /www/username/cgi-bin/lib

=item *

Create the directory C</www/username/cgi-bin/lib/CGI>, and upload
C<ContactForm.pm> to that directory.

=item *

In the CGI scripts that use this module, include a line that tells Perl
to look for modules also in your local library, such as

    use lib '/www/username/cgi-bin/lib';

=back

=head2 Other Installation Matters

If you have previous experience from installing CGI scripts, making
C<contact.pl> (or whichever name you choose) work should be easy.
Otherwise, this is a B<very> short lesson:

=over 4

=item 1.

Upload the CGI file in ASCII transfer mode to your C<cgi-bin>.

=item 2.

Set the file permission 755 (chmod 755).

=back

If that doesn't do it, there are many CGI tutorials for beginners
available on the web. This is one example:

    http://my.execpc.com/~keithp/bdlogcgi.htm

On some servers, the CGI file must be located in the C<cgi-bin> directory
(or in a C<cgi-bin> subdirectory). At the same time it's worth noting,
that the style sheet typically needs to be located somewhere outside the
C<cgi-bin>.

=head1 DEPENDENCIES

C<CGI::ContactForm> requires these modules:

    Mail::Sender
    Text::Flowed

(can be downloaded from CPAN http://www.cpan.org/ )

It also requires direct access to an SMTP server.

If C<Mail::Sender> and C<Text::Flowed> need to be installed manually,
you shall create C</www/username/cgi-bin/lib/Mail> and
C</www/username/cgi-bin/lib/Text> and upload C<Sender.pm> respective
C<Flowed.pm> to those directories.

=head1 VERSION HISTORY

=over 4

=item v1.15 (Aug 24, 2003)

Referer check removed, since it made the script fail with certain browsers
while its security value was limited.

=item v1.14 (Jul 10, 2003)

Handling of error messages improved.

=item v1.13 (Jul 1, 2003)

Code cleanup.

=item v1.12 (Apr 11, 2003)

References to the form data for saving memory.

=item v1.11 (Apr 6, 2003)

Markup for 'erroralert' modified for greater flexibility when editing the
form template.

Preparations for mod_perl.

=item v1.10 (Apr 4, 2003)

Template based customization added as an option.

=item v1.03 (Mar 30, 2003)

CGI.pm used for parsing form data.

New argument: 'maxsize' - for limiting the message size.

=item v1.02 (Feb 16, 2003)

DOCTYPE declaration changed to XHTML 1.1.

=item v1.01 (Feb 13, 2003)

CSS validation error corrected.

=item v1.0 (Feb 12, 2003)

Additional arguments added that makes it possible to have the form display
non-English text.

Warnings enabled.

=item v0.4 (Feb 9, 2003)

Error alert message added. Also C<ContactForm.css> was modified for this reason.

Simple test script included in the distribution.

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

  http://search.cpan.org/author/GUNNAR/

  http://www.gunnar.cc/contactform/

=head1 AUTHOR, COPYRIGHT AND LICENSE

  Copyright © 2003 Gunnar Hjalmarsson
  http://www.gunnar.cc/cgi-bin/contact.pl

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

use strict;
use CGI 'escapeHTML';
my (%args, %in, %error);
use vars qw($VERSION @ISA @EXPORT);

$VERSION = '1.15';

use Exporter;
@ISA = 'Exporter';
@EXPORT = 'contactform';

BEGIN {
    sub CFdie($) {
        print "Content-type: text/html\n\n<h1>Error</h1>\n<tt>", shift;
        if ($ENV{MOD_PERL}) {
            eval "use Apache";
            Apache::exit() unless $@;
        }
        exit 1;
    }

    eval "use Mail::Sender";
    my $error = "$@<p>" if $@;
    eval "use Text::Flowed 'reformat'";
    $error .= $@ if $@;
    CFdie($error) if $error;
}

sub contactform {
    MAIN: {
        local $^W = 1;  # enables warnings
        %args = %in = %error = ();
        arguments(@_);
        if ($ENV{REQUEST_METHOD} eq 'POST') {
            formdata();
            if (formcheck() == 0) {
                eval { mailsend() };
                CFdie(escapeHTML(my $msg = $@)) if $@;
                last MAIN;
            }
        }
        formprint();
    }
}

sub arguments {
    my %defaults = (
        recname        => '',
        recmail        => '',
        smtp           => '',
        styleurl       => '',
        returnlinktext => 'Main Page',
        returnlinkurl  => '/',
        formtmplpath   => '',
        resulttmplpath => '',
        maxsize        => 100,
        title          => 'Send email to',
        namelabel      => 'Your name:',
        emaillabel     => 'Your email:',
        subjectlabel   => 'Subject:',
        msglabel       => 'Message:',
        reset          => 'Reset',
        send           => 'Send',
        erroralert     => 'Fields with %s need to be filled or corrected.',
        marked         => 'marked labels',
        thanks         => 'Thanks for your message!',
        sent_to        => 'The message was sent to %s with a copy to %s.',
        encoding       => 'iso-8859-1',
    );
    my $error = '';
    {
        local $SIG{__WARN__} = sub { die $_[0] };
        eval { %args = (%defaults, @_) };
        $error .= "$@The module expects a number of key/value pairs.\n" if $@;
    }
    for (qw/recname recmail smtp/) {
        $error .= "The compulsory argument '$_' is missing.\n" unless $args{$_};
    }
    for (keys %args) {
        $error .= "Unknown argument: '$_'\n" unless defined $defaults{$_};
    }
    if ($args{recmail} and emailsyntax($args{recmail})) {
        $error .= "'$args{recmail}' is not a valid email address.\n";
    }
    for ('formtmplpath', 'resulttmplpath') {
        if ($args{$_} and !-f $args{$_}) {
            $error .= "Argument '$_': Can't find the file $args{$_}\n";
        }
    }

    CFdie("<pre>$error" . <<EXAMPLE

Example:

    contactform (
        recname => 'John Smith',
        recmail => 'john.smith\@domain.com',
        smtp    => 'smtp.domain.com',
    );
EXAMPLE

    ) if $error;
}

sub formdata {
    my $size = $ENV{CONTENT_LENGTH} ? $ENV{CONTENT_LENGTH} : (stat(STDIN))[7];
    if ($size > 1024 * $args{maxsize}) {
        CFdie("The message size exceeds the $args{maxsize} KiB limit.\n"
              . '<p><a href="javascript:history.back(1)">Back</a>');
    }

    # create hash of references to the form data
    my $o = new CGI(\*STDIN);
    $in{$_} = \$o->{$_}[0] for $o->param;

    # trim whitespace in message headers
    for (qw/name email subject/) {
        ${$in{$_}} =~ s/^\s+//;
        ${$in{$_}} =~ s/\s+$//;
        ${$in{$_}} =~ s/\s+/ /g;
    }
}

sub formcheck {
    for (qw/name subject message/) { $error{$_} = ' class="error"' unless ${$in{$_}} }
    $error{email} = ' class="error"' if emailsyntax(${$in{email}});
    return %error ? 1 : 0;
}

sub emailsyntax {
    return 1 unless my ($localpart, $domain) = shift =~ /^(.+)@(.+)/;
    my $char = '[^()<>@,;:\/\s"\'&|.]';
    return 1 unless $localpart =~ /^$char+(?:\.$char+)*$/ or $localpart =~ /^"[^",]+"$/;
    return $domain =~ /^$char+(?:\.$char+)+$/ ? 0 : 1;
}

sub mailsend {
    # Extra headers
    my @extras = ();
    push @extras, "X-Mailer: CGI::ContactForm $VERSION at $ENV{HTTP_HOST}";
    push @extras, "X-Originating-IP: [$ENV{REMOTE_ADDR}]" if $ENV{REMOTE_ADDR};

    # Make message format=flowed (RFC 2646)
    ${$in{message}} = reformat(${$in{message}}, { max_length => 66, opt_length => 66 });
    push @extras, 'MIME-Version: 1.0';
    push @extras, "Content-type: text/plain; charset=$args{encoding}; format=flowed";

    # Send message
    $Mail::Sender::NO_X_MAILER = 1;
    $Mail::Sender::SITE_HEADERS = join "\r\n", @extras;
    (new Mail::Sender) -> MailMsg ({
        smtp      => $args{smtp},
        from      => $args{recmail},
        fake_from => namefix(${$in{name}}) . " <${$in{email}}>",
        to        => namefix($args{recname}) . " <$args{recmail}>",
        bcc       => ${$in{email}},
        subject   => ${$in{subject}},
        msg       => ${$in{message}},
    }) or die "Cannot send mail.\n$Mail::Sender::Error\n";

    # Print resulting page
    my $sent_to = sprintf escapeHTML($args{sent_to}), '<b>'
      . escapeHTML($args{recname}) . '</b>', '<b>' . escapeHTML(${$in{email}}) . '</b>';
    my @resultargs = qw/recname returnlinktext returnlinkurl title thanks/;
    $args{$_} = escapeHTML($args{$_}) for @resultargs;
    $args{returnlinkurl} =~ s/ /%20/g;
    if ($args{resulttmplpath}) {
        my %result_vars = ();
        $result_vars{style} = \stylesheet();
        $result_vars{sent_to} = \$sent_to;
        $result_vars{$_} = \$args{$_} for @resultargs;
        templateprint($args{resulttmplpath}, %result_vars);
    } else {
        headprint();

        print <<RESULT;
<h1>$args{thanks}</h1>
<p>$sent_to</p>
<p class="returnlink"><a href="$args{returnlinkurl}">$args{returnlinktext}</a></p>
</body>
</html>
RESULT
    }
}

sub formprint {
    (my $scriptname = $0 ? $0 : $ENV{SCRIPT_FILENAME}) =~ s/.*[\/\\]//;
    my $erroralert = %error ? '<p class="erroralert">'
      . sprintf (escapeHTML($args{erroralert}), '<span class="error">'
      . "\n" . escapeHTML($args{marked}) . '</span>') . '</p>' : '';
    my @formargs = qw/recname returnlinktext returnlinkurl title namelabel
                      emaillabel subjectlabel msglabel reset send/;
    $args{$_} = escapeHTML($args{$_}) for @formargs;
    $args{returnlinkurl} =~ s/ /%20/g;
    for (qw/name email subject message/) {
        ${$in{$_}} = $in{$_} ? escapeHTML(${$in{$_}}) : '';
        $error{$_} ||= '';
    }

    # Prevent horizontal scrolling in NS4
    my $softwrap = ($ENV{HTTP_USER_AGENT} =~ /Mozilla\/[34]/
      and $ENV{HTTP_USER_AGENT} !~ /MSIE|Opera/) ? ' wrap="soft"' : '';

    if ($args{formtmplpath}) {
        my %form_vars = ();
        $form_vars{style} = \stylesheet();
        $form_vars{scriptname} = \$scriptname;
        $form_vars{erroralert} = \$erroralert;
        $form_vars{$_} = \$args{$_} for @formargs;
        for (qw/name email subject message/) {
            $form_vars{$_} = $in{$_};
            $form_vars{$_.'error'} = \$error{$_};
        }
        $form_vars{softwrap} = \$softwrap;
        templateprint($args{formtmplpath}, %form_vars);
    } else {
        headprint();

        print <<FORM;
<form action="$scriptname" method="post">
<table cellpadding="3">
<tr>
<td colspan="4"><h1 class="halign">$args{title} $args{recname}</h1></td>
</tr><tr>
<td><p$error{name}>$args{namelabel}</p></td><td><input type="text" name="name"
 value="${$in{name}}" size="20" />&nbsp;</td>
<td><p$error{email}>$args{emaillabel}</p></td><td><input type="text" name="email"
 value="${$in{email}}" size="20" /></td>
</tr><tr>
<td><p$error{subject}>$args{subjectlabel}</p></td>
<td colspan="3"><input type="text" name="subject" value="${$in{subject}}" size="55" /></td>
</tr><tr>
<td colspan="4"><p$error{message}>$args{msglabel}</p></td>
</tr><tr>
<td colspan="4">
<textarea name="message" rows="8" cols="65"$softwrap>${$in{message}}</textarea>
</td>
</tr><tr>
<td colspan="4" class="halign">
$erroralert
<input class="button" type="reset" value="$args{reset}" />&nbsp;&nbsp;
<input class="button" type="submit" value="$args{send}" /></td>
</tr><tr>
<td colspan="4"><p class="returnlink"><a href="$args{returnlinkurl}">
$args{returnlinktext}</a></p></td>
</tr>
</table>
</form>
</body>
</html>
FORM
    }
}

sub headprint {
    print "Content-type: text/html; charset=$args{encoding}\n\n";
    print <<HEAD;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
                      "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$args{title} $args{recname}</title>
<style type="text/css">
.error { font-weight: bold }
</style>
${\stylesheet()}
</head>
<body>
HEAD
}

sub stylesheet {
    ($args{styleurl} = escapeHTML($args{styleurl})) =~ s/ /%20/g;
    return $args{styleurl} ? '<link rel="stylesheet" type="text/css" href="'
      . "$args{styleurl}\" />" : '';
}

sub templateprint {
    my ($template, %tmpl_vars) = @_;
    my $error = '';
    open FH, "< $template" or die "Can't open $template\n$!";
    my $output = join '', <FH>;
    close FH;
    $output =~ s[<(?:!--\s*)?tmpl_var\s*(?:name\s*=\s*)?
                 (?:"([^">]*)"|'([^'>]*)'|([^\s=>]*))
                 \s*(?:--)?>][
        my $value = $1 ? $1 : ($2 ? $2 : $3);
        if ($tmpl_vars{lc $value}) {
            ${$tmpl_vars{lc $value}};
        } else {
            $error .= "Unknown template variable: '$value'\n";
        }
    ]egix;
    CFdie("<pre>$error") if $error;
    print "Content-type: text/html; charset=$args{encoding}\n\n";
    print $output;
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

