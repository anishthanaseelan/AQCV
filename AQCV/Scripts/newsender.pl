use MIME::Lite;
use Net::SMTP::TLS;
BEGIN { @MIME::Lite::SMTP::ISA = qw(Net::SMTP::TLS); }

my $msg = MIME::Lite->new(
From => 'anishthanaseelan@gmail.com',
To => 'anishthanaseelan@gmail.com',
Subject => 'anishthanaseelan@gmail.com',
Type =>'multipart/related'
);
$msg->attach(Type => 'text/html',
Data => 'Hello',
);
#$msg->attach(Type => 'image/jpg',
#Id => 'logo.jpg',
#Path => 'template.files/image002.jpg',
#);
MIME::Lite->send('smtp','smtp.gmail.com',AuthUser=>'anishthanaseelan', AuthPass=>'kats07', Timeout => 60);
$msg->send();
