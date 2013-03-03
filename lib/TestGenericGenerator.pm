#!/usr/bin/perl -wT
###############################################################################
#
package TestGenericGenerator;

use strict;
use Test::More;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object);

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );

my $xml = new XML::Simple;
my $xml_data   = $xml->XMLin( "xml/data.xml",  ForceContent => 1, ForceArray => ['option'] );

#print Dumper $xml_data->{'cityname'}->{'title'};

subtest 'test parse_object parts' => sub {
    plan tests => 7;
    my $testObject={
        'title'=>[
                    {'content'=>'titlefoo'},
                    {'content'=>'titlebar'},
                 ],
        'pre'=>[
                    {'content'=>'prefoo'},
                    {'content'=>'prebar'},
                 ],
        'root'=>[
                    {'content'=>'rootfoo'},
                    {'content'=>'rootbar'},
                 ],
        'post'=>[
                    {'content'=>'postfoo'},
                    {'content'=>'postbar'},
                 ],
        'trailer'=>[
                    {'content'=>'trailerfoo'},
                    {'content'=>'trailerbar'},
                 ],
    };
    srand(1);
    my $result=parse_object($testObject) ;
    ok( $result->{'content'} eq 'titlefoo prefoorootbarpostfoo trailerbar' , 'test content: '.$result->{'content'} );
    ok( $result->{'title'} eq 'titlefoo' , 'test title: '.$result->{'title'});
    ok( $result->{'pre'} eq 'prefoo' , 'test title: '.$result->{'pre'});
    ok( $result->{'root'} eq 'rootbar' , 'test title: '.$result->{'root'});
    ok( $result->{'post'} eq 'postfoo' , 'test title: '.$result->{'post'});
    ok( $result->{'trailer'} eq 'trailerbar' , 'test title: '.$result->{'trailer'});
    srand(2);
    $result=parse_object($testObject) ;
    ok( $result->{'content'} eq 'titlebar prefoorootbarpostbar  trailerbar' , 'test content: '.$result->{'content'} );

  };

  subtest 'test parse_object chance' => sub {
    plan tests => 4;
    my $testObject={
        'title_chance'=>'50',
        'title'=>[
                    {'content'=>'titlefoo'},
                 ],
    };
    srand(1);
    my $result=parse_object($testObject) ;
    ok( $result->{'content'} eq 'titlefoo ' , 'test content: '.$result->{'content'} );
    ok( $result->{'title'} eq 'titlefoo' , 'test title: '.$result->{'title'});
    srand(2);
    $result=parse_object($testObject) ;
    ok( $result->{'content'} eq '' , 'test content is empty as expected' );
    ok( ! defined $result->{'title'}  , 'test title not defined, as expected');

  };

done_testing( 2 );

1;

