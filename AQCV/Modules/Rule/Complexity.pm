package Rule::Complexity;

use strict;
#  Constructure to Complexity Rule
#  name: New
#  @param : none
#  @return : object to Rule::Complexity
sub New
{
    my ($class,$Attrib) = @_;
    my $self = 
	{
		"Attribs" => $Attrib
	};
    bless $self, $class;
    return $self;
}
#  
#  name: Validate
#  @param : Functiona referance
#  @return : Validation result : boolean and Message
sub Validate
{
    my ( $self , $FunctionRef) = @_;
    my $ComtCnt = 0;
    my $BlockCount = 0;
    my $PathCount = 0;
    my $Result = 0;
    my $Msg = "";
    #print "\nValidating Complexity....";
    
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
                if ( $FunctionRef->[$i] =~ /if\s*\(|else if\s*\(|\s*case|\s*default|while\s*\(|for\s*\(/ )
                {
                    $PathCount++;
                }
        }
    }
    #if ( $PathCount > $self->{"Attribs"}->{"Cutoff"} )
    if ( $PathCount > 9 ) 
    {
        $Result = 1;
        $Msg = "Complexity Index is $PathCount, Should be < 9";
    }
    
    #print "Complexity Index is $PathCount Goal : $self->{Attribs}->{Cutoff}";
    
    return ( $Result , $Msg );
}

1;
