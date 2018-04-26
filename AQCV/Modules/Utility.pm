package Utility;
###############################################################################
#
#   File Name:       Interface.pm
#   Author:          Anish Thanaseelan.K
#   Date:            10-Nov-2010
#   Purpose:         
#   Usage:           Utility
#
###############################################################################
use strict;

sub CopyFile()
{
   my $lRc = 0;
   my $File = shift;
   my @File = ();
   if ( open ( FILE , "<$File" ) )
   {
      @File = <FILE>;
      close ( FILE );
   }
   else
   {
      $lRc = 1;
      print "<ERROR>unable to open $File\n";
   }
   return ( $lRc , \@File );
}

sub SplitSource
{
   my $File = shift;
   my $FunctionCount = 1;
   my %Source = ();
   my $ComtCnt = 0;
   my $BlockCount = 0;
   my $FunctionName = "";

   $Source{$FunctionCount}{Name} = "Unknown";
   $Source{$FunctionCount}{Start} = 1;
   $Source{$FunctionCount}{End} = 0;
   
   my ( $lRc , $FileRef ) = &Utility::CopyFile ( $File );

   for ( my $i =0 ; $i < scalar ( @{$FileRef} ) && $lRc == 0 ;$i++ )
   {
      $FileRef->[$i] =~ s/\x0a|\x0d//g; # Remove CR and NL Chars
      $FileRef->[$i] =~ s/^\s+|\s+$//g; # Remove Trailing and heading Spaces
      
  
      push ( @{$Source{$FunctionCount}{Code}} , $FileRef->[$i] );
      
      if ( $FileRef->[$i] =~ /^$/ )
      {
		  next;
      }      

      # Skip Commented Lines 
      
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
         $BlockCount++ if ( $FileRef->[$i] =~ /\{/ );
         $BlockCount-- if ( $FileRef->[$i] =~ /\}/ );

         if ( $BlockCount == 0 && $FileRef->[$i] =~ /\}/ && $FunctionName !~ /^$/ )
         {
                 #print join ( "\n----" , @{$Source{$FunctionCount}{Code}}  );
                 $Source{$FunctionCount}{End} = $i;              
                 $FunctionName ="";
                 $FunctionCount++;
                
                 #<STDIN>;
                 
                 $Source{$FunctionCount}{Start} = $i+1;
                 $Source{$FunctionCount}{Name} = "Unknown";
         }
         elsif ( $BlockCount == 0 )
         {
            if ( $FileRef->[$i] =~ /^(\s*)(int|void|char)*(\s*)(\w+)(\s*)(\()/ && $FileRef->[$i] !~ /\;/ )
            {
            	$FunctionName = $4;
            	#print "<FUNCTION NAME> $FunctionName \n";
                $Source{$FunctionCount}{Name} = $FunctionName;
            }
         }
      } 
   }
   delete $Source{$FunctionCount}; 
   #print join ("\n<$Source{$_}{Name}>" , @{$Source{$_}{Code}} ) foreach sort keys %Source;
   return ( $lRc , \%Source );
}
sub MapChangedFunc
{
     my $SourceRef  = shift; 
     my $InvRef = shift;
     my $HasChange = 0;
     
     foreach my $FunctionCnt ( sort keys %{$SourceRef} )
     {
        foreach my $Line ( @{$InvRef} )
        {
            $HasChange = 1 if ( $Line >= $SourceRef->{$FunctionCnt}{Start}  
                        && $Line >= $SourceRef->{$FunctionCnt}{End} );
            
        }
        delete $SourceRef->{$FunctionCnt} if ( ! $HasChange );
        $HasChange = 0;
     }
     print join ( "\n" , keys %{$SourceRef} );
     #map { "print  $SourceRef->{$_}{Name} \n" } keys %{$SourceRef} ;
     return ( $SourceRef );
 }
 
=Anish
sub error()
{
	print STDERR "<Error>$_[0] .........\n";

	my $rc = 0;
	my @Data = ();
	my $Rpt = undef;
	my @Fieldlist = ( "Customer" , "Project" , "Type" , "Script" , "Error Occured" );

	( $rc , $Rpt )  = CreateRpt->new ( \@Fieldlist );

	if ( $rc == 0 )
	{
		@Data = ( "$CUST" , "$PROJ" , "$INST" , "$_[1]" , "$_[0]" );
		$rc = $Rpt->Data ( \@Data );
		$rc = $Rpt->Write( "$_[2]" , 'HTML' );
		$Rpt->reset();
		#&sendMail ( "$CUST" , "$PROJ" , "ERR-Collate" , "Collate Process Error" , "$_[2]" ) if ( $rc == 0 );
		&sendMail ( "All" , "All" , "ERR-Collate" , "Collate Process Error" , "$_[2]" ) if ( $rc == 0 );
	}
	else
	{
		prine STDERR "Error Occured while sending mail :". $Rpt->{errstr} . "\n";
	}
	return();

}
=cut
1;
