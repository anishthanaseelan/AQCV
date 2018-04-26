# This example puts up a Perl/Tk form and when it's completed
# runs a moving graphic

use Tk;
use Time::HiRes qw(usleep);

$window = MainWindow->new;
$upper = $window->Frame();

# Rather than write a separate line of similar code for each
# widget, we've looped through a number of prompt / entry box
# pairs required.  Each entry box is linked into a hash member
# via -textvariable so there's no need to read values back -
# they're simply there!

@want = ("Name","Service No.","Course");
foreach my $question(@want) {
  $lhs = $upper->Label(-text => $question);
  $d{$question} = "";
  $rhs = $upper->Entry(-textvariable => \$d{$question});
  $lhs -> grid($rhs);
  }
$upper -> pack;

$confirm = "";

$done = $window->Button(-text => "Done", -command => \&review);
$echo = $window->Label(-textvariable => \$confirm);
$rusure = $window->Button(-text => "RUSure", -command => \&final,
        -state => "disabled");
$progress = $window -> Canvas(-width =>300, -height => 150,
        -background => "green");

$done -> pack;
$echo -> pack;
$progress -> pack;
$rusure -> pack;

MainLoop;

#############################################################

# The pretty moving graphic when the use's entry is complete

sub review {
   $confirm = "";
   foreach $el (@want) {
        $confirm .= "$el ... $d{$el}\n";
   }
   $rusure->configure(-state => "normal");

   $progress->createRectangle(0,75,300,100,-fill => "pink");
   $progress->createRectangle(0,0,20,150,-fill => "yellow", -tag => "stripe");
   $progress->createRectangle(0,50,300,75,-fill => "pink");
   for ($k=0; $k<=300; $k+= 3) {
        $progress->update;
        $progress->move("stripe",3,0);
        usleep(100000);
        }
}

# Log completed entries to file once the application is exited

sub final {
    open (FH,">>logger");
    print FH $confirm;
    close FH;
    exit;
}
