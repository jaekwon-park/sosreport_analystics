#!/usr/bin/perl

use strict;
use warnings;
use File::Basename qw(dirname);

my $full_path = dirname(__FILE__);
my $filename = ( split "/", $full_path)[4];

system("/var/www/html/libpdf/bin/phantomjs /var/www/html/libpdf/examples/rasterize.js http://sosreport.rp.kr/$filename /var/www/html/pdf/$filename.pdf A4");
#print "Content-type: text/html\n\n";
#print $full_path."\n";
#print $filename."\n";

print "Location:http://sosreport.rp.kr/pdf/";
