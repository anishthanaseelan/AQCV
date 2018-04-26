
BEGIN 
{
	if ( $^O eq 'MSWin32' )
	{
	
		push ( @INC , 'D:\To-Learn\BITS-MS\Sem4\WorkBase\Construction\AQCV\Modules' );
		push ( @INC , 'D:\To-Learn\BITS-MS\Sem4\WorkBase\Construction\AQCV\Modules\Interface' );
	}
	else
	{
		push ( @INC , "/media/Prime/To-Learn/BITS-MS/Sem4/WorkBase/Construction/AQCV/Modules/" );
		push ( @INC , "/media/Prime/To-Learn/BITS-MS/Sem4/WorkBase/Construction/AQCV/Modules/Interface/" );
	}
}

use Sample;


use strict;


my $lRc = 0;

my $WorkDir = "/media/Prime/To-Learn/BITS-MS/Sem4/WorkBase/TestDir/TestProj2_Work/";
=Anish
my $Repo = undef;
my $SCMRef = undef;

my $Option = "";

if ( $lRc == 0 )
{
	print " The WorkDir is given $WorkDir \n";
	
	$SCMRef = New Common($WorkDir);
	
	$SCMRef->GetAll($Repo);
}
exit ( $lRc );

=cut
__END__
