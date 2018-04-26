package Certificate;

use Crypt::Blowfish;
use Previlage;
use strict;

#  This function issues certificate to the transation log
#  name: IssueCertificate
#  @param : Message
#  @return : Log message with certificate
sub IssueCertificate
{
	my $Message = shift;
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	my $TimeStamp = sprintf (  "%4d-%02d-%02d %02d:%02d:%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec );

	my $packkey = pack("H16", "HOWTOREMEMBERPASS");
	my $cipher = new Crypt::Blowfish $packkey;
	my $UserID = &Previlage::UserID();
	${$Message} =~ s/\|//g;
	my $TranLog = join ( "\|" , ( $UserID , $TimeStamp , $$Message ) );
	my $char8cksum = sprintf ( "%08d" , unpack("%32b*", $TranLog ));
	
	my $ciphertext =  unpack("H16",$cipher->encrypt($char8cksum)); # Gives readable cipher txt
	
	$TranLog = $ciphertext."\|".$TranLog;
	${$Message} = $TranLog;

}
#  This function verifies the  certificate in the  transation log
#  name: VerifyCertificate
#  @param : Message
#  @return : Certificate validity : boolean

sub VerifyCertificate
{
	my $LogMsg = shift;
	my $ValidCertificate = 0;
	my $packkey = pack("H16", "HOWTOREMEMBERPASS");
	my $cipher = new Crypt::Blowfish $packkey;
	my $Certificate = "";
	my $UserID = "";
	my $TimeStamp = "";
	my $Message = "";

	
	if ( $LogMsg =~ /^(.*)\|(.*)\|(.*)\|(.*)$/ )
	{
			( $Certificate , $UserID , $TimeStamp , $Message ) = split ( /\|/ , $LogMsg );
			
			my $TranLog = $UserID ."|". $TimeStamp ."|". $Message ;

			my $cksum4mLog = sprintf ( "%08d" , unpack("%32b*", $TranLog ));
			
			my $cksum4mCert = $cipher->decrypt(pack("H16", $Certificate ));

			if ( $cksum4mLog == $cksum4mCert )
			{	
				$ValidCertificate = 1;
				print "Valid Certificate \n";
			}
			else
			{
				$ValidCertificate = 0;
				print "Bogus Certificate \n";
			}
	}
	else
	{
		print "Invalid certificate found \n";
		$ValidCertificate = 0;
	}
	return ( $ValidCertificate );
}


1;
