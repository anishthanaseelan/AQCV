package SVN;

use strict;

use SVN::Agent;

sub New
{
	my ($class,$WorkDir) = @_;
	
	my $AgentRef = SVN::Agent->load({ path => $WorkDir });
    my $self = {
        "_AgentRef" => $AgentRef,
        "_WorkDir"  => $WorkDir
    };
    bless $self, $class;
    return $self;

}
sub GetAll
{
	my ( $self , $Repo ) = @_;
	$self->{_AgentRef}->checkout($Repo);
	return;
	
}

sub CheckOut 
{
	 my ( $self ) = @_;
	 return;

}

sub CheckIn 
{
	 my ( $self ) = @_;
	 return;

}
sub DESTROY
{
	my ( $self ) = @_;
	$self->{_AgentRef}->DESTROY;
   print "   SVN::DESTROY called\n";
}

1;
