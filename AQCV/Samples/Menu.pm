package Menu;
###############################################################################
#
#   File Name:       Menu.pm
#   Author:          Anish Thanaseelan.K
#   Date:            11-Nov-2010
#   Purpose:         Menu for AQCV 
#   Usage:           
#
###############################################################################
use Term::ReadKey;
use strict;

sub ShowOptions ()
{
	
	my $Option = 0;
	my $WorkDir = shift;
	system("clear");
	print "For the Given Directory $WorkDir, \n Please Choose Any one of the options \n";
	print "1. Checkout\n";
	print "2. Update\n";
	print "3. Checkin\n";
	print "4. Change Working Directory\n";
	print "Any other key to exit\n";
	$Option = &ReadOption();
	return ( $Option );
	
}
sub ReadOption()
{

	my $Key = '';
	
    if ( open(TTY, "</dev/tty") )
    {
		print "\nYour Choise :";
		ReadMode "raw";
		$Key = ReadKey 0, *TTY;
		ReadMode "normal";
		close ( TTY );
	}
	else
	{
		die " Unable to get the Option \n";
	}
 #   print "\nYou have chosen $Key \n";
    return ( $Key );
}
1;
