#!/usr/bin/perl -T
use lib '/www/jsmith/cgi-bin/lib';

use CGI::ContactForm;

contactform (
    recname   => 'John Smith',
    recmail   => 'john.smith@domain.com',
    smtp      => 'smtp.domain.com',
    styleurl  => '/style/ContactForm.css',
);

# $Id: contact.pl,v 1.3 2003/02/12 19:35:06 Gunnar Hjalmarsson Exp $
