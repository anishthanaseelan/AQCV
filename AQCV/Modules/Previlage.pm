package Previlage;

use strict;
use User;
#  Constructure to Configurator
#  name: New
#  @param : none
#  @return : object to AQCVConfig
sub New
{
	my ($class,$Admins) = @_;

	my $self = 
	{
		"_Admins" => $Admins
	};
    bless $self, $class;
    return $self;
}

sub IsAdmin
{
	my ( $self ) = @_;
	
	my $UserId = User->Login;
	
	foreach my $User  ( @{$self->{"_Admins"}} )
	{
		#print "$User eq $UserId \n";
		return 1 if ( $User eq $UserId );
	}
	return ( 0 );
	
}

sub UserID
{
	my ( $self ) = @_;
	return ( User->Login );
}

sub DESTROY
{
}

1;
