package Interface::Mail;

use strict;
#use Mail::Sender;
use Net::SMTP::TLS; 

#  Constructure to Main Interface
#  name: New
#  @param : Attribts 
#  @return : object to Interface::Mail
sub New
{
	my ($class,$Attribs) = @_;
	my $lRc = 0;
	my $self = 
	{
        "_Attribs" => $Attribs,
        "_Subject" => 	{ 
							"CRASH" => "AQCV : Rule engin Crush Report",
							"VIOLATION" => "AQCV: Violation and Administrator Override Report"
						},
        "_MailID" => 	{ 
							"CRASH" => $Attribs->{AdminMailID},
							"VIOLATION" => $Attribs->{ReportMailID}
						},

    };
    eval 
    {
		$self->{"_Mailer"} = new Net::SMTP::TLS(  
						 "$Attribs->{SMTPServer}",  
						 Hello   =>      $Attribs->{SMTPServer},  
						 Port    =>      $Attribs->{Port},  
						 User    =>      'anishthanaseelan',  
						 Password=>      'kats07'); 
	};
	if ( $@ )
	{
		print "Mailer intialization Failed :\n Error : $@ \n";
		$lRc = 1;
	}
    bless $self, $class;
    return ( $lRc , $self ) ;
}

=Anish Not Working

sub sendMail()
{
	my $self = shift;
	my $MailRptFile = shift;
	my $Type = shift;
	my $The_SenderObj = new Mail::Sender{ };

	if ( open ( FILE , "$MailRptFile" ) )
	{
		if ( $The_SenderObj->Open({ 
			to =>$self->{_MailID}{$Type} , 
			subject =>$self->{_Subject}{$Type}, 
			headers => "MIME-Version: 1.0\r\nContent-type: text/html\r\nContent-Transfer-Encoding: 7bit" }) )
		{
			while (<FILE>) { $The_SenderObj->Send($_) };

			close ( FILE );

			$The_SenderObj->Close();

			if ( @Mail::Sender::Errors[$The_SenderObj->{error}] ne "OK" )
			{
				my $msg  = " Error Occured while sending the mail :\n @Mail::Sender::Errors[$The_SenderObj->{error}] \n";
				print STDERR "$msg \n";
				$lRc = 100;
			}
			else
			{
				print "Mail sent Sucessfully.........\n";
			}
		}
		else
		{
			my $msg  = " Error Occured while sending the mail :\n $Mail::Sender::Error";
			print STDERR "$msg \n";
			$lRc = 100;
		}

	}
	else
	{
		print STDERR "Unable to open mail report file : $MailRptFile \n";
	}

	return ( $lRc );
	
}

=cut

sub sendMail()
{
	my $self = shift;
	my $MailRptFile = shift;
	my $Type = shift;
	my $lRc = 0;
	if (! open ( FILE , "$MailRptFile" ) )
	{
		$lRc = 1;
		print "Unable to open Report File $MailRptFile \n";
	}
	print "Sending Mail.. ";
	eval
	{
		$self->{"_Mailer"}->mail($self->{"_MailID"}{$Type});  
		$self->{"_Mailer"}->to($self->{"_MailID"}{$Type});  
		$self->{"_Mailer"}->data;  
		$self->{"_Mailer"}->datasend("Subject: $self->{_Subject}{$Type}\n");
		$self->{"_Mailer"}->datasend("MIME-Version: 1.0\r\nContent-type: text/html\r\nContent-Transfer-Encoding: 7bit \r\n");
		while (<FILE>) { $self->{"_Mailer"}->datasend($_); }
		$self->{"_Mailer"}->dataend;  
		$self->{"_Mailer"}->quit;
	};
	if ( $@ )
	{
		$lRc = 1;
		print "Failed\n";
	}
	else
	{
		print "Done\n";
	}

	return ( $lRc );
 }

sub DESTROY
{
}


1;
