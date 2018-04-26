#!/usr/local/bin/perl
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
use Certificate;
my $Comment = "Hello 123";
				&Certificate::IssueCertificate ( \$Comment );
				print "<Log> $Comment \n";
				&Certificate::VerifyCertificate ( $Comment );
				
print $^O;

#use Crypt::Blowfish;
#my $plaintext = "twthrhr . :  rrgwe/lkbjlrg:    thB kjosegrgshgsrgfahbvlSDLJAGSDLJVDSA";
#my $key = "HOWTOREMEMBERPASS";
##my $packkey = pack("H16", "0123456789ABCDEF"); 

#my $packkey = pack("H16", $key); 

#my $cipher = new Crypt::Blowfish $packkey;

#$setbits = unpack("%32b*", $plaintext);
#my $subset = sprintf ( "%08d" , $setbits );
#my $Enc = $cipher->encrypt($subset);
#$ciphertext =  unpack("H16",$Enc);

#print "<$Enc> <$ciphertext> , <$plaintext> \n";
	
#$Dec =  pack("H16", $ciphertext );

#$decsetbit = $cipher->decrypt($Dec);

#print "<$decsetbit><$setbits><$Dec><$Enc>\n";

    
    
    
#print &GetTime ( "RAW" );
rt
#sub GetTime
#{
	#my $Type = shift || "NORMAL";
	#my $lTime = '';
	
	#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	
	#if ( $Type eq "NORMAL" )
	#{
		#$lTime = sprintf (  "%4d-%02d-%02d %02d:%02d:%02d", 
				#$year+1900,$mon+1,$mday,$hour,$min,$sec );
	#}
	#elsif ( $Type eq "RAW" )
	#{
		#$lTime = sprintf (  "%4d%02d%02d%02d02d%02d", 
				#$year+1900,$mon+1,$mday,$hour,$min,$sec );
	#}
	#elsif ( $Type eq "RAWDATE" )
	#{
		#$lTime = sprintf (  "%4d%02d%02d", $year+1900,$mon+1,$mday );
	#}
	#else
	#{
		#$lTime = sprintf (  "%4d-%02d-%02d %02d:%02d:%02d", 
				#$year+1900,$mon+1,$mday,$hour,$min,$sec );

	#}
	#print "The Time $lTime \n";
	#return ( $lTime );
#}
