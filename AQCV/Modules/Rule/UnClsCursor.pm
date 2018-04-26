package Rule::UnClsCursor;

use strict;
use Utility;
use FileSql;
#  Constructure to Un closed cursor rule
#  name: New
#  @param : none
#  @return : object to Rule::UnClsCursor
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
        $Msg = &_checkCursorClose ( $FileRef ) ;
        $Result = 1 if ( length ( $Msg ) > 0 );
    }
    else
    {
        $Msg = "Unable to open file $File";
        $Result = 1;
    }
    
    return ( $Result , $Msg );
}

sub _checkCursorClose
{
	# This only ensures that when an open is present at least 1 close is also present.
	my $codeRef = shift;

    my $Msg = '';
	my $execRef = FileSql::getSqlExecInfo($codeRef);

	my %ocHash = ();

	foreach my $infoLine (@$execRef)
	{
		my ($name, $line, $type, undef, undef) = split (/~/, $infoLine);
		if ($type eq "OPEN" || $type eq "CLOSE")
		{
			$ocHash{$name}{$type} = $line;
		}
	}

	foreach my $name ( sort keys %ocHash )
	{
		my $openLine = $ocHash{$name}{"OPEN"};
		my $closeLine = $ocHash{$name}{"CLOSE"};
		if ($openLine && !$closeLine)
		{
			$Msg .= "LineNumber : $openLine : Cursor : $name \n";
		}
	}
	return $Msg;
}
1;
