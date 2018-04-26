#!/usr/local/bin/perl


use XML::Simple;
use Data::Dumper;

$xml = new XML::Simple;

$Config = $xml->XMLin("AQCV.xml");


print Dumper($Config);

=Anish
use XML::Parser;
 
# initialize parser and read the file
$parser = new XML::Parser( Style => 'Tree' );

 my $parser = new XML::Parser ( 
				'Non-Expat-Options' => { my_option => "toto" },
				Handlers => { 
                             Start   => \&hdl_start,
                             End     => \&hdl_end,
                             Char    => \&hdl_char,
                             Default => \&hdl_def,
                           });
my $tree = $parser->parsefile( "AQCV.xml" );
  
  print join ( "\n" , keys %{$tree} );
 # The Handlers
 sub hdl_start{
     my ($p, $elt, %atts) = @_;
      print "<START> <$p>, <$elt> \n";
      print "<$_>,<$p->{$_}>\n" foreach keys %$p;
      print "<$_>,<$atts{$_}>v\n" foreach keys %atts;
 }
  
 sub hdl_end{
     my ($p, $elt) = @_;
  print "<END> <$p>, <$elt> \n";
     
 }
 
 sub hdl_char {
     my ($p, $str) = @_;
  print "<CHAR> <$p>, <$str> \n";
     $message->{'_str'} .= $str;
 }
 
 sub hdl_def 
 { 
	my ($p, $str) = @_;
	print "<DEF> <$p>, <$str> \n";
}  
 
 
=cut
#BEGIN
#{
	#push ( @INC , "/root/Projects/AQCV/Modules");
	#push ( @INC , "/root/Projects/AQCV/Modules/Interface");
#}


#use strict;
##use SVN;
##use Menu;
#use Cwd;

#my $lRc = 0;

#my $lDir = "";

 #my $lFile = '';
 #my $lReps = '';
 #my $qwee = '';



#print "Hello";
#exit;
#=Ansih

#if ( scalar ( @ARGV ) == 1 )
#{
	## The Work Directory is Given
	#if ( -d "$ARGV[0]" )
	#{
		#$WorkDir = $ARGV[0];
	#}
	#elsif ( -f "$ARGV[0]" )
	#{
		#$WorkFile = $ARGV[0];
		#$lRc = 1;
		#print "$WorkFile is File; File operation Implemetation is not Done \n";
		## This will be used when working with othe SCM Tools
	#}

	#else
	#{
		#print "$WorkDir is not a Directory \n";
		#$WorkDir = $ARGV[0];
		#$lRc = 0;
	#}

	 
#} 
#elsif ( scalar ( @ARGV ) == 0 )
#{
	## Dir not given, Take the current dir 
	#$WorkDir = cwd();
#}
#else
#{
	#print "Usage Error : perl MySCM.pl ( <Dir to Work on> ) \n";
	#$lRc = 1;
#}
#=cut
