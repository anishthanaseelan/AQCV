package AQCVConfig;

use strict;
use XML::Simple;
#  Constructure to Configurator
#  name: New
#  @param : none
#  @return : object to AQCVConfig
sub New
{
	my ($class,$ConfigXML) = @_;
    my $xml = new XML::Simple;
	
	my $self = 
	{
		"_ParserRef" => $xml,
        "_DataRef" => $xml->XMLin($ConfigXML)
    };
    bless $self, $class;
    return $self;
}
#  
#  name: RuleModules
#  @param : none
#  @return : Hash referance to the active rules

sub RuleModules
{
	my ( $self ) = @_;
	my %Modules = ();
	foreach my $Rule ( keys %{$self->{_DataRef}->{Rules}} )
	{
		if ( $self->{_DataRef}->{Rules}->{$Rule}->{Active} =~ /Yes/i )
		{
			$Modules{$Rule} = $self->{_DataRef}->{Rules}->{$Rule}->{Module};
		}
	}
	return ( \%Modules );
}
#  
#  name: GetAdmins
#  @param : none
#  @return : Array referance to the Admin list
sub GetAdmins
{
	my ( $self ) = @_;
    print  @{$self->{_DataRef}->{Admins}{Userid}} ;
	return ( $self->{_DataRef}->{Admins}{Userid} );
	
}

#  
#  name: GetMailAttribs
#  @param : none
#  @return : Hash referance to the mail Attributs
sub GetMailAttribs
{
    my ( $self ) = @_;
    my $AttribRef = $self->{_DataRef}->{Mail};
    map ( $AttribRef->{$_} = $self->{_DataRef}->{General}{$_} , keys %{$self->{_DataRef}->{General}} );
	return ( $AttribRef );
}

#  
#  name: GetRuleAttribs
#  @param : Rule ID
#  @return : Hash referance to the Attributs 
sub GetRuleAttribs
{
	my ( $self ,$Rule ) = @_;
	return ( $self->{_DataRef}->{Rules}->{$Rule} );
}
#  
#  name: ActiveModeRules
#  @param : none
#  @return : Referance to the active rule list
sub ActiveModeRules
{
    my $self = shift;
    my @Rules = ();
    foreach my $Rule ( keys %{$self->{_DataRef}->{Rules}} )
	{
		if ( $self->{_DataRef}->{Rules}->{$Rule}->{Active} =~ /Yes/i &&
		$self->{_DataRef}->{Rules}->{$Rule}->{Mode} =~ /ACTIVE/i )
		{
			push ( @Rules , $Rule );
		}
	}
	return ( \@Rules );    
}
#  
#  name: IsCriticalRule
#  @param : Rule ID
#  @return : boolean : Rule status
sub IsCriticalRule
{
	my ( $self ,$Rule ) = @_;
	return ( 1 ) if ( $self->{_DataRef}->{Rules}->{$Rule}->{Mode} =~ /ACTIVE/i );
    return ( 0 );
}
#  
#  name: GetRuleName
#  @param : Rule ID
#  @return : Rule name
sub GetRuleName
{
	my ( $self ,$Rule ) = @_;
	return ( $self->{_DataRef}->{Rules}->{$Rule}->{Name} );
}
#  
#  name: FunctionRules
#  @param : None
#  @return : Referance to the Rule list
sub FunctionRules
{
	my ( $self ) = @_;
	my @Rules = ();
	
	foreach my $Rule ( keys %{$self->{_DataRef}->{Rules}} )
	{
		if ( $self->{_DataRef}->{Rules}->{$Rule}->{Active} =~ /Yes/i &&
		$self->{_DataRef}->{Rules}->{$Rule}->{Type} =~ /FUNCTION/i )
		{
			push ( @Rules , $Rule );
		}
	}
	return ( \@Rules );
	
}
#  
#  name: FileRules
#  @param : None
#  @return : Referance to the Rule list
sub FileRules
{
	my ( $self ) = @_;
	my @Rules = ();
	
	foreach my $Rule ( keys %{$self->{_DataRef}->{Rules}} )
	{
		if ( $self->{_DataRef}->{Rules}->{$Rule}->{Active} =~ /Yes/i &&
		$self->{_DataRef}->{Rules}->{$Rule}->{Type} =~ /FILE/i )
		{
			push ( @Rules , $Rule );
		}
	}
	return ( \@Rules );
}
#  
#  name: ProgramRules
#  @param : none
#  @return : Referance to the Rule list
sub ProgramRules
{
	my ( $self ) = @_;
	my @Rules = ();
	
	foreach my $Rule ( keys %{$self->{_DataRef}->{Rules}} )
	{
		if ( $self->{_DataRef}->{Rules}->{$Rule}->{Active} =~ /Yes/i &&
		$self->{_DataRef}->{Rules}->{$Rule}->{Type} =~ /PROGRAM/i )
		{
			push ( @Rules , $Rule );
		}
	}
	return ( \@Rules );
}

sub DESTROY
{
}

1;
