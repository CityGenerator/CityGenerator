#!/usr/bin/perl -w

use strict;
use JSON;
use XML::Simple;
use Data::Dumper;




foreach my $xmlfile (@ARGV){

    my $xml = XML::Simple->new();
    local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';
    my $xml_data            = $xml->XMLin( $xmlfile,          ForceContent => 1, ForceArray => ['option'] );

    my $jsonfile=$xmlfile;
    $jsonfile=~s/xml/json/g;
    print "$xmlfile  $jsonfile\n";

    my $JSON  = JSON->new->utf8->pretty(1);
    $JSON->convert_blessed(1);
    open JSONDATA, ">",$jsonfile;
    print JSONDATA $JSON->encode($xml_data);
    
    close JSONDATA;
}
