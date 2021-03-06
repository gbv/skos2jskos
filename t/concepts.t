use v5.14;
use Test::More;
use Test::Output;
use File::Temp;
use JSON;

my $dir = File::Temp::tempdir();

my $exit;
sub run { system( $^X, 'script/skos2jskos', @_ ); $exit = $? >> 8 }

sub slurp_ndjson {
    open my $fh, "<", shift;
    [ map { JSON->new->utf8->decode($_) } <$fh> ];
}

run( '-q', 't/ex/concepts.ttl', '-d', $dir );
ok !$exit, 'ok';

my $concepts = slurp_ndjson("$dir/concepts.ndjson");
$concepts = [ sort { $a->{uri} cmp $b->{uri} } @$concepts ];

is_deeply $concepts,
  [
    {
        inScheme => [ { uri => 'http://example.org/' } ],
        topConceptOf => [ { uri => 'http://example.org/' } ],
        notation => ["\x{2603}"],
        prefLabel => { en => 'A', de => "\x{c4}" },
        type     => ['http://www.w3.org/2004/02/skos/core#Concept'],
        uri      => 'http://example.org/A',
        narrower => [ { uri => 'http://example.org/B' } ]
    },
    {
        inScheme => [ { uri => 'http://example.org/' } ],
        notation => ["\x{2639}"],
        type => ['http://www.w3.org/2004/02/skos/core#Concept'],
        uri  => 'http://example.org/B',
    }
  ],
  'converted concepts';

done_testing;
