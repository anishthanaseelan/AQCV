use Tk;
use strict;
use warnings;

#changes focus on ANY key BUT tab

my $win = MainWindow->new();

$win->Button(-text=>'Other Window',-command=>\&otherwindow)->pack;

sub otherwindow
{
    my $otherwin = $win->Toplevel;
    my $foo = $otherwin->Entry->pack;
    my $bar = $otherwin->Entry->pack;
    my $baz = $otherwin->Entry->pack;
    my $boo = $otherwin->Entry->pack;
    my $baa = $otherwin->Entry->pack;

    &defineOrder($foo,$baa,$bar,$boo,$baz);

}    

sub defineOrder
{
    my $widget;
    for (my $i=0; defined( $_[$i+1] ); $i++)
    {

#        $_[$i]->bind('<Tab>', [\&focus, $_[$i+1]]);
        $_[$i]->bind('<Any-KeyPress>', [\&focus, $_[$i+1]]);
    }

    # Uncomment this line if you want to wrap around
    #$_[$#_]->bind('<Key-Return>',  [\&focus, $_[0]]);

    $_[0]->focus;

}

sub focus
{
    my ($tk, $self) = @_;
    $self->focus;

}

MainLoop();

__END__ 
