#!/usr/bin/perl
use lib 'lib';
use CGI::ContactForm;

contactform (
    recname   => 'John Smith',
    recmail   => 'john.smith@domain.com',
    smtp      => 'smtp.domain.com',
    styleurl  => '/style/ContactForm.css',
);

# $Id: contact.pl,v 1.1.1.1 2003/02/03 08:22:38 Gunnar Hjalmarsson Exp $
