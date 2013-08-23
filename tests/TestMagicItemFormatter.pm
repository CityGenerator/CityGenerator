
#!/usr/bin/perl -wT
###############################################################################
#
package TestMagicItemFormatter;

use strict;
use warnings;

use MagicItemFormatter;
use MagicItemGenerator;
use CityGenerator;
use Data::Dumper;
use Exporter;
use GenericGenerator;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test MagicItem Summary' => sub {
    my $item = MagicItemGenerator::create_item( { seed => 1 } );
    my $itemsummary = MagicItemFormatter::printSummary($item);
    isnt($itemsummary, undef, "");

	subtest 'Test MagicItem Summary' => sub {
	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'potion', 'sideeffect_roll'=>99 } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");

	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'potion', 'sideeffect_roll'=>1 } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");
	};
	subtest 'Test MagicItem Summary' => sub {
	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'scroll','sideeffect_roll'=>1, 'decorations_roll'=>1  } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");

	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'scroll','sideeffect_roll'=>99, 'decorations_roll'=>99 } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");
	};
	subtest 'Test MagicItem Summary' => sub {
	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'armor','sideeffect_roll'=>1, 'decorations_roll'=>1, 'ability_roll'=>1 } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");

	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'armor','sideeffect_roll'=>99, 'decorations_roll'=>99,'ability_roll'=>99  } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");
	};
	subtest 'Test MagicItem Summary' => sub {
	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'weapon','sideeffect_roll'=>1, 'decorations_roll'=>1, 'ability_roll'=>1 } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");

	    $item = MagicItemGenerator::create_item( { seed => 1, 'item'=>'weapon','sideeffect_roll'=>99, 'decorations_roll'=>99, 'ability_roll'=>99 } );
	    $itemsummary = MagicItemFormatter::printSummary($item);
	    isnt($itemsummary, undef, "");
	};

    done_testing();
};


1;
