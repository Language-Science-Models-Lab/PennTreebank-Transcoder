#!/usr/bin/perl

# This script verifies that the grammar transform program compiles and successfully runs the tests in the tests directory successfully
# Please make sure to verify your grammar changes/additions work with the existing tests and create a test sample for your additional
# rules in the tests directory, following the test-#.in and .out format, before submitting your changes to the respository!

# by Joseph Nunn, all rights reserved

use strict;
use warnings;
use File::Slurp ;

my $testdir = 'tests';
my $failcount = 0;
my $goodcount = 0;
my $bar = "----------------\n";
my $exename = "ptrans" ;

print "Making Clean\n";
my $compileResult = `make clean` ;
print "Testing Compile\n";
print $bar ;
$compileResult = `make` ;
print $bar ;
print "Compilation Results:\n" ;
print "$compileResult\n" ;

print "Changing Permissions on executable\n";
if ( $^O eq "darwin" || $^O eq "linux" ) {
  my $chresult = `chmod a+x $exename` ;
} else {
  print "On windows you have to give executable permissions on the compiled $exename manually!\n\n" ;
}

print "\n" ;

if ( ! -x "ptrans" ) {
  print "ERROR! no ptrans executable can be run, check permissions or compilation results above\n" ;
  exit( 1 ) ;
}

opendir(DIR, $testdir) or die $!;

print "Running Tests\n";
print "$bar";
while (my $infile = readdir(DIR)) {

  # We only want files
  next unless (-f "$testdir/$infile");

  # Use a regular expression to find input files
  next unless ($infile =~ m/(.*)\.in$/);

  # Output file has same name, different extension
  my $outfile = $1 . ".out" ;

  print "Testing input file $infile against expected output file $outfile............." ;
  
  if ( ! -r "$testdir/$outfile" ) {
	print "ERROR!, no matching output file $outfile for input file $infile!\n" ;
	$failcount++ ;
	next ;
  }

  my $outfileData = read_file("$testdir/$outfile") ;
  
  my $transformOutput = `./ptrans $testdir/$infile` ;

  my $diff = $transformOutput ^ $outfileData ;

  my $diffsum = unpack( "%W*", $diff ) ;

  if ( $diffsum != 0 ) {
	print "TEST FAILED!\n\n" ;
	$diff =~ s/./ord $& ? '^' : ' '/ge;
#	print "Transformed:\n\n$transformOutput\n";
#	print "Expected   :\n\n$outfileData\n\n" ;	
	#	print "Difference :\n\n$diff\n\n" ;
	print "Output      : " ;
	print "$_\n" for $transformOutput ;
	print "Expected    : " ;
	print "$_\n" for $outfileData ;
	print "Differences : " ;
	print "$_\n" for $diff ;
	$failcount++ ;
	print "\n\n" ;
  } else {
	$goodcount++ ;
	print "OK\n" ;
  }
}

print "$bar";
print "Finished testing:\n" ;

if ( $failcount == 0 ) {
  print "all tests Passed.\n" ;
} else {
  print "$failcount tests Failed.\n" ;
  print "$goodcount tests Passed.\n" ;
}

closedir(DIR);
exit 0;
