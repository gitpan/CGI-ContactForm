# $Id: Makefile.PL,v 1.2 2003/02/06 13:16:25 Gunnar Hjalmarsson Exp $

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'CGI::ContactForm',
    VERSION_FROM      => 'lib/CGI/ContactForm.pm',
    PREREQ_PM         => { Mail::Sender => 0, Text::Flowed => 0 },
);
