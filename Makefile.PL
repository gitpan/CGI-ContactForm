# $Id: Makefile.PL,v 1.5 2004/01/14 13:10:52 Gunnar Hjalmarsson Exp $

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'CGI::ContactForm',
    VERSION_FROM      => 'lib/CGI/ContactForm.pm',
    PREREQ_PM         => { Mail::Sender => 0, Text::Flowed => 0 },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/CGI/ContactForm.pm',
       AUTHOR         => 'Gunnar Hjalmarsson <cpan@gunnar.cc>'
      ) : ()
    ),
);
