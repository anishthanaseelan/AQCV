package Common;


use SVN;

sub New
{
	my ($class,$WorkDir) = @_;
	my $self = {
        "_AgentRef" => New SVN($WorkDir),
        "_WorkDir"  => $WorkDir
    };
    print "Creating Wirk object with $WorkDir \n";
    bless $self, $class;
    return $self;

}
sub GetAll
{
	my ( $self , $Repo) = @_;
	$self->{_AgentRef}->GetAll($Repo);
	return;
	
}

sub CheckOut 
{
	#Dummy
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
   print "   Common::DESTROY called\n";
}
1;

__END__
