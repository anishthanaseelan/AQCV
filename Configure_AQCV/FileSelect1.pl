#!/usr/local/bin/perl
use Tk;
# Main Window
my $mw = new MainWindow;

#Making a text area
my $txt = $mw -> Scrolled('Text',-width => 50,-scrollbars=>'e') -> pack ();

#Declare that there is a menu
my $mbar = $mw -> Menu();
$mw -> configure(-menu => $mbar);

#The Main Buttons
my $file = $mbar -> cascade(-label=>"File", -underline=>0, -tearoff => 0);
my $others = $mbar -> cascade(-label =>"Others", -underline=>0, -tearoff => 0);
my $help = $mbar -> cascade(-label =>"Help", -underline=>0, -tearoff => 0);

## File Menu ##
$file -> command(-label => "New", -underline=>0, 
		-command=>sub { $txt -> delete('1.0','end');} );
$file -> checkbutton(-label =>"Open", -underline => 0,
		-command => [\&menuClicked, "Open"]);
$file -> command(-label =>"Save", -underline => 0,
		-command => [\&menuClicked, "Save"]);
$file -> separator();
$file -> command(-label =>"Exit", -underline => 1,
		-command => sub { exit } );

## Others Menu ##
my $insert = $others -> cascade(-label =>"Insert", -underline => 0, -tearoff => 0);
$insert -> command(-label =>"Name", 
	-command => sub { $txt->insert('end',"Name : Binny V A\n");});
$insert -> command(-label =>"Website", -command=>sub { 
	$txt->insert('end',"Website : http://www.geocities.com/binnyva/\n");});
$insert -> command(-label =>"Email", 
	-command=> sub {$txt->insert('end',"E-Mail : binnyva\@hotmail.com\n");});
$others -> command(-label =>"Insert All", -underline => 7,
	-command => sub { $txt->insert('end',"Name : Binny V A
Website : http://www.geocities.com/binnyva/
E-Mail : binnyva\@hotmail.com");
  	});

## Help ##
$help -> command(-label =>"About", -command => sub { 
	$txt->delete('1.0','end');
	$txt->insert('end',
	"About
----------
This script was created to make a menu for a\nPerl/Tk tutorial.
Made by Binny V A
Website : http://www.geocities.com/binnyva/code
E-Mail : binnyva\@hotmail.com"); });

MainLoop;

sub menuClicked {
	my ($opt) = @_;
	$mw->messageBox(-message=>"You have clicked $opt.
This function is not implanted yet.");
}
