# $Id: Makefile.PL,v 1.4 2003/02/12 16:07:42 Gunnar Hjalmarsson Exp $

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'CGI::ContactForm',
    VERSION_FROM      => 'lib/CGI/ContactForm.pm',
    PREREQ_PM         => { Mail::Sender => 0, Text::Flowed => 0 },
);
