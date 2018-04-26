use XML::LibXML;
#use XML::LibXML::Schema;

my $schema = XML::LibXML::Schema->new(location => 'file.xsd' );
my $parser = XML::LibXML->new;

my $xml    = 'file.xml';
my $doc    = $parser->parse_file( $xml );

eval { $schema->validate( $doc ) };
die $@ if $@;

print  "$xml is valid\n";
