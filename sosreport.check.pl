#!/usr/bin/perl

use strict;
#use warnings;
#use diagnostics;

use Archive::Extract; 		# 압축 해제를 위한 모듈 
use File::Copy;  		# 파일 복사를 위한 모듈 
use File::Path;  		# 디렉토리 통째 삭제를 위한 모듈 
use File::stat;  		# 디렉토리 통째 삭제를 위한 모듈 
use Encode;	 		# 한글 변환을 위한 모듈 
use Encode::Locale;		# 한글 변환을 위한 모듈 
use Encode::Guess qw/euc-kr utf8 ascii cp949/;
use utf8; 			# 한글 변환을 위한 모듈 
use Time::Local; 		# 현재 시간을 구하기 위한 모듈 
use POSIX;			# df 정보 foramtting을 위한 모듈 
use Number::Format qw(:subs); 	# df 정보 formatting 을 위한 모듈 
#use Thread;


# 스크립에서 사용할 경로 변수들 지정 
my $sosreport_dir="/storage/sosreport"; 			# sosreport 를 읽어들일 경로
my $sosreport_mv_job_done_dir="/storage/sosreport/done/"; 	# 분석이 끝난 sosreport 를 이동 시킬 폴더 
my $sosreport_mv_job_fail_dir="/storage/sosreport/failed/"; 	# 분석이 끝난 sosreport 를 이동 시킬 폴더 
my $sosreport_extract_dir="/tmp/sosreport/"; 				# sosreport 압축 해제할 디렉토리
my $homepage_index="/var/www/html/";

# 스크립에서 사용할 경로 변수 쓰기
my $hostname_save="hostname.txt";
my $uptime_save="uptime.txt";
my $lsb_release_save="lsb_release.txt";
my $uname_save="uname.txt";
my $arch_save="arch.txt";
my $cpu_name_save="cpu_model.txt";
my $cpu_count_save="cpu_count.txt";
my $nic_info_save="nic_info.txt";
my $grub_save="grub.txt";
my $daemon_list_save="daemon_list.txt";
my $memory_save="mem.txt";
my $sysctl_save="sysctl.txt";
my $kdump_save="kdump.txt";
my $bonding_save="bonding.txt";
my $bond_status_save="bond_status.txt";
my $df_save="df.txt";
my $route_save="route.txt";
my $netstat_save="netstat.txt";
my $ps_save="ps.txt";
my $error_save="error.txt";
my $warn_save="warn.txt";
my $fail_save="fail.txt";
my $load_average_save="load_average.txt";
my $comment_save="comment.txt";
my $sar_cpu_user_save="sar_cpu_user.txt";
my $sar_cpu_system_save="sar_cpu_system.txt";
my $sar_cpu_iowait_save="sar_cpu_iowait.txt";
my $sar_cswch_save="sar_cswsh.txt";
my $sar_memfree_save="sar_memfree.txt";
my $sar_memused_save="sar_memused.txt";
my $sar_membuffer_save="sar_membuffer.txt";
my $sar_memcache_save="sar_memcache.txt";
my $sar_memswap_save="sar_memswap.txt";
my $sar_load15_save="sar_load15.txt";
my $sar_load5_save="sar_load5.txt";
my $sar_load1_save="sar_load1.txt";

# 스크립에서 사용할 경로 변수 읽기
my $cpu_info_file="/proc/cpuinfo";
my $lsb_release_file="/sos_commands/lsbrelease/lsb_release";
my $hostname_file="/sos_commands/general/hostname";
my $meminfo_file="/sos_commands/memory/free";
my $uptime_file="/sos_commands/general/uptime";
my $messages_file="/var/log/messages";
my $uname_file="/sos_commands/kernel/uname_-a";
my $netstat_file="/sos_commands/networking/netstat_-neopa";
my $network_file="/sos_commands/networking/";
my $bonding_file="/proc/net/bonding/";
my $chkconfig_file="/sos_commands/startup/chkconfig_--list";
my $df_file="/sos_commands/filesys/df_-al";
my $ifconfig_file="/sos_commands/networking/ifconfig_-a";
my $ipaddress_file="/sos_commands/networking/ip_address";
my $grub_file="/boot/grub/grub.conf";
my $sysctl_file="/etc/sysctl.conf";
my $kdump_file="/etc/kdump.conf";
my $route_file="/sos_commands/networking/route_-n";
my $mount_file="/sos_commands/filesys/mount_-l";
my $ps_file="/sos_commands/process/ps_auxwww";
my $sar_dir_file="/var/log/sa/";
my $filesystem_dir_file="/sos_commands/filesys/";

#html 파일을 만들 템플릿 파일 읽어오기 
chdir "$homepage_index"."sosreport" || die "can't cd $homepage_index";
my @homepage_sh_file_list = glob ("sh/*.php");
my @homepage_js_file_list = glob ("js/*.js");

#chdir "$sosreport_dir" || die "can't cd $sosreport_dir"; # sosreport 가 저장되어 있는 경로 확인 및 해당 디렉토리로 작업 경로 이동
my @sosreport_file_list = glob ( $sosreport_dir."/*.tar.*"); # sosreport 가 저장되어 있는 경로에서 sosreport 들을 배열로 읽어 들임

