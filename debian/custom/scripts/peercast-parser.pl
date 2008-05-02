#!/usr/bin/perl -s

# Peercact URL handler for xmms.
# By Romain Beauxis <toots@rastageeks.org>

# Usage: peercast-enqueue-in-xmms.pl -h=<server.address:port> -b=<binary commad> <peercast://foo>
# This script search for a string in the following mask: peercast://pls/HASHNUMBER
# And then call the required binary to enqueue the URL: http://127.0.0.1:7144/stream/HASHNUMBER
# WARNING: this does not handle any parameter like ?foo after the HASH, 
# But xmms seems to accept it.

my $link = shift;
my $host = $h;
my $binary = $b;

if (!$host) { $host = "127.0.0.1:7144"; }
 
$link =~ /peercast:\/\/pls\/(\w*)/;
my $regex = $1;
$binary =~ s/\%u/http:\/\/$host\/stream\/$regex/;

exec("$binary")

