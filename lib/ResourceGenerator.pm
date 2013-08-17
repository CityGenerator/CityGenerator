#!/usr/bin/perl -wT
use strict;
use Data::Dumper;
use XML::Simple;
use lib "lib/";
use List::Util 'shuffle', 'min', 'max' ;
use POSIX;
use GenericGenerator;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object seed);
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

my $xml = XML::Simple->new();
my $xml_data = $xml->XMLin( "xml/resources.xml", ForceContent => 1, ForceArray => ['option'] );

#print Dumper $xml_data;

my $d = 0;
my $loop = 0;
my $max = 20;

my $output = "\n";
my $age;
my $scarcity = '';
my $wildlife = '';
my $group = '';
my $type = '';
my $suffix;
my $natural = '';
my $ravished; 

while ($loop < $max) {
    
    # Wildlife
    #
    $d = d(100);    
    $scarcity = roll_from_array( $d, $xml_data->{'scarcity'}->{'option'} )->{'content'};
    $wildlife = rand_from_array( $xml_data->{'wildlife'}->{'animal'} );
    $type = rand_from_array( $xml_data->{'wildlife'}->{'type'} )->{'content'};
    $ravished = rand_from_array( $xml_data->{'ravished'}->{'type'} )->{'content'} . ' ' .rand_from_array( $xml_data->{'ravished'}->{'option'} )->{'content'};

    $output .= "* $scarcity $type $wildlife->{'content'} $wildlife->{'group'} $ravished\n";
    
    # Natural
    #
    $d = d(100);
    $scarcity = roll_from_array( $d, $xml_data->{'scarcity'}->{'option'} )->{'content'};
    $natural = rand_from_array( $xml_data->{'natural'}->{'type'} );
    $age = rand_from_array( $xml_data->{'natural'}->{'age'}->{'option'} )->{'content'};
    $suffix = rand_from_array( $natural->{'suffix'}->{'option'} )->{'content'};
    $ravished = rand_from_array( $xml_data->{'ravished'}->{'type'} )->{'content'} . ' ' .rand_from_array( $xml_data->{'ravished'}->{'option'} )->{'content'};
    $output .= "* $scarcity $age $natural->{'content'} $suffix $ravished\n";
    
    $loop++;
}
print Dumper $output;

1;
__END__
