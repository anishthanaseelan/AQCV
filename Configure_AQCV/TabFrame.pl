    use Tk::TabFrame;

    $TabbedFrame = $widget->TabFrame
       (
        -font => '-adobe-times-medium-r-normal--20-*-*-*-*-*-*-*',
        -tabcurve => 2,
        -padx => 5,
        -pady => 5,
        #[normal frame options...],
       );

    #font     - font for tabs
    #tabcurve - curve to use for top corners of tabs
    #padx     - padding on either side of children
    #pady     - padding above and below children

    $CurrentSelection = $l_Window->cget ('-current');
    $CurrentSelection = $l_Window->cget ('-raised');

    #current  - (Readonly) currently selected widget
    #raised   - (Readonly) currently selected widget

    $child = $TabbedFrame->Frame # can also be Button, Label, etc
       (
        -caption => 'Tab label',
        -tabcolor => 'yellow',
        #[widget options...],
       );

    #caption  - label text for the widget's tab
    #tabcolor - background for the tab button