rmtree $sosreport_extract_dir."*";

# 배열로 읽어들인 sosreport 들의 압축을 해제함 
for (my $i=0; $i<=$#sosreport_file_list; $i++) {
	my $now = strftime "%F %H:%M:%S",localtime;
	print $now." ".$sosreport_file_list[$i]." starting extract! \n";
	my $sosreport = Archive::Extract -> new(archive => $sosreport_file_list[$i]); # 압축해제를 위한 압축파일 인식 
	my $extract_ok = $sosreport -> extract ( to => $sosreport_extract_dir ) or die failed_extract($sosreport_file_list[$i],$sosreport_mv_job_fail_dir,$sosreport_file_list[$i]); # 압축파일 해제
	my $extract_dir = $sosreport-> extract_path; 						# sosreport 압축 해제한 디렉토리명을 구함
#	print  $sosreport_mv_job_done_dir.(split "/", $sosreport_file_list[$i])[3]."\n";
	if ( -e $sosreport_mv_job_done_dir.(split "/", $sosreport_file_list[$i])[3] ) {
		my $now = strftime "%F %H:%M:%S",localtime;
		unlink $sosreport_mv_job_done_dir.(split "/", $sosreport_file_list[$i])[3] or die "remove sosreport fail ".$sosreport_mv_job_done_dir.(split "/", $sosreport_file_list[$i])[3]." from done folder $!";
		print $now." ".(split "/", $sosreport_file_list[$i])[3]." delete from done folder \n";
	}
	move($sosreport_file_list[$i], $sosreport_mv_job_done_dir) or die "Move failed $!"; 	# 압축 해제한 sosreport 를 이동함
	$now = strftime "%F %H:%M:%S",localtime;
	print $now." ".$sosreport_file_list[$i]." extract done\n";
	
	my $sosreport_name = (split "/" ,$extract_dir)[3]; 					# sosreport의 이름을 변수로 받아옴 
	my $sosreport_save_pwd=$homepage_index.$sosreport_name."/sh/data/"; # sosreport 분석 결과를 저장할 디렉토리 
	# 예전에 남아있던 폴더를 확인해서 있으면 삭제함 
	if ( $sosreport_name != "" ){
		my $now = strftime "%F %H:%M:%S",localtime;
		print $now." "."sosreport name is empty\n";	
	}
	else {
		if ( -e $homepage_index.$sosreport_name ) {
			rmtree $homepage_index.$sosreport_name or die "remove dir fail $homepage_index.$sosreport_name $!";
		}	
	}
	# sosreport 웹페이지 만들기에 필요한 디렉토리 및 파일 복사 
	mkdir $homepage_index.$sosreport_name or die "mkdir faild $homepage_index$sosreport_name";
	mkdir $homepage_index.$sosreport_name."/sh" or die "mkdir faild $homepage_index$sosreport_name"."/sh";
	mkdir $homepage_index.$sosreport_name."/js" or die "mkdir faild $homepage_index$sosreport_name"."/js";
	mkdir $homepage_index.$sosreport_name."/sh/data" or die "mkdir faild $homepage_index$sosreport_name"."/sh/data";
	# sh, js 파일들만 복사 css파일들은 index.html 에서 참조하여 복사하지 않음 
	copy $homepage_index."sosreport/index.html", $homepage_index.$sosreport_name."/index.html" or die "copy failed";
	copy $homepage_index."sosreport/comment.html", $homepage_index.$sosreport_name."/comment.html" or die "copy failed";
	copy $homepage_index."sosreport/convert.pl", $homepage_index.$sosreport_name."/convert.pl" or die "copy failed";
	copy $homepage_index."sosreport/save.pl", $homepage_index.$sosreport_name."/save.pl" or die "copy failed";
	for (my $i=0; $i<=$#homepage_js_file_list; $i++) {
		copy $homepage_index."sosreport/".$homepage_js_file_list[$i], $homepage_index.$sosreport_name."/".$homepage_js_file_list[$i] or die "copy failed";
	}
	for (my $i=0; $i<=$#homepage_sh_file_list; $i++) {
		copy $homepage_index."sosreport/".$homepage_sh_file_list[$i], $homepage_index.$sosreport_name."/".$homepage_sh_file_list[$i] or die "copy failed";
	}
	
	# 기본적인 엔지니어 의견 저장 
#	write_file($sosreport_save_pwd.$comment_save,"특이사항 없습니다.");
	# message 로그 파일이 없을시 message 파일 생성
	if ( !-e $extract_dir.$messages_file) {
		my $today = strftime "%m %d %H:%M:%S",localtime;
		write_file($extract_dir.$messages_file,$today." ".$sosreport_name."sosreport: rockPLACE "." warning: sosreport에 message 로그 파일이 수집 되지 않았습니다.");
	}
	if ( !-e $extract_dir.$lsb_release_file) {
		my $today = strftime "%m %d %H:%M:%S",localtime;
		mkdir $extract_dir."/sos_commands/lsbrelease/";
		write_file($extract_dir.$lsb_release_file,"Description:	lsb_release file does't exist");			
	}
	if ( !-e $extract_dir.$kdump_file) {
		mkdir $extract_dir."/etc";
		write_file($extract_dir.$kdump_file,"kdump.conf file does't exist");			
	}



	#필요한 파일들 배열로 읽어들이기 기본적으로 한줄이 배열 하나에 들어감 
	my @cpu_info_data = read_line_file($extract_dir.$cpu_info_file);
	my @os_ver_data = read_line_file($extract_dir.$lsb_release_file);
	my @hostname_data = read_line_file($extract_dir.$hostname_file);
	my @meminfo_data = read_line_file($extract_dir.$meminfo_file);
	my @uptime_data = read_line_file($extract_dir.$uptime_file);
	my @messages_data = read_line_file($extract_dir.$messages_file);
	my @uname_data = read_line_file($extract_dir.$uname_file);
	my @netstat_data = read_line_file($extract_dir.$netstat_file);
	my @chkconfig_list_data = read_line_file($extract_dir.$chkconfig_file);
	my @network_nic_list = glob($extract_dir.$network_file."ethtool_eth*");
	my @bonding_list = glob($extract_dir.$bonding_file."bond*");
	my @network_ifconfig_list = read_line_file($extract_dir.$ifconfig_file);
	my @network_ip_list= read_line_file($extract_dir.$ipaddress_file);
	my @grub_data= read_line_file($extract_dir.$grub_file);
	my @sysctl_data= read_line_file($extract_dir.$sysctl_file);
	my @kdump_data= read_line_file($extract_dir.$kdump_file);
	my @route_data= read_line_file($extract_dir.$route_file);
	my @df_data = read_line_file($extract_dir.$df_file);
	my @mount_data = read_line_file($extract_dir.$mount_file);
	my @ps_data = read_line_file($extract_dir.$ps_file);
	my @sar_file_list = glob ($extract_dir.$sar_dir_file."sar*");


	# sar 정보 분석 sar 하나씩 분석해서 별도 파일로 정규화 시킴 
	for ( my $i=0; $i<= $#sar_file_list; $i++) {
		my @sar_data = read_line_file($sar_file_list[$i]);
		foreach(@sar_data){		# sar파일을 읽어온 배열 @sar_data에 공백을 comma로 바꿈
			s/\s+/,/g;
		}
		# cpu usage user
		my @sar_cpu_data = grep /^\d+:\d+:\d+\,all,/ , @sar_data; # @sar_data에서 cpu 사용률 부분만 따로 @sar_cpu_data로 저장
		my ($sar_cpu_string) = join "#", @sar_cpu_data;
		save_sar_data($sar_cpu_string,$sosreport_save_pwd.$sar_cpu_user_save,2);
		save_sar_data($sar_cpu_string,$sosreport_save_pwd.$sar_cpu_system_save,4);
		save_sar_data($sar_cpu_string,$sosreport_save_pwd.$sar_cpu_iowait_save,5);
		# 배열에 라인 구분자 # 붙여서 스트링으로 변환
		my $sar_data_string = join "#", @sar_data;
		# context switch 부분
		my ($sar_data_cswch) = $sar_data_string =~ m/cswch\/s#(.*?)Average/s;
		save_sar_data($sar_data_cswch, $sosreport_save_pwd.$sar_cswch_save,1);
		# memory 부분
		my ($sar_data_memory) = $sar_data_string =~ m/kbswpcad#(.*?)Average/s;
		save_sar_data($sar_data_memory,$sosreport_save_pwd.$sar_memfree_save,1);
		save_sar_data($sar_data_memory,$sosreport_save_pwd.$sar_memused_save,3);
		save_sar_data($sar_data_memory,$sosreport_save_pwd.$sar_membuffer_save,4);
		save_sar_data($sar_data_memory,$sosreport_save_pwd.$sar_memcache_save,5);
		save_sar_data($sar_data_memory,$sosreport_save_pwd.$sar_memswap_save,8);
		my ($sar_data_loadavg) = $sar_data_string =~ m/ldavg-15#(.*?)Average/s;
		save_sar_data($sar_data_loadavg,$sosreport_save_pwd.$sar_load15_save,5);
		save_sar_data($sar_data_loadavg,$sosreport_save_pwd.$sar_load5_save,4);
		save_sar_data($sar_data_loadavg,$sosreport_save_pwd.$sar_load1_save,3);
	}	



	#chart header 에 쓰일 title
	foreach(@sar_file_list) {
		s/\/tmp\/sosreport\/$sosreport_name\/var\/log\/sa\/sar/'/g;
	}
	my $user_title = join "',",@sar_file_list;

	#chart 만들기 함수
	make_percent_chart_js("cpu_user",$sosreport_save_pwd.$sar_cpu_user_save,$user_title,$homepage_index.$sosreport_name);
	make_percent_chart_js("cpu_iowait",$sosreport_save_pwd.$sar_cpu_iowait_save,$user_title,$homepage_index.$sosreport_name);
	make_percent_chart_js("cpu_system",$sosreport_save_pwd.$sar_cpu_system_save,$user_title,$homepage_index.$sosreport_name);
	make_chart_js("cswch",$sosreport_save_pwd.$sar_cswch_save,$user_title,$homepage_index.$sosreport_name);
	make_chart_js("mem_free",$sosreport_save_pwd.$sar_memfree_save,$user_title,$homepage_index.$sosreport_name);
	make_percent_chart_js("mem_used",$sosreport_save_pwd.$sar_memused_save,$user_title,$homepage_index.$sosreport_name);
	make_chart_js("mem_buffer",$sosreport_save_pwd.$sar_membuffer_save,$user_title,$homepage_index.$sosreport_name);
	make_chart_js("mem_cache",$sosreport_save_pwd.$sar_memcache_save,$user_title,$homepage_index.$sosreport_name);
	make_percent_chart_js("mem_swap",$sosreport_save_pwd.$sar_memswap_save,$user_title,$homepage_index.$sosreport_name);
	make_chart_js("ldavg_15",$sosreport_save_pwd.$sar_load15_save,$user_title,$homepage_index.$sosreport_name);
	make_chart_js("ldavg_5",$sosreport_save_pwd.$sar_load5_save,$user_title,$homepage_index.$sosreport_name);
	make_chart_js("ldavg_1",$sosreport_save_pwd.$sar_load1_save,$user_title,$homepage_index.$sosreport_name);

	# 아래쪽은 완성 됨 #########################
	# bonding 정보 구하기
	for (my $i=0; $i <= $#bonding_list; $i++) {
		my @bonding_data = read_line_file($bonding_list[$i]);
		$bonding_list[$i] = substr($bonding_list[$i], index ($bonding_list[$i],"bond"));
		my @bonding_name = split ("/", $bonding_list[$i]);
		my @bonding_slave_name = grep {/Interface:/} @bonding_data;
		@bonding_slave_name = regular_bond(@bonding_slave_name);

		my @bonding_slave_mac= grep {/addr:/} @bonding_data;
		@bonding_slave_mac= regular_bond(@bonding_slave_mac);

		my @bonding_fail= grep {/Count:/} @bonding_data;
		@bonding_fail= regular_bond(@bonding_fail);

		my @bonding_mode= grep {/Mode:/} @bonding_data;
		@bonding_mode= regular_bond(@bonding_mode);

		my @bonding_active = grep {/Active Slave:/} @bonding_data;
		@bonding_active = regular_bond(@bonding_active);

		my @bonding_interval= grep {/Polling/} @bonding_data;
		@bonding_interval= regular_bond(@bonding_interval);

		my @bonding_ip_address = grep {/inet/} @network_ip_list; # ip 구하기 
		@bonding_ip_address = grep {/$bonding_name[1]/} @bonding_ip_address;
		my @bonding_ip = split(" ", $bonding_ip_address[0]);
		for ( my $bond_slave_count=0; $bond_slave_count <= $#bonding_slave_name;$bond_slave_count++) {
			write_file($sosreport_save_pwd.$bonding_save,join (",",$bonding_name[1],$bonding_slave_name[$bond_slave_count],$bonding_fail[$bond_slave_count],$bonding_slave_mac[$bond_slave_count]."\n"));
		}
	write_file($sosreport_save_pwd.$bond_status_save,join (",",$bonding_name[1],$bonding_mode[0],$bonding_active[0],$bonding_interval[0],$bonding_ip[1]."\n"));
	}		

	# nic 정보 구하기 
	for (my $nic_count=0; $nic_count <= $#network_nic_list; $nic_count++) {
		my @network_nic_data = read_line_file($network_nic_list[$nic_count]);
		my @network_nic_speed = grep {/Speed/} @network_nic_data;
		($network_nic_speed[0]) = (split ":", $network_nic_speed[0])[1];
		my @network_nic_duplex = grep {/Duplex/} @network_nic_data;
		($network_nic_duplex[0]) = (split ":", $network_nic_duplex[0])[1];
		my @network_nic_port = grep {/Port/} @network_nic_data;
		($network_nic_port[0]) = (split ":", $network_nic_port[0])[1];
		my @network_nic_auto = grep {/Auto/} @network_nic_data;
		($network_nic_auto[0]) = (split ":", $network_nic_auto[0])[1];
		my @network_nic_link= grep {/Link detected/} @network_nic_data;
		($network_nic_link[0]) = (split ":", $network_nic_link[0])[1];
		my($network_nic_name) = substr($network_nic_list[$nic_count], index ($network_nic_list[$nic_count],"_eth"));
		$network_nic_name =~ s/_//;
		my @network_mac_address = grep {/$network_nic_name/} @network_ifconfig_list;
		($network_mac_address[0],) = (split " ", $network_mac_address[0])[4];
		my @network_ip_address = grep {/inet/} @network_ip_list; # ip list 
		@network_ip_address = grep {/$network_nic_name/} @network_ip_address;
		($network_ip_address[0]) = (split " ", $network_ip_address[0])[1];
		write_file($sosreport_save_pwd.$nic_info_save, join(",",$network_nic_name,array_print(@network_nic_speed),array_print(@network_nic_duplex),array_print(@network_nic_port),array_print(@network_nic_auto),array_print(@network_nic_link),$network_ip_address[0],$network_mac_address[0],"\n"));
	}

	# cpu model 이름 구하기
	my @cpu_model_name = grep {/name/} @cpu_info_data;
	$cpu_model_name[0] = (split ":", $cpu_model_name[0])[1];
	
	# sysctl 값 구하기
	@sysctl_data = grep {!/^#/} @sysctl_data;
	chomp @sysctl_data;
	for (my $i=0; $i <= $#sysctl_data ; $i++) {
		$sysctl_data[$i] =~ tr/=/,/;
		array_write_file($sosreport_save_pwd.$sysctl_save, $sysctl_data[$i]."\n");
	}

	# kdump 설정 파일 읽어오기
	@kdump_data = grep {!/^#/} @kdump_data;
	chomp @kdump_data;
	for (my $i=0; $i <= $#kdump_data ; $i++) {
		array_write_file($sosreport_save_pwd.$kdump_save, $kdump_data[$i]."\n");
	}
	
	# cpu process 갯수 구하기
	my $cpu_count = grep {/process/} @cpu_info_data;

	# os version 구하기
	$os_ver_data[0] =~ s/Description:\s+//g;

	# memory 구하기
	my $memory_info = join " ", @meminfo_data;
	my @memory_info_array = (split " ",$memory_info)[7,11,12,15,16];
	for (my $i=0; $i <= $#memory_info_array; $i++) {
		$memory_info_array[$i] = int($memory_info_array[$i] / 1024);
	}

	# df정보 
	shift @df_data;
	my $df_info_string = join " ", @df_data;
	my @df_info = (split " ",$df_info_string);
	for ( my $i=0; $i<=$#df_info; $i=$i+6) {
		my @fs_info = grep {/$df_info[$i+5]/} @mount_data;
		my $df_info_device_name = $df_info[$i];
		$df_info_device_name =~ s/\//./g;
		if ( grep {/\.dev\./} $df_info_device_name ) {
		my @filesystem_status = read_line_file($extract_dir.$filesystem_dir_file."dumpe2fs_".$df_info_device_name);
		@filesystem_status = grep {/Filesystem state:/} @filesystem_status;
		$filesystem_status[0] = (split ":", $filesystem_status[0])[1];
		$filesystem_status[0] =~ s/\s+//g;
		$fs_info[0] = substr($fs_info[0], index ($fs_info[0], "type "));
		$fs_info[0] =~ s/type\s+//;
		$fs_info[0] = (split " ", $fs_info[0])[0];
		write_file($sosreport_save_pwd.$df_save,$df_info[$i].":".format_bytes($df_info[$i+1]*1024,precision=>0).":".format_bytes($df_info[$i+2]*1024,precision=>0).":".format_bytes($df_info[$i+3]*1024,precision=>0).":".$df_info[$i+4].":".$df_info[$i+5].":".$fs_info[0].":".$filesystem_status[0]."\n");
		}
	}

	#ps 리스트 구하기
	shift @ps_data;
	for ( my $i=0; $i<=$#ps_data; $i++) {
		my @ps_info = (split " ", $ps_data[$i],11)[0,1,2,3,4,5,6,7,8,9,10];
		if (length $ps_info[10] > 50) {
			$ps_info[10] = substr($ps_info[10], 0, 50)."...";
		}
		my $ps_regular = join ",",@ps_info;
		write_file($sosreport_save_pwd.$ps_save,$ps_regular."\n");
	}

	# uptime 구하기
	my $uptime_info = join " ", @uptime_data;
	($uptime_info) = (split",",$uptime_info,2)[0];
	$uptime_info =~ s/\s+(..)\:(..)\:(..)\s+up\s+//;

	# load average 구하기
	my $load_average = join " ", @uptime_data;
	($load_average) = (split "average:", $load_average)[1];
	write_file($sosreport_save_pwd.$load_average_save,$load_average);

	# error,fail,warn massage  확인
	my @error_messages = grep {/error/i} @messages_data;
	my @error_messages_uniq = uniq(@error_messages);	
	for ( my $i=0; $i<=$#error_messages_uniq;$i++) {
		write_file($sosreport_save_pwd.$error_save, $error_messages_uniq[$i]."\n");
	}

	my @warn_messages = grep {/warn/i} @messages_data;
	my @warn_messages_uniq = uniq(@warn_messages);	
	for ( my $i=0; $i<=$#warn_messages_uniq;$i++) {
		write_file($sosreport_save_pwd.$warn_save, $warn_messages_uniq[$i]."\n");
	}

	my @fail_messages = grep {/fail/i} @messages_data;
	my @fail_messages_uniq = uniq(@fail_messages);	
	for ( my $i=0; $i<=$#fail_messages_uniq;$i++) {
		write_file($sosreport_save_pwd.$fail_save, $fail_messages_uniq[$i]."\n");
	}
	if ( !-e $sosreport_save_pwd.$comment_save) {
		write_file($sosreport_save_pwd.$comment_save,"특이사항이 없습니다."."\n");
	}
	# kernel version 확인
	my $uname_info = join " ", @uname_data;
	$uname_info = (split " ",$uname_info)[2];
	my $arch_info = (split " ", (join " ", @uname_data))[13];

	# booting parameter 확인
	my @grub_conf = grep {/kernel/} @grub_data;
	@grub_conf = grep {/$uname_info/} @grub_conf;
	$grub_conf[0] = (split " ", $grub_conf[0],3)[2];

	# netstat 정보
	my @netstat_tcp_uniq = grep {/tcp/} @netstat_data;
	my @netstat_udp_uniq = grep {/udp/} @netstat_data;
	my @netstat_tcp_data = uniq_tcp(@netstat_tcp_uniq);
	for ( my $i=0;$i<=$#netstat_tcp_data;$i++) {
		my @netstat_total = (split " " ,$netstat_tcp_data[$i])[0,1,2,3,4,5,8];
		write_file($sosreport_save_pwd.$netstat_save, join (",",@netstat_total,"\n")); 
	}
	my @netstat_udp_data = uniq_udp(@netstat_udp_uniq);
	for (my $i=0;$i<=$#netstat_udp_data;$i++) {
		my @netstat_total = (split " " ,$netstat_udp_data[$i])[0,1,2,3,4, undef,7];
		write_file($sosreport_save_pwd.$netstat_save, join (",",@netstat_total,"\n")); 
	}

	#활성화 데몬 정보
	@chkconfig_list_data = grep {/:on/} @chkconfig_list_data;
	for ( my $i=0; $i<= $#chkconfig_list_data; $i++) {
		$chkconfig_list_data[$i] =~ s/\s+/,/g;
		$chkconfig_list_data[$i] =~ s/[0-9]:off//g;
		$chkconfig_list_data[$i] =~ s/[0-9]:on/on/g;
		$chkconfig_list_data[$i] = $chkconfig_list_data[$i]."\n";
		write_file($sosreport_save_pwd.$daemon_list_save, $chkconfig_list_data[$i]);
	}	
	for ( my $i=2; $i<= $#route_data; $i++) {
		$route_data[$i] =~ s/\s+/,/g;
		write_file($sosreport_save_pwd.$route_save, $route_data[$i]."\n");
	}

	write_file($sosreport_save_pwd.$hostname_save, $hostname_data[0]);
	write_file($sosreport_save_pwd.$uptime_save, $uptime_info);
	write_file($sosreport_save_pwd.$lsb_release_save, $os_ver_data[0]);
	write_file($sosreport_save_pwd.$uname_save, $uname_info);
	write_file($sosreport_save_pwd.$arch_save, $arch_info);
	write_file($sosreport_save_pwd.$cpu_name_save, $cpu_model_name[0]);
	write_file($sosreport_save_pwd.$cpu_count_save, $cpu_count);
	write_file($sosreport_save_pwd.$grub_save, $grub_conf[0]);
	write_file($sosreport_save_pwd.$memory_save, join (",","mem:",@memory_info_array,"\n"));
	
	rmtree $extract_dir; ## 임시 디렉토리 삭제
	
	chmod 0777, $homepage_index.$sosreport_name."/sh/data/comment.txt" or die "chmod faild $homepage_index.$sosreport_name"."/sh/data/comment.txt";
#	my $tid = Thread->self->tid;
	my $now = strftime "%F %H:%M:%S",localtime;
	print $now." ".$sosreport_name." Analystic done\n";

}

# index file make

unlink ($homepage_index."/sh/data/index.txt");

my @host_name_index = glob ($homepage_index."*-*");
for (my $i; $i <=$#host_name_index; $i++) {
        if ( time() - (stat($host_name_index[$i]))->ctime > 604800) {
		my $now = strftime "%F %H:%M:%S",localtime;
		print $now." ".$host_name_index[$i]." is old folder. Deleted\n";
                rmtree $host_name_index[$i]; 
        } elsif ( read_file($host_name_index[$i]."/sh/data/hostname.txt" )  eq  "" ) {
		my $now = strftime "%F %H:%M:%S",localtime;
		print $now." ".$host_name_index[$i]." host name value is empty. Deleted\n";
              	rmtree $host_name_index[$i]; 
	} else {
		my $host_name= read_file($host_name_index[$i]."/sh/data/hostname.txt");
		my $os_ver = (split " ", (read_file($host_name_index[$i]."/sh/data/lsb_release.txt")))[6];
		my $kernel = read_file($host_name_index[$i]."/sh/data/uname.txt");
		my $arch = read_file($host_name_index[$i]."/sh/data/arch.txt");
		my $cpu_count = read_file($host_name_index[$i]."/sh/data/cpu_count.txt");
		my $memory;
		if ( -e $host_name_index[$i]."/sh/data/mem.txt") {
	 		$memory = (split ",", (read_file($host_name_index[$i]."/sh/data/mem.txt")))[1];
		} else {
	       		$memory= 1;
		}
		my $memory_used;
		if ( -e $host_name_index[$i]."/sh/data/mem.txt") {
		 	$memory_used = (split ",", (read_file($host_name_index[$i]."/sh/data/mem.txt")))[4];
		} else {
	       		$memory_used= 1;
		}
		my $uptime = read_file($host_name_index[$i]."/sh/data/uptime.txt");
		$uptime =~ s/:/분 /;
		my @daemon_list =  read_line_file($host_name_index[$i]."/sh/data/daemon_list.txt");
		my @kdump = grep {/kdump/} @daemon_list;
		if ( !grep {/kdump/} @daemon_list) {
			$kdump[0] = "off";
		} else {
			$kdump[0] = (split "," , $kdump[0])[5];
		}	
		my $daemon_count = read_line_file($host_name_index[$i]."/sh/data/daemon_list.txt");
		my $error_count;
		if ( -e $host_name_index[$i]."/sh/data/error.txt") {
			$error_count = read_line_file($host_name_index[$i]."/sh/data/error.txt");
		} else {
		       	$error_count = 0;
		}
		my $warn_count;
		if ( -e $host_name_index[$i]."/sh/data/warn.txt") {
			$warn_count = read_line_file($host_name_index[$i]."/sh/data/warn.txt");
		} else {
	       		$warn_count = 0;
		}
		my $fail_count;
		if ( -e $host_name_index[$i]."/sh/data/fail.txt") {
			$fail_count = read_line_file($host_name_index[$i]."/sh/data/fail.txt");
		} else {
	       		$fail_count = 0;
		}
		write_file($homepage_index."/sh/data/index.txt", join (":","<a href=./".(split "/", $host_name_index[$i])[4].">".$host_name."</a>","RHEL ".$os_ver,$kernel,$arch,$cpu_count,format_bytes($memory*1024*1024,precision=>0),format_bytes($memory_used*1024*1024,precision=>0),format_number($memory_used/$memory*100,2),$uptime, $kdump[0], $daemon_count, $warn_count, $fail_count ,$error_count."\n"));
	}
}

	

sub regular_bond {
	my (@string) = @_;
	for ( my $i=0; $i<=$#string; $i++) {
		$string[$i] = substr($string[$i],index ($string[$i],":"));
		$string[$i] =~ s/:\s+//;
	}
	return @string ;
}

sub read_line_file {
	my @all;
	my ($filename) = @_;
	#open my $in , '<:encoding(console_in)', $filename or die "could not open '$filename' for reading $!";
	if ( -e $filename ) {
		open my $in , '<:encoding(guess)', $filename or  print "could not open '$filename' for reading $!\n";
		if ( ref($in)) {
			open $in, '<:encoding(ISO-8859-15)', $filename;
		}
		chomp ( @all = grep /\S/, readline($in));
		close $in;
	} else {
		@all = "";
	}	
	return @all;
}

sub read_file{
	my $all;
	my ($filename) = @_;
	#open my $in , '<:encoding(console_in)', $filename or die "could not open '$filename' for reading $!";
	if ( -e $filename ) {
	open my $in , '<:encoding(guess)', $filename or print "could not open '$filename' for reading $!\n";
	if ( ref($in)) {
		open $in, '<:encoding(ISO-8859-15)', $filename;
	}
	local $/ = undef;
	$all = <$in>;;
	close $in;
	} else {
		$all = "";
	}	
	return $all;
}

sub array_print {
	my (@filename) = @_;
	for ( my $i=0; $i<= $#filename; $i++) {
               return $filename[$i];  
        }
}

sub write_file {
	my ($filename, $content) = @_;
	open my $out, '>>:encoding(console_out)', $filename or die "Could not open '$filename' for writing $!\n";
		print $out $content;
	close $out;
	return;
}

sub write_new_file {
	my ($filename, $content) = @_;
	open my $out, '>:encoding(console_out)', $filename or die "Could not open '$filename' for writing $!\n";
	print $out $content;
	close $out;
	return;
}


sub array_write_file {
	my ($filename, @content) = @_;
	open my $out, '>>:encoding(console_out)', $filename or die "Could not open '$filename' for writing $!\n";
	print $out @content;
	close $out;
	return;
}
sub uniq {
	my %seen;
	return grep { !$seen{(split " ", $_,6)[5]}++ } @_;
}
sub uniq_tcp{
	my %seen;
	return grep { !$seen{(split " ", $_)[8]}++ } @_;
}
sub uniq_udp{
	my %seen;
	return grep { !$seen{(split " ", $_)[7]}++ } @_;
}
sub make_chart_js { 
	my @vars = @_;
	my $save_file = $vars[0];
	my $load_file = $vars[1];
	my $user_title = $vars[2];
	my $save_pwd = $vars[3];
	my @sar_save_data = read_line_file($load_file);
	for (my $i=0; $i<=$#sar_save_data; $i++) {
		if ( $i==$#sar_save_data) {
			write_file($save_pwd."/js/".$save_file.".js", "[".$sar_save_data[$i]."]\n");
			write_file($save_pwd."/js/".$save_file.".js", " ]);\n");
			write_file($save_pwd."/js/".$save_file.".js", "var options = {  title: '".$save_file."'   };\n");
			write_file($save_pwd."/js/".$save_file.".js", "var chart = new google.visualization.LineChart(document.getElementById('chart_".$save_file."'));\n");
			write_file($save_pwd."/js/".$save_file.".js", "chart.draw(data, options);\n");
			write_file($save_pwd."/js/".$save_file.".js", "}\n");
		} elsif ($i==0) {
			write_file($save_pwd."/js/".$save_file.".js", "google.load(\"visualization\", \"1\", {packages:[\"corechart\"]});\n");
			write_file($save_pwd."/js/".$save_file.".js", "google.setOnLoadCallback(drawChart);\n");
			write_file($save_pwd."/js/".$save_file.".js", "function drawChart() {\n");
			write_file($save_pwd."/js/".$save_file.".js", "var data = google.visualization.arrayToDataTable([\n");
			write_file($save_pwd."/js/".$save_file.".js", "['time',".$user_title."'],\n");
			write_file($save_pwd."/js/".$save_file.".js", "[".$sar_save_data[$i]."],\n");
		} else {
			write_file($save_pwd."/js/".$save_file.".js", "[".$sar_save_data[$i]."],\n");
		}
	}
}

sub make_percent_chart_js{ 
	my @vars = @_;
	my $save_file = $vars[0];
	my $load_file = $vars[1];
	my $user_title = $vars[2];
	my $save_pwd = $vars[3];
	my @sar_save_data = read_line_file($load_file);
	for (my $i=0; $i<=$#sar_save_data; $i++) {
		if ( $i==$#sar_save_data) {
			write_file($save_pwd."/js/".$save_file.".js", "[".$sar_save_data[$i]."]\n");
			write_file($save_pwd."/js/".$save_file.".js", " ]);\n");
			write_file($save_pwd."/js/".$save_file.".js", "var options = {  title: '".$save_file."'   };\n");
			write_file($save_pwd."/js/".$save_file.".js", "var chart = new google.visualization.LineChart(document.getElementById('chart_".$save_file."'));\n");
			write_file($save_pwd."/js/".$save_file.".js", "chart.draw(data, {vAxis:{maxValue:100,minValue:0}});\n");
			write_file($save_pwd."/js/".$save_file.".js", "}\n");
		} elsif ($i==0) {
			write_file($save_pwd."/js/".$save_file.".js", "google.load(\"visualization\", \"1\", {packages:[\"corechart\"]});\n");
			write_file($save_pwd."/js/".$save_file.".js", "google.setOnLoadCallback(drawChart);\n");
			write_file($save_pwd."/js/".$save_file.".js", "function drawChart() {\n");
			write_file($save_pwd."/js/".$save_file.".js", "var data = google.visualization.arrayToDataTable([\n");
			write_file($save_pwd."/js/".$save_file.".js", "['time',".$user_title."'],\n");
			write_file($save_pwd."/js/".$save_file.".js", "[".$sar_save_data[$i]."],\n");
		} else {
			write_file($save_pwd."/js/".$save_file.".js", "[".$sar_save_data[$i]."],\n");
		}
	}
}

sub save_sar_data {
	my @vars = @_;
	my $array = $vars[0];
	my $save_file = $vars[1];
	my $position = $vars[2];
	my @sar_data = ( split "#", $array);
	my %sar_time = create_time_table();

	if ( !-e $save_file) {
		for (my $i=0; $i<=$#sar_data; $i++) {
			my $time = (split ",", $sar_data[$i])[0];
			my $minute = (split ":", $time)[1];
			my $hour = (split ":", $time)[0];
			my $timestamp = join ( ":", $hour, $minute);
			$sar_time{$timestamp}  = (split ",", $sar_data[$i])[$position];
		#	my $data = (split ",", $sar_data[$i])[$position];
			#write_file($save_file,"'".$time."',".$data."\n");
		}
		foreach my $key (sort keys %sar_time) {
			write_file($save_file,"'".$key."',".$sar_time{$key}."\n");
		}
	} else {
		my @sar_save_data = read_line_file($save_file);
		unlink ($save_file);
		for (my $i=0; $i<=$#sar_data; $i++) {
			my $time = (split ",", $sar_data[$i])[0];
			my $minute = (split ":", $time)[1];
			my $hour = (split ":", $time)[0];
			my $timestamp = join ( ":", $hour, $minute);
			$sar_time{$timestamp}  = (split ",", $sar_data[$i])[$position];
			#my $data = (split ",", $sar_data[$i])[$position];
			#write_file($save_file,$sar_save_data[$i].",".$data."\n");
	#		write_file($save_file,$sar_save_data[$i].",".$sar_time{$timestamp}."\n");
		}
		
		for (my $i=0; $i<=$#sar_save_data; $i++) {
			my $time = (split ",", $sar_save_data[$i])[0];
			$time =~ s/'//g;
			my $minute = (split ":", $time)[1];
			my $hour = (split ":", $time)[0];
			my $timestamp = join ( ":", $hour, $minute);
			write_file($save_file,$sar_save_data[$i].",".$sar_time{$timestamp}."\n");
		}
	}
}

sub create_time_table {
	my %time;
	for (my $i=0; $i <= 1430 ; $i = $i + 10) {
       		my $m = $i % 60;
	        my $h = int($i / 60);
        	$time{join(':', (map { length($_) == 1 ? '0'.$_ : $_ } $h, $m))} = 0;
	}	
#	foreach my $key (sort keys %time) {
#       	say "$key => $time{$key}";
#	}
	return %time;
}

sub failed_extract {
	my @vars=@_;
	my $now = strftime "%F %H:%M:%S",localtime;
	my $filename = (split "/", $vars[2])[3];
	print $now." ".$filename." archive file was wrong. \n";
	move($vars[0], $vars[1]) or die "Move failed $!"; 	
	write_file($sosreport_dir."/failed_extract_sosreport-file-list.txt",$filename."\n");
}	
