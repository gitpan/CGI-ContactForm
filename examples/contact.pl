#!/usr/bin/perl -T
use CGI::Carp 'fatalsToBrowser';

use lib '/www/jsmith/cgi-bin/lib';
use CGI::ContactForm;

contactform (
    recname   => 'John Smith',
    recmail   => 'john.smith@domain.com',
    styleurl  => '/style/ContactForm.css',
);

# $Id: contact.pl,v 1.5 2004/03/15 01:09:12 Gunnar Hjalmarsson Exp $
