##!/usr/bin/perl -w

#my $lRc = 0;
#$lRc = system ( "svn checkout");





 use Mail::Sender;
 $sender = new Mail::Sender
  { smtp=>'smtp.gmail.com',port=>'587',auth=>'CRAM-MD5',on_errors=>'code',from => 'anishthanaseelan@gmail.com', authid=>'anishthanaseelan' , authpwd=>'kats07' , debug_level => 4, debug => "/root/Desktop/file.txt"};
 $sender->MailFile({to => 'anishthanaseelan@gmail.com',
  subject => 'Here is the file',
  msg => "I'm sending you the list you wanted.",
  file => '/root/Projects/AQCV/Scripts/test.txt'});
 $sender->Close;
			if ( @Mail::Sender::Errors[$The_SenderObj->{error}] ne "OK" )
			{
				my $msg  = " Error Occured while sending the mail :\n @Mail::Sender::Errors[$The_SenderObj->{error}] \n";
				print STDERR "$msg \n";
				$lRc = 100;
			}
			else
			{
				print "Mail sent Sucessfully......... @Mail::Sender::Errors[$The_SenderObj->{error}] \n";
			}
