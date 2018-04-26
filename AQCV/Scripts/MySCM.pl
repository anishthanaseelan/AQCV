#!/usr/local/bin/perl
###############################################################################
#
#   File Name:       MySCM.pl
#   Author:          Anish Thanaseelan.K
#   Date:            10-Nov-2010
#   Purpose:         This is a Common SCM  Cleint
#   Usage:           ./MySCM.pl ( <Dir to Work on> )
#
###############################################################################

BEGIN 
{

	if ( $^O eq "MSWin32" )
	{
	}
	else
	{
		push ( @INC , '/root/Projects/AQCV/Modules' );
    }
}


use Interface::Common;
use strict;
use Cwd;
use Menu;

my $lRc = 0;

my $WorkDir = undef;
my $TempDir = undef;
my $WorkFile = undef;
my $Repo = undef;
my $SCMRef = undef;
my $Comment = undef;

my $Option = "";

my $ConfigXML = "/root/Projects/AQCV/Scripts/AQCV.xml";

if ( ! -f $ConfigXML )
{
    die "Configuration XML Not Found : $ConfigXML";
}

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
		print "$ARGV[0] is not a Directory \n";
		#$WorkDir = $ARGV[0];
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
	print "Current Work Directory is $WorkDir \n";
	
	( $lRc , $SCMRef )  = Interface::Common->New($WorkDir,$ConfigXML);
	
	while ( $lRc == 0 )
	{
		$Option = &Menu::ShowOptions ($WorkDir) ;
		
		if ( $Option =~ /^1$/ )
		{
            while ()
            {
                print "\nThe Repository you want to load :";
                $Repo = <STDIN>;
                chomp ( $Repo );
                last if ( $Repo !~ /^$/ );
            }
            $SCMRef->GetAll($Repo);
			print "\n The repository is loaded\n";
            <STDIN>;
		}
		elsif ( $Option =~ /^2$/ )
		{
			$SCMRef->Update();
            print "\nWork Directory updated\n";
            <STDIN>;
		}
		elsif ( $Option =~ /^3$/ )
		{
			$SCMRef->CheckIn();
			
		}
		elsif ( $Option =~ /^4$/ )
		{
				print "\nThe New Working Dir is:";
				$TempDir = <STDIN>;
				chop ( $TempDir );
				if ( -d "$TempDir" )
				{
					$WorkDir = $TempDir;
					$SCMRef->DESTROY;
					$SCMRef = undef;
					$SCMRef = Interface::Common->New($WorkDir,$ConfigXML);
				}
				else
				{
					print "\nError:$TempDir is not a Directory \n";
					<STDIN>;
					next;
				}
		}
        elsif ( $Option =~ /^5$/ )
		{
			$SCMRef->Validate();			
		}
		else
		{
			last;
		}
	}
}
exit ( $lRc );
