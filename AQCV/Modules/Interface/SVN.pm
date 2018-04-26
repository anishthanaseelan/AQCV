package Interface::SVN;

use strict;
use SVN::Agent;
#  Constructure to SVN Agent
#  name: New
#  @param : none
#  @return : object to Interface::SVN
sub New
{
	my ($class,$WorkDir) = @_;
	
	my $self = 
	{
        "_AgentRef" => SVN::Agent->load({ path => $WorkDir }),
        "_WorkDir"  => $WorkDir
    };
    bless $self, $class;
    return $self;
}
sub _reload
{
	my ( $self ) = @_;
	$self->{_AgentRef} = undef;
	$self->{_AgentRef} = SVN::Agent->load({ path => $self->{"_WorkDir"} });
	return;
	
}
sub GetAll
{
	my ( $self , $Repo ) = @_;
	$self->{_AgentRef}->checkout($Repo);
	return;
	
}

sub Update 
{
	 my ( $self ) = @_;
	 $self ->{_AgentRef}->update();
	 return;
}
#  
#  name: GetChanges
#  @param : None
#  @return : Hash with Files and their Changed lines ( Start and End )
sub GetChanges
{
	my ( $self ) = @_;
	
	$self->_reload();
	$self->{_AgentRef}->prepare_changes();
	return ( $self->{_AgentRef}->changes );
}

sub CheckIn 
{
	my ( $self , $Message ) = @_;
	my $lRc = 0;
	eval
	{
		$self->{_AgentRef}->commit( $Message );				
	};
	if ( $@ )
	{
		print &_ExtractError ( $@ );
		$lRc = 1;
	}
	return $lRc;
}

sub _ExtractError
{
	return ( join ( "\n", grep( /svn: / , split ( "\n",shift) )) );
}

#   
#  name: DiffInventory
#  @param
#  @return This should return a Hash of array with Change Start lines
#  @{$HasRef->{File}{ChangeType}}

sub DiffInventory
{
	my ($self) = @_;
	my %DiffInventory = ();
	
	foreach my $File ( @{$self->{_AgentRef}->added()}  )
	{
		if ( $File =~ /\.ec$/ )
		{
			$DiffInventory{Added}{$File} = "Dummy";
		}
	}
	
	foreach my $File ( @{$self->{_AgentRef}->modified()}  )
	{
		if ( $File =~ /\.ec$/ )
		{

			my $ChangesLines = $self->_GetChangedLines( $File ); 
			$DiffInventory{Modified}{$File} = $ChangesLines;
		}
	}
	return ( \%DiffInventory );
	
}

sub _GetChangedLines
{
	my ($self , $File) = @_;
	my @ChangedLines = ();
	my $ActualLine = 0;
	#print "\n<FILE> $File ";
	my @Lines = split ( "\n", $self->{_AgentRef}->diff($File) );
	
	foreach my $Line ( @Lines ) 
	{
		#if ( $line =~ /^(Index:)\s+(.*)$/ )
		#print "\n<Line> <$Line>";
		if ( $Line =~ /^\@\@\s+(\+|\-)(\d+),(.*)$/ )
		{
			$ActualLine = $2;
			$ActualLine+=3 if ( $ActualLine > 1 ) ; 
			push ( @ChangedLines , $ActualLine );
			#print "\n<Lines> <@ChangedLines>";
		}
	}
	return ( \@ChangedLines );
}

sub DESTROY
{
	#print "Destroying Interface::SVN objects \n";
}
1;
__END__
