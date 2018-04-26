package Menu;

#use Term::ReadKey;
use strict;

sub ShowOptions ()
{
	
	my $Option = 0;
	my $WorkDir = shift;
	system("clear");
	print "Work Directory : $WorkDir, \nChoose the task you want to perform \n";
	print "1. Get Repository for the first time\n";
	print "2. Update work directory\n";
	print "3. Check-in code changes\n";
	print "4. Change the work directory\n";
	print "5. Validate changes for compliance\n";
	print "\n\n Or any other key to exit\n";
	$Option = &ReadOption();
	return ( $Option );
	
}

#sub ReadOption()
#{

	#my $Key = '';
	
    #if ( open(TTY, "</dev/tty") )
    #{
		#print "\nYour Choise :";
		#ReadMode "raw";
		#$Key = ReadKey 0, *TTY;
		#ReadMode "normal";
		#close ( TTY );
	#}
	#else
	#{
		#die " Unable to get the Option \n";
	#}
 ##   print "\nYou have chosen $Key \n";
    #return ( $Key );
#}

sub ReadOption()
{
	my $Key = '';
	print "\nYour Choice :";
	$Key = <STDIN>;
	chomp ( $Key );
    return ( $Key );
}

1;
