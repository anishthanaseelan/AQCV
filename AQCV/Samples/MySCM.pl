#!/usr/local/bin/perl -W
###############################################################################
#
#   File Name:       MySCM.pl
#   Author:          Anish Thanaseelan.K
#   Date:            10-Nov-2010
#   Purpose:         This is a Common SCM  Cleint
#   Usage:           ./MySCM.pl ( <Dir to Work on> )
#
###############################################################################

use Term::ReadKey;
use Common;
use strict;
use Cwd;
use Menu;

my $lRc = 0;

my $WorkDir = undef;
my $WorkFile = undef;
my $Repo = undef;
my $SCMRef = undef;

my $Option = "";

if ( scalar ( @ARGV ) == 1 )
{
	# The Work Directory is Given
	if ( -d "$ARGV[0]" )
	{
		$WorkDir = $ARGV[0];
	}
	elsif ( -f "$ARGV[0]" )
	{
		$WorkFile = $ARGV[0];
		$lRc = 1;
		print "$WorkFile is File; File operation Implemetation is not Done \n";
		# This will be used when working with other SCM Tools
	}

	else
	{
		print "$WorkDir is not a Directory \n";
		$lRc = 1;
	}

	 
} 
elsif ( scalar ( @ARGV ) == 0 )
{
	# Dir not given, Take the current dir 
	$WorkDir = cwd();
}
else
{
	print "Usage Error : perl MySCM.pl ( <Dir to Work on> ) \n";
	$lRc = 1;
}

if ( $lRc == 0 )
{
	print " The WorkDir is given $WorkDir \n";
	
	$SCMRef = New Common($WorkDir);
	
	while ()
	{
		$Option = &Menu::ShowOptions ($WorkDir) ;
		if ( $Option =~ /^1$/ )
		{
				print "\nThe Repository you want to load :";
				$Repo = <STDIN>;
				$SCMRef->GetAll($Repo);
				print "\n The repository is downloaded\n";
		}
		elsif ( $Option =~ /^2$/ )
		{
		}
		elsif ( $Option =~ /^3$/ )
		{
		}
		elsif ( $Option =~ /^4$/ )
		{
			print "\nThe New Working Dir is:";
			$WorkDir = <STDIN>;
			if ( -d "$WorkDir" )
			{
				$SCMRef->DESTROY;
				$SCMRef = undef;
				$SCMRef = New Common($WorkDir);
			}
			else
			{
						
				print "$WorkDir not a Directory... Try again";
				next;
			}
			
		}
		else
		{
			last;
		}
	}

	print "The User Option is $Option \n";

}
exit ( $lRc );












