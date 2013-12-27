#!/usr/bin/perl -w
#
# IMAP/IMAPS authenticator for Squid
# Copyright (C) 2012 Nishant Sharma <codemarauder@gmail.com>
#
# Modified By Umang Jain, IIT Mandi  <umang94@gmail.com>

use Authen::Simple::IMAP;

$|=1;
if ( @ARGV != 1){
    print STDERR "Usage: $0 imap(s)://imaps-serveR\n";
      exit 1;
}

my $server = shift @ARGV;
my $domain = shift @ARGV;
my $protocol = 'IMAP';
$protocol = 'IMAPS' if $server =~ m/imaps:\/\//;
$server =~ s/^imap(.*)\/\/(.*)$/$2/;

while (<>){
    my ($username, $password) = split(/\s+/);
      $username =~ s/%([0-9a-f][0-9a-f])/pack("H2",$1)/gie;
        my $supplieddomain = $username;
 $supplieddomain =~ s/^(.*)\@(.*)$/$2/;
              $password =~ s/%([0-9a-f][0-9a-f])/pack("H2",$1)/gie;

                my $imap = Authen::Simple::IMAP->new(
                          host => $server,
                                protocol => $protocol,
                                      timeout => 15,
                                          );

                  if (!$imap){
                        print "ERR Server not responding\n";
                            next;
                              }

                    if ($imap->authenticate($username, $password)){
                          print "OK\n";
                            }
                      else{
                            print "ERR\n";
                              }
                        undef $imap;
}
