# $Id: Makefile.PL,v 1.3 2003/02/09 06:36:19 Gunnar Hjalmarsson Exp $

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
