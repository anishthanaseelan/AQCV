package CreateRpt;

use strict;
use POSIX;

#  Constructure to the log creater
#  name: New
#  @param : none
#  @return : object to CreateRpt

sub New()
{
	my $rc = 0;
	my $msg = undef;
	my $class = shift;
	my $Fields = shift;
	my $self = {};
	my %LenHash = ();
	my $Fld = undef;
	my $i = 0;
	my  $len = 0;
	if ( scalar ( @{$Fields} ) < 0 )
	{
		$rc = 100;
		$msg = "No Fields where passed";
		&CreateRpt::error ( $self , $rc , $msg );
	}
	else
	{
		$self->{FLDNAMES} = $Fields;

		foreach $Fld ( @{$self->{FLDNAMES}} )
		{
			$LenHash{$Fld} = 0;
		}

		$self->{FLDLEN}	= \%LenHash; 

		for ( $i = 0 ; $i < scalar ( @{$self->{FLDNAMES}} ) ; $i++ )

		{
			$len = length ( ${$Fields}[$i] );

			if ( ${$self->{FLDLEN}}{${$self->{FLDNAMES}}[$i]} < $len )
			{
				${$self->{FLDLEN}}{${$self->{FLDNAMES}}[$i]} = $len;
			}

		}		

	}
	$self->{RECSEQ} = 0;
	bless ( $self  );
	#bless ( $self , $class );
	return ( $rc , $self );

}

sub Reset ()
{
	my $rc = 0;
	my $self = shift ;
	$self->{DATA} = undef;
	$self->{RECSEQ} = 0;
	return ( $rc );
}


sub Data
{
	my $rc = 0;
	my $msg = undef;
	my $self = shift;
	my $data = shift;
	my @FldArr = @{$self->{FLDNAMES}};
	my %LenArr = %{$self->{FLDLEN}};
	my $i = 0;
	my $len = 0;


	if ( scalar ( @{$data} ) != scalar ( @{$self->{FLDNAMES}} ) )
	{
		$rc = 567;
		my $dlen = scalar ( @{$data} );
		my $flen = scalar ( @{$self->{FLDNAMES}} );
		$msg ="Given Number of Data not equal to the Field list given : $dlen != $flen <@{$data}>";
		&CreateRpt::error ( $self , $rc , $msg );	
	}
	else
	{
		$self->{RECSEQ}++;
	
		for ( $i = 0 ; $i < scalar ( @{$self->{FLDNAMES}} ) ; $i++ )
		{
			$len = length ( ${$data}[$i] );

			if ( ${$self->{FLDLEN}}{${$self->{FLDNAMES}}[$i]} < $len )
			{
				${$self->{FLDLEN}}{${$self->{FLDNAMES}}[$i]} = $len;
			}

			${$self->{DATA}}[$self->{RECSEQ}][$i] = ${$data}[$i]; 
		}		
	}
	return ( $rc );

}

sub Write
{
	my $rc = 0;
	my $msg = undef;
	my $self = shift;
	my $FileName = shift;
	my $FileType = shift || "TXT";
	my $Hdr = "";
	my $Hdr1 = "+";
	my $Hdr2 = "|";
	my $Hdr3 = "+";
	my $NumberOfFields = 0;
	my $i = 0;
	my $j = 0;
	my $len = 0;
	my $LineData = undef;
	if ( defined  ( $self->{DATA} ) )
	{
		open ( rptH , ">$FileName" ) or $rc = 200;
		if ( $rc != 0 )
		{
			$msg = " Unable to open File : $FileName ";
			&CreateRpt::error ( $self , $rc , $msg );
		}
		else
		{
			if ( $FileType =~ /HTML/i )
			{
				#print "Writing the HTML File....\n";
				#$Hdr = "Content\-Type\: text\/html\;";
				$Hdr = "";
				$Hdr .= "<center><TABLE BORDER=3 CELLPADDING=5 cellspacing=5 width = 100% BORDERCOLOR=\"\#000000\">";
				$Hdr .= "<tr>";
				for ( $i = 0 ; $i < scalar ( @{$self->{FLDNAMES}}) ; $i++ )
				{
					$Hdr .= "<th bgcolor=\"\#808080\">${$self->{FLDNAMES}}[$i]</th>";
				}
				$Hdr .= "</tr>";
				for ( $i = 1 ; $i <=  $self->{RECSEQ} ; $i++ )
				{
					$LineData .= "<tr align =center bgcolor=\"\#C0C0C0\" >";
					for ( $j = 0 ; $j < @{$self->{FLDNAMES}} ; $j++ )
					{
						$LineData .= "<td align =center>${$self->{DATA}}[$i][$j]</td>";
					}
					$LineData .= "</tr>\n";
				}
				print rptH "$Hdr\n";
				print rptH "$LineData\n";
				close ( rptH );
				
			}
			else
			{
				print "Writing the TXT File...\n";
				for ( $i = 0 ; $i < scalar ( @{$self->{FLDNAMES}}) ; $i++ )
				{
					$len = ${$self->{FLDLEN}}{${$self->{FLDNAMES}}[$i]} ;
					$NumberOfFields++;

					$Hdr1 .= "-" x $len;
					$Hdr1 .= "-" ;

					$Hdr2 .= sprintf ( "%".$len."s" , ${$self->{FLDNAMES}}[$i] );
					$Hdr2 .= "|";  
				
					$Hdr3 .= "-" x $len ;
					$Hdr3 .= "+" ;

					#${$self->{DATA}}[$self->{RECSEQ}][$i] = ${$data}[$i]; 
				}		
				chop ( $Hdr1 );
				chop ( $Hdr3 );

				$Hdr1 =  $Hdr1 . "+";
				$Hdr3 =  $Hdr3 . "+";
				print rptH "$Hdr1 \n";
				print rptH "$Hdr2 \n";
				print rptH "$Hdr3 \n";
				for ( $i = 1 ; $i <=  $self->{RECSEQ} ; $i++ )
				{
					$LineData = "|";
					for ( $j = 0 ; $j < @{$self->{FLDNAMES}} ; $j++ )
					{
						$len = ${$self->{FLDLEN}}{${$self->{FLDNAMES}}[$j]} ;	
						$LineData .= sprintf ( "%".$len."s" , ${$self->{DATA}}[$i][$j] );
						$LineData .= "|";
					}
					print rptH "$LineData\n";
				}
				print rptH "$Hdr3 \n";
				close ( rptH );
			}

		}
			
	}
	return ( $rc );

}

sub error
{
    my $self = shift;

    my $rc = shift || undef;

    my $msg = shift || undef;

    $self->{errstr} = "" if ( ! defined $self->{errstr} );

    if ( defined $msg )
    {
            $self->{errstr} .= "\t CreateRpt:$msg\n";
    }
	else
	{
		$self->{errstr} .= "\t CreateRpt:Unknown Error Occured....$rc = $rc.\n";
	}

        return ;

}
sub DESTROY
{
}

1;
