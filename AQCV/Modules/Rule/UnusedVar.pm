package Rule::UnusedVar;

use strict;
use Utility;
use FileEc;

#  Constructure to Unused variable rule
#  name: New
#  @param : none
#  @return : object to Rule::UnusedVar
  
  
sub New
{
    my ($class,$Attrib) = @_;
    my $self = 
	{
		"Attribs" => $Attrib,
	};
    bless $self, $class;
    return $self;
}

#  
#  name: Validate
#  @param : File Name
#  @return : Validation result : boolean and Message

sub Validate
{
    my ( $self , $File) = @_;
    
    my $Result = 0;
    my $Msg = "";
    my ( $lRc , $FileRef ) = &Utility::CopyFile($File);
    #print "OPening File $File .. <$lRc>\n";
    if ( $lRc == 0)
    {
        $Msg = &_checkUnusedVariable ( $FileRef ) ;
        $Result = 1 if ( length ( $Msg ) > 0 );
    }
    else
    {
        $Msg = "Unable to open file $File";
        $Result = 1;
    }
    
    return ( $Result , $Msg );
}
    
sub _checkUnusedVariable
{
	my $codeRef = shift;

    my $Msg = "";
	my $functionRef = FileEc::getFunctionList($codeRef);
	my @functions = @$functionRef;
    my $strippedVar = '';

	foreach my $functionName (@functions)
	{
		my $functionStartLine = FileEc::getFunctionLineNumbers($codeRef, $functionName);
		($functionStartLine, undef) = split (/~/, $functionStartLine);
		my $functionCodeRef = FileEc::getFunctionCode($codeRef, $functionName);
		my $varInfoRef = FileEc::getVariableInfo($functionCodeRef);
		my $varsRef = FileEc::getVariables(undef, $varInfoRef);
		foreach my $var (@$varsRef)
		{
			my $count = 0;
			foreach my $line (@$functionCodeRef)
			{
				($strippedVar, undef) = split (/\[/, $var, 2);
				if ($line =~ m/$strippedVar/)
				{
					$count++;
				}
			}
			if ($count < 2)
			{
				my $varLineNum = $functionStartLine + (FileEc::getVariableLineNumber(undef, $var, $varInfoRef) - 1);
                $Msg .= "LineNumber : $varLineNum : Variable : $var \n";
			}
		}
	}
	return $Msg;
}

1;
