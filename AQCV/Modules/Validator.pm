package Validator;

use strict;
use Utility;
#  Constructure to Configurator
#  name: New
#  @param : none
#  @return : object to AQCVConfig
sub New
{
	my ($class,$Config,$RptrRef) = @_;

	my $self = 
	{
		"_Config" => $Config,
		"_RptrRef" => $RptrRef
	};
	$self->{"_RuleEngin"} = &_InitAll($self);
    bless $self, $class;
    return $self;
}
sub _InitAll()
{
	my  $self  = shift;
	my %RuleObjects = ();
	my $RuleAttrib = undef;
	
	my $ModuleRef = $self->{"_Config"}->RuleModules();
	
	foreach my $Rule ( keys %{$ModuleRef} )
	{
		$RuleAttrib = $self->{"_Config"}->GetRuleAttribs($Rule);

		eval ( "use $ModuleRef->{$Rule}"  );
		if( $@ )
		{
			$self->{"_RptrRef"}->SentCrashRpt($@);
			die "Rule engin crushed....\n";
		}
		else
		{
			$RuleObjects{$Rule} = $ModuleRef->{$Rule}->New($RuleAttrib);
		}
	}
	return ( \%RuleObjects );
}

sub Validate ()
{
	my ( $self , $InvRef ) = @_;
	my $lRc = 0;
	my $SourceRef = undef;
	my $CriticalViolation = 0;

	foreach my $ChangeType ( keys %{$InvRef} )
	{
		last if $lRc != 0;
		
		foreach my $File ( keys %{$InvRef->{$ChangeType}} )
		{
			
			if ( $ChangeType eq "Added" )
			{
				#print "\nAdded.. $File";
				( $lRc , $SourceRef ) = &Utility::SplitSource($File);
				
				$CriticalViolation = 1 if ( $self->_ProcessSource( $SourceRef , $File ) ) ;
			}
			elsif ( $ChangeType eq "Modified" )
			{
				#print "\nModified.. $File";
				( $lRc , $SourceRef ) = &Utility::SplitSource($File);
				$SourceRef = &Utility::MapChangedFunc( $SourceRef , 
					$InvRef->{$ChangeType}{$File} );
					
				$CriticalViolation = 1 if ( $self->_ProcessSource ( $SourceRef , $File ) );
			}
			else
			{
				$lRc = 1;
				print "Unhandled Change Type \n";
				last;
			}
		}
	}
	return ( $lRc , $CriticalViolation );
}

sub _ProcessSource 
{
	my ( $self , $SourceRef , $File ) = @_;
	my $Result = 0;
	my $Msg = "";
	my $lRc = 0;
	my $CriticalViolation = 0;
	
	foreach my $FunctionCnt ( sort keys %{$SourceRef} )
	{
		#print "\nValidating Function $SourceRef->{$FunctionCnt}{Name}";
		
		foreach my $Rule ( @{$self->{"_Config"}->FunctionRules()} )
		{
			eval
			{
				( $Result, $Msg ) = $self->{"_RuleEngin"}->{$Rule}->Validate($SourceRef-> {$FunctionCnt}{Code});
			};
			if ( $@ )
			{
				$self->{"_RptrRef"}->SentCrashRpt($@);
				$lRc = 1;
				die "\nRule Engin Crashed";
			}
			else
			{
				if ( $Result )
				{
					#print "\nSending to Accumulator \n";<STDIN>;
					$self->{"_RptrRef"}->Accumulator( $File,$SourceRef->{$FunctionCnt}{Name},
						$self->{"_Config"}->GetRuleName($Rule),$Msg );
					$CriticalViolation = 1 if ( $self->{"_Config"}->IsCriticalRule($Rule));
				}	
			}
		}
	}
	foreach my $Rule ( @{$self->{"_Config"}->FileRules()} )
	{
		eval
		{
			( $Result, $Msg ) = $self->{"_RuleEngin"}->{$Rule}->Validate($File);
		};
		if ( $@ )
		{
			$self->{"_RptrRef"}->SentCrashRpt($@);
			$lRc = 1;
			die "\nRule Engin Crashed";
		}
		else
		{
			if ( $Result )
			{
				$self->{"_RptrRef"}->Accumulator( $File,"Full File Validation",	$self->{"_Config"}->GetRuleName($Rule),$Msg );
				$CriticalViolation = 1 if ( $self->{"_Config"}->IsCriticalRule($Rule));
			}
		}
	}
	return ( $CriticalViolation  );
}
1;
