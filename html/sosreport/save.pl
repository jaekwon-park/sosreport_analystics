#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use File::Basename qw(dirname);
use Encode;                     # 한글 변환을 위한 모듈 
use Encode::Locale;             # 한글 변환을 위한 모듈 
use utf8;  

my $full_path = dirname(__FILE__);
my $filename = ( split "/", $full_path)[4];

my $q = CGI->new;
$q->charset('utf-8');
my $comment =decode("utf-8",$q-> param('comment'));

#print "Content-type: text/html\n\n";
#print $full_path."\n";
#print $filename."\n";

open my $out, '>:encoding(utf-8)', "/var/www/html/".$filename."/sh/data/comment.txt" or die "Could not open for writing $!";
print $out $comment;
close $out;


print $q->redirect("http://192.168.100.183/".$filename);
