#!/usr/local/bin/perl
use strict;
use Tk;
use Tk::NoteBook;
use Tk::FileSelect;
use Tk::Listbox;
use XML::Simple;
use Data::Dumper;
use Tk::MsgBox;

my $book = undef;
my $mw = MainWindow->new();
my ( $tab1 , $tab2, $tab3 , $tab4 ) = undef;
my $start_dir = '/root/Projects/AQCV/Scripts/';

my $LoadDialog = $mw->FileSelect(-directory => $start_dir ,-filter => '*.xml');
my $SaveDialog = $mw->FileSelect(-directory => $start_dir, -filter => '*.xml');
my $FileName = '';
my $menubar = $mw->Menu;
my $Data = undef;
my $AdminId = '';
my $RuleID = '';
my @Admins = ();
my @Rules - ();
my $AdminListbox = undef;
my $txtAdmin = undef;
my $txtRule = undef;
my $lblAdmin = undef;
my $btnAddAdmin = undef;
my $btnRmAdmin = undef;
my $btnAddRule = undef;
my $btnRmRule = undef;
my $lblAdminList = undef;
my $FrameList = undef;
my $FrameDesc = undef;
my $lblRuleList  = undef;
my $RuleListbox = undef;
my $lblRuleDesc = undef;
my %CurrRuleData = ();

my $xmlin = new XML::Simple;
my $xmlout = new XML::Simple;

$mw->geometry( "400x400" );
$mw->configure(-menu => $menubar);

my $file = $menubar->cascade(-label => '~File',-tearoff => 0 );
#my $help = $menubar -> cascade(-label =>"Close", -underline=>0, -tearoff => 0 , -command =>\&exit,);

$file->command(
    -label       => 'New',
    -accelerator => 'Ctrl-n',
    -underline   => 0,
    -command => [\&NewTabs],

);
$file->separator;
$file->command(
    -label       => 'Open',
    -accelerator => 'Ctrl-o',
    -underline   => 0,
    -command => [\&BrowseXML],
);
$file->separator;

$file->command(
    -label       => 'Save',
    -accelerator => 'Ctrl-s',
    -underline   => 0,
    -command => [\&SaveXML],
);
$file->command(
    -label       => 'Save As',
    -accelerator => 'Ctrl-a',
    -underline   => 1,
    -command => [\&SaveAsXML],
);
$file->separator;
$file->command(
    -label       => "Close",
    -accelerator => 'Ctrl-w',
    -underline   => 0,
    -command     => \&exit,
);

MainLoop;

sub NewTabs
{
	@Admins = ();
	@Rules = ();
	$Data = undef;
	$FileName = '';
	&createNoteBook;
}
sub createNoteBook
{
	$book->destroy if ( $book );
	$book = $mw->NoteBook()->pack( -fill=>'both', -expand=>1 );

	$tab1 = $book->add( "Sheet 1", -label=>"General", -createcmd=>[\&createGeneralTab , "Read"] );
	$tab2 = $book->add( "Sheet 2", -label=>"Mail", -createcmd=>[\&createMailTab, "Read"]);
	$tab3 = $book->add( "Sheet 3", -label=>"Admin", -createcmd=>[\&createAdminTab , "Read"] );
	$tab4 = $book->add( "Sheet 4", -label=>"Rules", -createcmd=>[\&createRuleTab , "Read"]);
}
sub BrowseXML
{
	while ()
	{
		$LoadDialog = $mw->FileSelect(-directory => $start_dir ,-filter => '*.xml');
		$FileName = $LoadDialog->Show;
		#print "<File><$FileName> \n";    
		
		if ( -f $FileName && $FileName =~ /\.xml/ )
		{
			&createNoteBook();
			$Data = undef;
			@Admins = ();
			@Rules = ();
			&LoadFromFile($FileName);
			last;
		}
		else
		{
			my $w = $mw->MsgBox(-type => "okcancel",
								-detail  => "Please press 'OK' select xml or 'Cancel' to cancel this operation",
								-message => "Please select a correct configuration file",
								-title   => "Open" );
			if ( $w->Show eq 'cancel' )
			{
				last;
			}
		}
	}
}
sub LoadFromFile
{
	$Data = $xmlin->XMLin($FileName ); 
	@Rules = keys %{$Data->{Rules}};
	print Dumper($Data);
	@Admins = @{$Data->{Admins}{Userid}};
}
sub Copytofile
{
	$FileName = shift;
	my $out = $xmlout->XMLout($Data , RootName => 'AQCV', AttrIndent => 1,OutputFile => $FileName); 
	#$xmlout->XMLout({'contentkey'=>$Data,'outputfile'=>$FileName});
	#my $out = $xmlout->XMLout({'contentkey'=>$Data,'outputfile'=>$FileName});
	print "\n $out \n";
	if ( -f $FileName )
	{
		print "Copied to $FileName \n";
	}
	
}
sub SaveXML
{
	$SaveDialog = $mw->FileSelect(-directory => $start_dir, -filter => '*.xml');
	$FileName = $SaveDialog->Show if ( $FileName =~ /^$/ );
	
	&Copytofile($FileName);

	print "<FILE> $FileName \n";

}

