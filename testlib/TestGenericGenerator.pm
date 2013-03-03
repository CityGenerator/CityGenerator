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




subtest 'test rand_from_array' => sub {
    my $result;
    srand(1);
    set_seed(1);
    my $testarray=[ 'foo','bar','baz'  ];
    my $loop=10;
    while ($loop-- > 0 ){
        $result=rand_from_array($testarray);
        is($result, 'foo', 'test array results');
    }
    set_seed(2);
    $loop=10;
    while ($loop-- > 0 ){
        $result=rand_from_array($testarray);
        is($result, 'baz', 'test array results');
    }
    done_testing();
};

#sub rand_from_array {
#    my ($array) = @_;
#    srand $seed;
#    my $index = int( rand( scalar @{ $array} ) );
#    return $array->[$index];
#}
#



subtest 'test set_seed' => sub {
    my $result;
    srand(1);

    $result=set_seed(3);
    is( $result, 3 , 'the given number');
    is( $GenericGenerator::seed, 3, 'the resulting seed' );
    $result=set_seed('broken');
    is( $result, 783234, 'a random number' );
    is( $GenericGenerator::seed, 783234, 'the resulting seed' );
    $result=set_seed();
    is( $result, 146253, 'a random number' );
    is( $GenericGenerator::seed, 146253, 'the resulting seed' );

    done_testing();
};


subtest 'test single d() ' => sub {
    my $result;
    srand(1);
    $result=d(3);
    is( $result, 1 );
    $result=d(3);
    is( $result, 2 );
    $result=d(3);
    is( $result, 3 );
    $result=d(3);
    is( $result, 2 );
    $result=d('pie');
    is( $result, 1 );
    done_testing();

  };

subtest 'test multi d() ' => sub {
    my $result;
    srand(1);
    $result=d('1d6');
    is( $result, 1 );
    $result=d('4d6');
    is( $result, 16 );
    $result=d('4d6');
    is( $result, 14 );
    $result=d('0d6');
    is( $result, 0 );
    $result=d('1d0');
    is( $result, 1 );
    $result=d('0d0');
    is( $result, 0 );

    done_testing();
  };












######################################33
subtest 'test parse_object parts' => sub {
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
    is( $result->{'content'},   'titlefoo prefoorootbarpostfoo trailerbar' );
    is( $result->{'title'},     'titlefoo' );
    is( $result->{'pre'},       'prefoo' );
    is( $result->{'root'},      'rootbar');
    is( $result->{'post'},      'postfoo');
    is( $result->{'trailer'},   'trailerbar' );
    srand(2);
    $result=parse_object($testObject) ;
    is( $result->{'content'}, 'titlebar prefoorootbarpostbar  trailerbar'  );
    done_testing();

  };

  subtest 'test parse_object chance' => sub {
    my $testObject={
        'title_chance'=>'50',
        'title'=>[
                    {'content'=>'titlefoo'},
                 ],
        'pre_chance'=>'50',
        'pre'=>[
                    {'content'=>'prefoo'},
                 ],
        'root'=>'rootfoo'
    };
    srand(1);
    my $result=parse_object($testObject) ;
    is( $result->{'content'},   'titlefoo prefoo' );
    is( $result->{'title'},     'titlefoo'  );
    is( $result->{'pre'},       'prefoo'  );
    srand(2);
    $result=parse_object($testObject) ;
    is( $result->{'content'}, 'prefoo'  );
    isnt( defined $result->{'title'}  , 'test title not defined, as expected');
    is( $result->{'pre'},       'prefoo'  );
    done_testing();
  };


  subtest 'test roll from array' => sub {
    my $result;
    srand(1);
    my $testdata={
          'option' => [
                      { 'min' => '1',  'max' => '10',  'content' => 'unheard of'  },
                      { 'min' => '11', 'max' => '30',  'content' => 'rare'        },
                      { 'min' => '29', 'max' => '100', 'content' => 'unusual'     },
                    ]

    };
    $result=roll_from_array(-1,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );
    $result=roll_from_array(3,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );
    $result=roll_from_array(10,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );
    $result=roll_from_array(11,$testdata->{'option'})->{'content'};
    is( $result, 'rare'  );
    $result=roll_from_array(110,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of', 'if it is beyond the max' );
    $testdata={
          'option' => [
                      {                'max' => '20',  'content' => 'unheard of'  },
                      { 'min' => '21', 'max' => '30',  'content' => 'rare'        },
                      { 'min' => '31',                 'content' => 'unusual'     },
                    ]

    };
    $result=roll_from_array(1,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );
    $result=roll_from_array(20,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );
    $result=roll_from_array(21,$testdata->{'option'})->{'content'};
    is( $result, 'rare'  );
    $result=roll_from_array(30,$testdata->{'option'})->{'content'};
    is( $result, 'rare'  );
    $result=roll_from_array(31,$testdata->{'option'})->{'content'};
    is( $result, 'unusual'  );
    $result=roll_from_array(101,$testdata->{'option'})->{'content'};
    is( $result, 'unusual'  );
    $testdata={
          'option' => [
                      { 'content' => 'unheard of'  },
                    ]
    };
    $result=roll_from_array(101,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );
    $result=roll_from_array(11,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );
    $testdata={
          'option' => [
                      { 'min' =>'10','content' => 'unheard of'  },
                    ]
    };
    $result=roll_from_array(1,$testdata->{'option'})->{'content'};
    is( $result, 'unheard of'  );


    done_testing();
  };






    done_testing();
1;

