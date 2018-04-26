package Rule::SQLLogChk;

use strict;
#  Constructure to SQL logging check rule
#  name: New
#  @param : none
#  @return : object to Rule::SQLLogChk
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
#  @param : Function referance
#  @return : Validation result : boolean and Message
sub Validate
{
    my ( $self , $FunctionRef) = @_;
    my $ComtCnt = 0;
    my $Result = 0;
    my $Msg = "";
    my $LogStatment = '';
    my @FailedStats = ();
    my $SQLLogStart = '';
    #print "\nValidating Complexcity....";
    
    for ( my $i =0 ; $i < scalar ( @{$FunctionRef} ); $i++ )
    {
        $FunctionRef->[$i] =~ s/\x0a|\x0d//g;
        $FunctionRef->[$i] =~ s/^\s+|\s+$//g;
        $FunctionRef->[$i] =~ s/__T\(\"/\"/;
        $FunctionRef->[$i] =~ s/\"\)/\"/;

        # Skip Commented Lines

        if ( $FunctionRef->[$i] =~ /^\/\//  )
        {
            next ;
        }
        elsif ( $FunctionRef->[$i] =~ /^(\/\*)(.*)(\*\/)$/ ) #Single line comment
        {
            $ComtCnt = 0 if ( $ComtCnt == 1 ) ; # we have some unclosed comments
            next ;
        }
        elsif ( $FunctionRef->[$i] =~ /^\/\*/) #Commented Line Start
        {
            $ComtCnt = 1;
            next;
        }
        elsif ( $FunctionRef->[$i] =~ /\*\/$/ && $ComtCnt == 1  ) #Found a Comment end
        {
            #print "Found a Comment end $FunctionRef->[$i]\n";
            $ComtCnt = 0;
            next;
        }
        elsif ( $ComtCnt == 1 ) # Comment Continues
        {
            #print "Comment Continues $FunctionRef->[$i]\n";
            next;
        }
        else
        {
                if ( $FunctionRef->[$i] =~ /XXXLogWriteSQL/ )
                {
                    $SQLLogStart = 1 if ( $FunctionRef->[$i] !~ /\;$/ );
                    $LogStatment = $FunctionRef->[$i];
                }      
                elsif ( $FunctionRef->[$i] =~ /\;$/ && $SQLLogStart == 1  )
                {
                    $SQLLogStart = 0;
                    $LogStatment .= $FunctionRef->[$i];
                    $Msg = &ValidateSQLLog($LogStatment);
                    push ( @FailedStats , $Msg ) if ( length ( $Msg ) > 0 );
                }
                elsif ( $SQLLogStart == 1 ) 
                {
                    $LogStatment .= $FunctionRef->[$i];
                }

                else
                {
                    # Do Nothing 
                }
        }
    }
    if ( scalar ( @FailedStats ) > 0  )
    {
        $Msg = join ( "\n" , @FailedStats );
        $Result = 1;
    }

    return ( $Result , $Msg );
}

sub ValidateSQLLog
{
    my $Statment  = shift;
    my $Msg = '';
    
    if ( $Statment =~ /DEBUG/ || $Statment =~ /SQLCODE/ )
    {
        $Msg = $Statment ;
    }
    return $Msg;
}

1;
