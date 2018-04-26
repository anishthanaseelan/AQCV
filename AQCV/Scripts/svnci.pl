##!/usr/bin/perl -w

#my $lRc = 0;
#$lRc = system ( "svn commit");

open ( FILE , "/root/Projects/AQCV/Reports/Violation_root__7541.HTML" );

 use Net::SMTP::TLS;  
 my $mailer = new Net::SMTP::TLS(  
     'smtp.gmail.com',  
     Hello   =>      'smtp.gmail.com',  
     Port    =>      587,  
     User    =>      'anishthanaseelan',  
     Password=>      'kats07');  
 $mailer->mail('anishthanaseelan@gmail.com');  
 $mailer->to('anishthanaseelan@gmail.com');  
 $mailer->data;  
#$mailer->datasend("To: [b]Test\@DOMAINNAME.com[/b]\n");
#$mailer->datasend("From: A Test Account <[b]TEST\@DOMAINNAME.com[/b]>\n");
$mailer->datasend("Subject: A Test Message\n");
$mailer->datasend("MIME-Version: 1.0\r\nContent-type: text/html\r\nContent-Transfer-Encoding: 7bit \r\n");

 while ( <FILE> )
 {
	 $mailer->datasend("$_");
}
 $mailer->dataend;  
 $mailer->quit;

#use Email::Stuff;

#Email::Stuff->from ($from );
#Email::Stuff->to ($to );
#Email::Stuff->subject ($subject);
#Email::Stuff->text_body ( $text );
#Email::Stuff->using( ‘Gmail’, username => $user, password => $pass );
#Email::Stuff->send;
#perl -MMail::Sender -e 'Mail::Sender->printAuthProtocols("smtp.gmail.com")'
