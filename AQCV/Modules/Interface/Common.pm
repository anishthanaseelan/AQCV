package Interface::Common;

use strict;
use Interface::SVN;
use Validator;
use Reporter;
use AQCVConfig;
use Previlage;
use Certificate;

#  Constructure to Common ( the hub )
#  name: New
#  @param : none
#  @return : object to Common
sub New
{
	my ($class,$WorkDir,$ConfigXML) = @_;
	my $lRc = 0;
	
	my $self = 
	{
		"_AgentRef" => Interface::SVN->New($WorkDir),
		"_ConfigRef" => AQCVConfig->New($ConfigXML),
		"_WorkDir"  => $WorkDir
	};
	
	($lRc , $self->{"_RptRef"} ) =  Reporter->New($self->{"_ConfigRef"}->GetMailAttribs());

	$self->{"_Validator"} = Validator->New($self->{"_ConfigRef"},$self->{"_RptRef"}) if ( $lRc == 0 );
	
	$self->{"_Previlage"} = Previlage->New( $self->{"_ConfigRef"}->GetAdmins() ) if ( $lRc == 0 );

    bless $self, $class;
    return ($lRc , $self);

}
sub GetAll
{
	my ( $self , $Repo) = @_;
	$self->{_AgentRef}->GetAll($Repo);
	return;	
}

sub CheckOut 
{
	#Dummy for SVN Implimentation
	my ( $self ) = @_;
	return;
}
sub GetChanges()
{
	my ( $self ) = @_;
	return ( $self->{_AgentRef}->GetChanges() );
}

sub CheckIn 
{
	 my ( $self ) = @_;
	 my $lRc = 0;
	 my $ResultRef = undef;
	 my @ChangedFiles = @{$self->GetChanges()};
	 my $Comment = '';
	 my $CriticalViolation = 0;
	 my $AdminOverride = 0;
	 my $Msg = '';
	 
	 if ( scalar (@ChangedFiles) > 0 )
	 {
		print "\nThe following files will be Checked-in...\n";
		print join ( "\n" , @ChangedFiles );
		print "\n Shall i proceed Checkin [y/n]:";
		$Comment = <STDIN>;
		chomp ( $Comment );
		
		if ( $Comment =~ /^Y$/i )
		{
			print "\nValidating the Modified Files for Compliance....\n";
			
			( $lRc , $CriticalViolation )= $self->{_Validator}->Validate ( $self->{_AgentRef}->DiffInventory() );
			
			if ( $lRc == 0 )
			{
				$self->{"_RptRef"}->PrintReport();
				
				if ( $self->{"_Previlage"}->IsAdmin() &&  $CriticalViolation != 0 )
				{
					print "\nThere are Critical Violations; Do you still want to check-in [y/n]:";
					$Comment = <STDIN>;
					chomp ( $Comment );
					if ( $Comment =~ /^Y$/i )
					{
						$AdminOverride = 1;
						print "\nCheck-In with Non-Compliant code ....\n";
					}
				}
			}
		
			$Msg = "Critical Violation" if ( $CriticalViolation );
			$Msg = "Admin Override" if ( $AdminOverride );
		
			$lRc = $self->{"_RptRef"}->WriteUsageRpt( $Msg );
			
			if ( ( $CriticalViolation == 0 || $AdminOverride == 1 ) && $lRc == 0 )
			{
				while ()
				{
					print "\nCheck-in Comment : ";
					$Comment = <STDIN>;
					chomp ( $Comment );
					if ( $Comment =~ /^$/ )
					{
						print "\nCheck-in comment is mandatory,Please provide... ";
					}
					else
					{
						last;
					}
				}
				
				&Certificate::IssueCertificate ( \$Comment );
				&Certificate::VerifyCertificate ( $Comment );
				
				$lRc = $self->{_AgentRef}->CheckIn( $Comment );
				
				if ( $lRc == 0 )
				{
					print "\nWork Directory Committed.\n" ;
					$self->{"_RptRef"}->SentViolationRpt() if ( $AdminOverride == 1 );
				}
				else
				{
					print "\nCommit Failed... \n";
				}
				
			}
			else
			{
				print "Quality Compliance Violations Found \n";
				print "Please resolve them and try check-in again\n";
				print "If you should override this Validation, Check-in from a Administrator Account\n";
			}
		}
		else
		{
			print "\nCommit canceled.\n";
		}
		$Msg = "Admin Override" if ( $AdminOverride );
		$Msg = "Critical Violation" if ( $CriticalViolation );
		
		$lRc = $self->{"_RptRef"}->WriteUsageRpt( $Msg );
	 }
	 else
	 {
		print "\nWork directory has no changes since last update\n";		
	 }
	 <STDIN>;
	 
	 return ( $lRc );

}

sub AnyActiveViolations()
{
	my ( $self ) = @_;
	my $Flag = 0;
	my $ActiveModeRules = $self->{"_ConfigRef"}->ActiveModeRules;
	
	foreach my $VioRules ( @{$self->{"_RptRef"}->GetViolatedRules()} )
	{
		foreach my $ActiveModeRule ( @{$ActiveModeRules} )
		{
			#print "$VioRules eq $ActiveModeRule \n";
			if ( $VioRules eq $ActiveModeRule )
			{
				$Flag = 1;
				last;				
			}
		}
	}
	return ($Flag);
}
sub Validate
{

	 my ( $self ) = @_;
	 my $lRc = 0;
	 my $ResultRef = undef;
	 my @ChangedFiles = @{$self->GetChanges()};
	 my $Comment = '';
	 
	 if ( scalar (@ChangedFiles) > 0 )
	 {
		print "\nThe Following Files will be Validated...\n";
		print join ( "\n" , @ChangedFiles );

		print "\nValidating the Modified Files for Compliance....\n";
		
		( $lRc , $ResultRef ) = $self->{_Validator}->Validate ( $self->{_AgentRef}->DiffInventory() );
		
		if ( $lRc == 0 )
		{
			$self->{"_RptRef"}->PrintReport();
		}

	 }
	 else
	 {
		print "\nWork directory has no changes since last update\n";		
	 }
	 <STDIN>;
	 
	 return ( $lRc );

}
sub Update 
{
	 my ( $self ) = @_;
	 $self->{_AgentRef}->Update();
	 return;

}


sub DESTROY
{
	#print "Destroying Interface::Common objects \n";
}
1;

__END__
