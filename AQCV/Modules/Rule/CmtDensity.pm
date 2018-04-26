package Rule::CmtDensity;

use strict;
use Utility;
#  Constructure to Comment Density Rule
#  name: New
#  @param : none
#  @return : object to Rule::CmtDensity
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
    my $ComtCnt = 0;
    my $BlockCount = 0;
    my $PathCount = 0;
    my $Result = 0;
    my $Msg = "";
    my $FileRef = undef;
    my $lRc = 0;
    my $BlankCnt = 0;
    my $CommentCnt = 0;
    my $SourceCnt = 0;
    my $Density = 0;
    
    ( $lRc , $FileRef )= &Utility::CopyFile ( $File );
    
 
    for ( my $i =0 ; $i < scalar ( @{$FileRef} ) && $lRc == 0; $i++ )
    {
        $FileRef->[$i] =~ s/\x0a|\x0d//g;
        $FileRef->[$i] =~ s/^\s+|\s+$//g;
        $FileRef->[$i] =~ s/__T\(\"/\"/;
        $FileRef->[$i] =~ s/\"\)/\"/;

        # Skip Commented Lines
        if ( $FileRef->[$i] =~ /^$/  )
        {
            $BlankCnt++;
            next;
        }
        $CommentCnt++;
        if ( $FileRef->[$i] =~ /^\/\//  )
        {
            next ;
        }
        elsif ( $FileRef->[$i] =~ /^(\/\*)(.*)(\*\/)$/ ) #Single line comment
        {
            $ComtCnt = 0 if ( $ComtCnt == 1 ) ; # we have some unclosed comments
            next ;
        }
        elsif ( $FileRef->[$i] =~ /^\/\*/) #Commented Line Start
        {
            $ComtCnt = 1;
            next;
        }
        elsif ( $FileRef->[$i] =~ /\*\/$/ && $ComtCnt == 1  ) #Found a Comment end
        {
            #print "Found a Comment end $FileRef->[$i]\n";
            $ComtCnt = 0;
            next;
        }
        elsif ( $ComtCnt == 1 ) # Comment Continues
        {
            #print "Comment Continues $FileRef->[$i]\n";
            next;
        }
        else
        {
            $CommentCnt--;
            $SourceCnt++;
        }
    }
    
    #Crash test
    #$SourceCnt = $CommentCnt = 0;
  
    $Density = ( $CommentCnt / ( $SourceCnt + $CommentCnt ) ) * 100;
    
    #print "$self->{Attribs}->{Cutoff} :: $Density ::$SourceCnt\ n";
    
   #if ( $Density < $self->{"Attribs"}->{"Cutoff"}  )
   
    if ( $Density < 30  )
    {
        $Result = 1;
        $Msg = "Comment Density is $Density , should be > 30\%";
    }

    return ( $Result , $Msg );
}

1;