sub SaveAsXML
{
	$SaveDialog = $mw->FileSelect(-directory => $start_dir, -filter => '*.xml');
	$FileName = $SaveDialog->Show;
	
	if ( -f $FileName  )
	{
		my $w = $mw->MsgBox(-type => "okcancel",
							-detail  => "Press 'OK'Overwrite or 'Cancel' to cancel this operation",
							-message => "File already present",
							-title   => "Save" );
		if ( $w->Show eq 'ok' )
		{
			&Copytofile($FileName);
		}
	}
	else
	{
		&Copytofile($FileName);
	}
	print "<FILE> $FileName \n";

}
sub createMailTab
{
	my %Fields = ("ReportMailID" => "Report Mail ID","AdminMailID" => "Admin Mail ID","SMTPServer" =>"SMTP Server","Port" => "Port");
	foreach my $FieldName(keys %Fields)
	{
		my $lhs = $tab2->Label(-text => $Fields{$FieldName});
		my $rhs = $tab2->Entry(-textvariable => \$Data->{Mail}{$FieldName});
		$lhs -> grid($rhs);
	}

}	
sub createGeneralTab
{
	my %Fields = ("ReportPath" => "Report Path","LocalTempDir" => "Local Temp. Dir","RepoTempDir" =>"Repo Temp. Dir");
	foreach my $FieldName(keys %Fields)
	{
		my $lhs = $tab1->Label(-text => $Fields{$FieldName});
		my $rhs = $tab1->Entry(-textvariable => \$Data->{General}{$FieldName});
		$lhs -> grid($rhs);
	}
	

}	
sub AddAdmin
{
	push ( @Admins , $AdminId ) if ( $AdminId =~ /^\w{3,8}$/);
	$AdminId = "";
	
}
sub RemoveAdmin
{
	
	if ( scalar ( @Admins ) > 0 && $AdminListbox->curselection->[0] =~ /\d/ )
	{
		splice ( @Admins, $AdminListbox->curselection->[0], 2 );
		#my @Arr = @Admins;
		#@Admins = ();
		$AdminListbox->delete($AdminListbox->curselection->[0]);
		#$AdminListbox->insert('end', @Arr ) if scalar ( @Arr ) > 0;
	}
	#$AdminListbox->delete ( $AdminListbox->curselection , $AdminListbox->curselection );
}

sub AddRule
{
	push ( @Rules , $RuleID ) if ( $RuleID =~ /^\w{3,8}$/);
	$AdminId = "";
	
}
sub RemoveRule
{
	splice ( @Rules, $RuleListbox->curselection->[0], 2 ) 
	if ( scalar ( @Rules ) > 0 && $RuleListbox->curselection->[0] =~ /\d/ );

	#$AdminListbox->delete ( $AdminListbox->curselection , $AdminListbox->curselection );
}
sub createAdminTab
{

	my $AdminTitle = "AQCV Administrators";
	my @Fields = ( "Admin ID" );
	my $FieldName = "Admin ID";
	#foreach my $FieldName(@Fields)
	#{
	$lblAdmin = $tab3->Label(-text => $FieldName);
	$txtAdmin = $tab3->Entry(-textvariable => \$AdminId);

	$lblAdmin -> grid ( -row => 0, -column => 0, -sticky => 'e');
	$txtAdmin -> grid ( -row => 0, -column => 2, -sticky => 'w');
	
	$btnAddAdmin = $tab3->Button(-text => "Add", -command => \&AddAdmin ,  );
	$btnRmAdmin = $tab3->Button(-text => "Remove", -command => \&RemoveAdmin );
	
	$btnAddAdmin -> grid ( -row => 2, -column => 2, -sticky => 'e');
	$btnRmAdmin -> grid ( -row => 4, -column => 2, -sticky => 'e');
	$FieldName = "Admin List";
	$lblAdminList = $tab3->Label(-text => $FieldName);
	
	$AdminListbox = $tab3->Scrolled(
    'Listbox',
    -listvariable  => \@Admins,
    -selectmode    => 'single',
    -bg            => 'gray',
    -scrollbars    => 'ose',
    -activestyle   => 'dotbox',
);


$lblAdminList -> grid ( -row => 3, -column => 0, -sticky => 'e');
$AdminListbox -> grid ( -row => 3, -column => 2, -sticky => 'w');

#$tab3->pack;

}

