# $Id: Makefile.PL,v 1.1.1.1 2003/02/03 08:22:38 Gunnar Hjalmarsson Exp $

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'CGI::ContactForm',
    VERSION_FROM      => 'lib/CGI/ContactForm.pm',
    PREREQ_PM         => { Mail::Sender => 0, Text::Flowed => 0 },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/CGI/ContactForm.pm',
       AUTHOR         => 'Gunnar Hjalmarsson <http://www.gunnar.cc/cgi-bin/contact.pl>'
      ) : ()
    ),
);
