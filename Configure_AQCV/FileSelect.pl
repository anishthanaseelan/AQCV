 use Tk::FileSelect;
use Tk;
my $top = MainWindow->new();
my $start_dir = '/usr/local';
 $FSref = $top->FileSelect(-directory => $start_dir);

 $file = $FSref->Show;


 MainLoop;