sub createRuleTab
{
	my $FieldName = "Rule List";
	my $GridRowID = 0;
	
	$FrameList = $tab4->Frame(-borderwidth => 2, -relief => 'groove');
	$FieldName = "Rule Describtion";
	$FrameDesc = $tab4->Frame(-borderwidth => 3, -relief => 'groove');
	$FrameList -> grid ( -row => 0, -column => 0, -sticky => 'w');
	$FrameDesc -> grid ( -row => 0, -column => 1, -sticky => 'w');
	$FieldName = "Rule Name";
	$lblRuleList = $FrameList->Label(-text => $FieldName);
	$txtRule = $FrameList->Entry(-textvariable => \$RuleID);
	$btnAddRule = $FrameList->Button(-text => "Add", -command => \&AddRule ,  );
	$btnRmRule = $FrameList->Button(-text => "Remove", -command => \&RemoveRule );
	
	$RuleListbox = $FrameList->Scrolled(
    'Listbox',
    -listvariable  => \@Rules,
    -selectmode    => 'single',
    -bg            => 'gray',
    -scrollbars    => 'ose',
    -activestyle   => 'dotbox'
    );
    $lblRuleList -> grid ( -row => 0, -column => 0, -sticky => 'w');
	$txtRule -> grid ( -row => 1, -column => 0, -sticky => 'w');
	$btnAddRule -> grid ( -row => 2, -column => 0, -sticky => 'e');
	$RuleListbox -> grid ( -row => 3, -column => 0, -sticky => 'w');
	$btnRmRule -> grid ( -row => 4, -column => 0, -sticky => 'e');
	
	$FieldName = "Rule Describtion :";
	$lblRuleDesc = $FrameDesc->Label(-text => $FieldName);
	$lblRuleDesc -> grid ( -row => $GridRowID, -column => 0, -sticky => 'w');
	my %Fields = ("Name" => "Rule Name","Type" => "Rule Type","Mode" =>"Mode","Module" => "Module");
	foreach my $FieldName(keys %Fields)
	{
		$GridRowID++;
		my $lhs = $FrameDesc->Label(-text => $Fields{$FieldName});
		if ( $FieldName eq "Type" )
		{
			my $lblType = $FrameDesc -> Label(-text=>"Type ");
			my $FrameType = $FrameDesc->Frame(-borderwidth => 3, -relief => 'groove');
			my $rdb_Func = $FrameType -> Radiobutton(-text=>"Function",  	-value=>"FUNCTION",  -variable=>\$CurrRuleData{$FieldName});
			my $rdb_file = $FrameType -> Radiobutton(-text=>"File",	-value=>"FILE",-variable=>\$CurrRuleData{$FieldName});
			my $rdb_pgm = $FrameType -> Radiobutton(-text=>"Program",	-value=>"PROGRAM",-variable=>\$CurrRuleData{$FieldName});
			$rdb_Func -> grid ( -row => 0, -column => 1, -sticky => 'e');
			$rdb_file -> grid ( -row => 0, -column => 2, -sticky => 'e');
			$rdb_pgm -> grid ( -row => 0, -column => 3, -sticky => 'e');
			$lblType -> grid ( -row => 0, -column => 3, -sticky => 'e');
			$lblType -> grid ( -row => $GridRowID, -column => 0, -sticky => 'w');
			$FrameType -> grid ( -row => $GridRowID, -column => 1, -sticky => 'w');

		}
		elsif (  $FieldName eq "Mode" )
		{
			my $lblMode = $FrameDesc -> Label(-text=>"Mode ");
			my $FrameMode = $FrameDesc->Frame(-borderwidth => 3, -relief => 'groove');
			my $rdb_Actv= $FrameMode -> Radiobutton(-text=>"Active",  	-value=>"ACTIVE",  -variable=>\$CurrRuleData{$FieldName});
			my $rdb_pasv = $FrameMode -> Radiobutton(-text=>"Passive",	-value=>"PASSIVE",-variable=>\$CurrRuleData{$FieldName});
			$rdb_Actv -> grid ( -row => 0, -column => 0, -sticky => 'e');
			$rdb_pasv -> grid ( -row => 0, -column => 1, -sticky => 'e');
			$lblMode -> grid ( -row => $GridRowID, -column => 0, -sticky => 'w');
			$FrameMode -> grid ( -row => $GridRowID, -column => 1, -sticky => 'w');
			
		}
		else
		{
			my $rhs = $FrameDesc->Entry(-textvariable => \$CurrRuleData{$FieldName});
			$lhs -> grid ( -row => $GridRowID, -column => 0, -sticky => 'w');
			$rhs -> grid ( -row => $GridRowID, -column => 1, -sticky => 'w');
		}
		
	}	

}
