package Reporter;

use strict;
use Interface::Mail;
use CreateRpt;
use Previlage;
#  Constructure to Configurator
#  name: New
#  @param : none
#  @return : object to AQCVConfig
sub New
{
	my ($class,$MailCfgRef) = @_;
	my $lRc = 0;
	my $ViolRpt = undef;
	my $CrashRpt = undef;
	my $Mail = undef;
	my @ViolFieldlist = ( "File" , "Function" , "Rule" , "Message" );
	my @CrhFieldlist = ( "User" , "Time" , "Error" );

	( $lRc , $ViolRpt )  = CreateRpt->New ( \@ViolFieldlist );
	
	( $lRc , $CrashRpt )  = CreateRpt->New ( \@CrhFieldlist ) if ( $lRc == 0 );
	
	( $lRc , $Mail ) = Interface::Mail->New ( $MailCfgRef ) if ( $MailCfgRef->{SendMail} =~ /Yes/i && $lRc == 0 );
	
	my $self = 	{	
			"_ViolRptrRef" => $ViolRpt,
			"_CrshRptrRef" => $CrashRpt,
			"_Data" => {},
			"_Mailer" => $Mail,
			"_Attribs" => $MailCfgRef
	};
	 
	$self->{"_Attribs"}->{"ReportPath"} =~ s/^\s+|\s+$//g;
	 
	if ( ! -d $self->{"_Attribs"}->{"ReportPath"}  )
	{
		print "Report directory not present.... \n";
		$lRc = 1;
	}
	bless $self, $class;
    return( $lRc , $self );
}

sub Accumulator
{
	my ( $self,$File,$Function,$Rule,$Msg ) = @_;
	my @ReportRec = ( $File,$Function,$Rule,$Msg ) ;
	
	$self->{"_Data"}->{$File}{$Function}{$Rule} = $Msg;

	return ;
}

sub WriteUsageRpt
{
	my $self = shift;
	my $Msg = shift;
	my $lRc = 0;
	my $Time = $self->GetTime();
	my $Date = $self->GetTime("RAWDATE");
	my $UserID = &Previlage::UserID;
	my $RulesViolated = scalar @{$self->GetViolatedRules()};
	my $ViolFileCount = scalar ( keys %{$self->{"_Data"}} );
	my $RptFileName = "Usage_"."_".$Date."\."."csv";
	my $ReportFile =  $self->{"_Attribs"}->{"ReportPath"}."/".$RptFileName;
	my $UsageRptHeader = "Time,User,#Files,#Rules Violated,Remarks";
	
	if (! -f $ReportFile )
	{
		if ( open  ( USGRPT , ">>$ReportFile" ) )
		{
			print USGRPT "$UsageRptHeader\n";
		}
		else
		{
			print "Unable to open the Usage Report \n";
			$lRc = 1;
		}
	}
	if ( open  ( USGRPT , ">>$ReportFile" ) )
	{
		print USGRPT "$Time,$UserID,$ViolFileCount,$RulesViolated,$Msg\n";
	}
	else
	{
		print "Unable to open the Usage Report \n";
		$lRc = 1;
	}
	
	return ( $lRc );
}

