#!/usr/bin/perl
#Modified By Umang Jain
# Runs in real-time to update user databases as sites are accessed
# It's is recommended run this script using the command:
# tail -n1 -F /path/to/squid_access_log | rtparse.pl
#

$db_dir = "/var/db/squidquota/users"; # Defines the location of the per-user files
$local_net_regexp = '10\.\.\.\d+'; # Skip requests to local servers  Modified by Umang Jain, B11086

while (<STDIN>) {
	@group = split(/\s/,$_);
	$dl_size = $group[$#group-5];
	$dl_user = $group[$#group-2];
	$dl_result = $group[$#group-6];
	$dl_source = $group[$#group-1];
	$dl_request = $group[$#group-3];

	if (($dl_result =~ m%^TCP_MISS/%) && $dl_source =~ m%FIRST_UP_PARENT/%    #Modified by Umang Jain
	    && ($dl_user !~ /^-/)) { # Only log non-cache requests and those with a username.
		if ( not -d "$db_dir/$dl_user" ) { # create non-existing dirs.
			system("mkdir -p $db_dir/$dl_user");
			}
		if ("$dl_size" eq 0) { # Don't log empty files. No point
			next;
			}	
		if((index($dl_request, '10.4.') != -1) || (index($url, 'insite.iitmandi') != -1)) {
			next;   # Don't log local traffic
		}
		open (USERDB,"<$db_dir/$dl_user/quotadb");
		my @userdb = <USERDB>;
		print @userdb;
		close USERDB;

		foreach $line (@userdb) {
			@db_field = split(/\s/,$line);
		        if ($db_field[0] =~ "balance") {
                		$db_balance = $db_field[1];
	                }
			if ($db_field[0] =~ "quota") {
				$db_quota = $db_field[1];
                	}
		}
		$db_balance = $db_balance - $dl_size;

		open (JNL,">>$db_dir/$dl_user/jnl");
		print JNL "$dl_size\n";
		close JNL;

		open (USER,">$db_dir/$dl_user/quotadb");
		print USER "balance $db_balance\nquota $db_quota";
		close USER;
		}
		
}
