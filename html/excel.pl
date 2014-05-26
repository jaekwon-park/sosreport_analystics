#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use File::Copy;                 # 파일 복사를 위한 모듈 
use File::Path;                 # 디렉토리 통째 삭제를 위한 모듈 
use File::stat;                 # 디렉토리 통째 삭제를 위한 모듈 
use Encode;                     # 한글 변환을 위한 모듈 
use Encode::Locale;             # 한글 변환을 위한 모듈 
use utf8;                       # 한글 변환을 위한 모듈 
use Excel::Writer::XLSX;     


my $index_file="/var/www/html/sh/data/index.txt";
my $workbook=Excel::Writer::XLSX -> new('/var/www/html/index.xlsx');
#$workbook->set_optimization();
my $worksheet = $workbook -> add_worksheet('정기점검');
#$worksheet->set_column( 0, 0, 'hostname' );

my $title = $workbook->add_format(bg_color => 13, pattern =>1, border=>7);
my $right_line= $workbook->add_format(bg_color=>9, pattern=>1);
my $last_line= $workbook->add_format(bg_color=>9, pattern=>1);
$last_line->set_right(1);

# index 저장 파일 읽기
my @index_data = read_line_file($index_file);
$worksheet->write(0,0,'hostname',$title);
$worksheet->write(0,1,'os',$title);
$worksheet->write(0,2,'kernel version',$title);
$worksheet->write(0,3,'arch',$title);
$worksheet->write(0,4,'cpu',$title);
$worksheet->write(0,5,'memory',$title);
$worksheet->write(0,6,'used',$title);
$worksheet->write(0,7,'사용률',$title);
$worksheet->write(0,8,'uptime',$title);
$worksheet->write(0,9,'kdump',$title);
$worksheet->write(0,10,'daemon',$title);
$worksheet->write(0,11,'warn',$title);
$worksheet->write(0,12,'fail',$title);
$worksheet->write(0,13,'error',$title);

# hostname
for (my $i=0; $i<= $#index_data; $i++) {
	my $hostname = (split ":", $index_data[$i])[0];
	$hostname = (split ">", $hostname)[1];
	$hostname = (split "<", $hostname)[0];
	$worksheet->write($i+1,0,$hostname,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,0,$hostname,$bottom_line);
	}		
}
for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[1];
	$worksheet->write($i+1,'1',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,1,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[2];
	$worksheet->write($i+1,'2',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,2,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[3];
	$worksheet->write($i+1,'3',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,3,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[4];
	$worksheet->write($i+1,'4',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,4,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[5];
	$worksheet->write($i+1,'5',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,5,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[6];
	$worksheet->write($i+1,'6',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,6,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[7];
	$worksheet->write($i+1,'7',$data."%",$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,7,$data."%",$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[8];
	$worksheet->write($i+1,'8',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,8,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[9];
	$worksheet->write($i+1,'9',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,9,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[10];
	$worksheet->write($i+1,'10',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,10,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[11];
	$worksheet->write($i+1,'11',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,11,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[12];
	$worksheet->write($i+1,'12',$data,$right_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$worksheet->write($i+1,12,$data,$bottom_line);
	}		
}

for (my $i=0; $i<= $#index_data; $i++) {
	my $data = (split ":", $index_data[$i])[13];
	$worksheet->write($i+1,'13',$data,$last_line);
	if ($i == $#index_data) {
		my $bottom_line= $workbook->add_format(bg_color=>9, pattern=>1);
		$bottom_line->set_bottom(1);
		$bottom_line->set_right(1);
		$worksheet->write($i+1,13,$data,$bottom_line);
	}		
}


sub read_line_file {
	my ($filename) = @_;
	open my $in , '<:encoding(console_in)', $filename or die "could not open '$filename' for reading $!";
	chomp (my @all = grep /\S/, readline($in));
	close $in;
return @all;
}