sub GetViolatedRules
{
	my $self = shift;
	my %Rules = ();
	my @RulesList = ();
	foreach my $File ( keys %{$self->{"_Data"}} )
	{
		foreach my $Function ( keys %{$self->{"_Data"}{$File}} )
		{
			foreach my $Rule ( keys %{$self->{"_Data"}{$File}{$Function}} ) 
			{
				$Rules{$Rule} = 1;
			}
		}
	}
	@RulesList = keys %Rules;
	return ( \@RulesList );
}
sub PrintReport 
{
	my $self = shift;
	my $lRc = 0;
	#print join ( "\n" , keys %{$self->{"_Data"}} );
	print "\nViolation Report: \n" if ( scalar ( keys %{$self->{"_Data"}} ) > 0 );
	foreach my $File ( keys %{$self->{"_Data"}} )
	{
		print "\tFile : $File\n";
		foreach my $Function ( keys %{$self->{"_Data"}{$File}} )
		{
			print "\t\tFunction : $Function\n";
			foreach my $Rule ( keys %{$self->{"_Data"}{$File}{$Function}} ) 
			{
				print "\t\t\tRule : $Rule\n\n";
				print "\t\t\tDesc : $self->{_Data}{$File}{$Function}{$Rule}\n";
			}
		}
	}

	return $lRc;
}
sub WriteViolationRpt
{
	
	my $self = shift;
	my $FileType = shift || "TXT";
	my @Data = ();
	my $lRc = 0;
	my $UserID = &Previlage::UserID;
	
	my $Time = $self->GetTime("RAW");
	
	my $RptFileName = "Violation_".$UserID."_".$Time."_".$$."\.".$FileType;
	
	my $RptFile =  $self->{"_Attribs"}->{"ReportPath"}."/".$RptFileName;
	
	print "The Report File is $RptFile \n";
	
	if ( scalar ( keys %{$self->{"_Data"}} ) > 0 )
	{
		
		foreach my $File ( keys %{$self->{"_Data"}} )
		{

			foreach my $Function ( keys %{$self->{"_Data"}{$File}} )
			{

				foreach my $Rule ( keys %{$self->{"_Data"}{$File}{$Function}} ) 
				{
					@Data = ( $File,$Function,$Rule,$self->{_Data}{$File}{$Function}{$Rule} );
					
					$self->{"_ViolRptrRef"}->Data(\@Data);
					
				}
			}
		}
		$lRc = $self->{"_ViolRptrRef"}->Write($RptFile,$FileType);
	}
	
	return ( $RptFile , $lRc );
	
}

sub WriteCrashRpt
{
	
	my $self = shift;
	my $Error = shift;
	my $FileType = shift || "TXT";
	my $lRc = 0;
	
	my @Data = ();
	my $UserID = &Previlage::UserID;
	
	my $Time = $self->GetTime("RAW");
	
	my $NormalTime = $self->GetTime();
	
	my $RptFileName = "Crash_".$UserID."_".$Time."_".$$."\.".$FileType;
	
	my $RptFile =  $self->{"_Attribs"}->{"ReportPath"}."/".$RptFileName;
	
	print "The Crash Report File is $RptFile \n";
	
	@Data = ( $UserID , $NormalTime , "$Error"  );
					
	$self->{"_CrshRptrRef"}->Data(\@Data);
	$lRc = $self->{"_CrshRptrRef"}->Write($RptFile,$FileType);
	#$self->{"_CrshRptrRef"}->Reset();
	return ( $RptFile , $lRc  );
	
}

sub SentViolationRpt
{
	my $self = shift;
	

	my ( $RptFileName, $lRc ) = $self->WriteViolationRpt ( "HTML" );
	
	if ( -f $RptFileName && $lRc == 0 && $self->{"_Attribs"}->{SendMail} =~ /YES/i )
	{
		$lRc = $self->{"_Mailer"}->sendMail( $RptFileName , "VIOLATION");
	}
	
	return ( $lRc );
}

sub SentCrashRpt
{
	my $self = shift;
	my $Error = shift;
	
	my ( $RptFileName , $lRc )  = $self->WriteCrashRpt ( $Error, "HTML" );
	
	if ( -f $RptFileName && $lRc == 0 )
	{
		$lRc = $self->{"_Mailer"}->sendMail( $RptFileName , "CRASH");
	}
	
	return ( $lRc );
}

sub GetTime
{
	my $self = shift;
	my $Type = shift || "NORMAL";
	my $lTime = '';
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	
	if ( $Type eq "NORMAL" )
	{
		$lTime = sprintf (  "%4d-%02d-%02d %02d:%02d:%02d", 
				$year+1900,$mon+1,$mday,$hour,$min,$sec );
	}
	elsif ( $Type eq "RAW" )
	{
		$lTime = sprintf (  "%4d%02d%02d%02d%02d%02d", 
				$year+1900,$mon+1,$mday,$hour,$min,$sec );
	}
	elsif ( $Type eq "RAWDATE" )
	{
		$lTime = sprintf (  "%4d%02d%02d", $year+1900,$mon+1,$mday );
	}
	else
	{
		$lTime = sprintf (  "%4d-%02d-%02d %02d:%02d:%02d", 
				$year+1900,$mon+1,$mday,$hour,$min,$sec );

	}
	#print "The Time $lTime \n";
	return ( $lTime );
}
sub DESTROY
{
}

1;
