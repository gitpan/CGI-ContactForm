#!/usr/bin/perl -T
use CGI::Carp 'fatalsToBrowser';

use lib '/www/jsmith/cgi-bin/lib';
use CGI::ContactForm;

contactform (
    recname   => 'John Smith',
    recmail   => 'john.smith@domain.com',
    smtp      => 'smtp.domain.com',
    styleurl  => '/style/ContactForm.css',
);

# $Id: contact.pl,v 1.4 2003/04/04 21:31:28 Gunnar Hjalmarsson Exp $
