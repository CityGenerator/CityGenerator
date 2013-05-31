#!/usr/bin/perl -wT
###############################################################################
#
package TestGovtGenerator;

use strict;
use warnings;
use Test::More;
use GovtGenerator;
use GenericGenerator qw( set_seed );

use Data::Dumper;
use XML::Simple;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( );


subtest 'test create_govt' => sub {
    my $govt;
    set_seed(1);
    $govt=GovtGenerator::create_govt();
    is($govt->{'seed'},41630);

    $govt=GovtGenerator::create_govt({'seed'=>12});
    is($govt->{'seed'},12);

    done_testing();
};

subtest 'test set_govt_type' => sub {
    my $govt;
    $govt=GovtGenerator::create_govt({'seed'=>41630});
    GovtGenerator::set_govt_type($govt);
    is($govt->{'seed'},41630);
    is($govt->{'description'},"dictator");
    is($govt->{'type_approval_mod'},-1);

    $govt=GovtGenerator::create_govt({'seed'=>12, 'description'=>'foo', 'type_approval_mod'=>5,});
    GovtGenerator::set_govt_type($govt);
    is($govt->{'seed'},12);
    is($govt->{'description'},"foo");
    is($govt->{'type_approval_mod'},5);

    done_testing();
};


subtest 'test set_reputation' => sub {
    my $govt;
    $govt=GovtGenerator::create_govt({'seed'=>41630});
    GovtGenerator::set_reputation($govt);
    is($govt->{'seed'},41630);
    is($govt->{'reputation'},'praised');

    #FIXME check for collisions like approval_mod
    $govt=GovtGenerator::create_govt({'seed'=>12, 'reputation'=>'foo', 'reputation_approval_mod'=>'5'});
    GovtGenerator::set_reputation($govt);
    is($govt->{'seed'},12);
    is($govt->{'reputation_approval_mod'},5);
    is($govt->{'reputation'},"foo");

    done_testing();
};


subtest 'test generate_stats' => sub {
    my $govt;
    $govt=GovtGenerator::create_govt({'seed'=>41630});
    GovtGenerator::generate_stats($govt);
    is($govt->{'seed'},41630);
    is_deeply($govt->{'stats'},{'corruption'=>86, 'approval'=>58, 'efficiency'=>51, 'influence'=>76, 'unity'=>52 });

    #FIXME check for collisions like approval_mod
    $govt=GovtGenerator::create_govt({'seed'=>12, 'stats'=>{'corruption'=>12, 'approval'=>33, 'efficiency'=>44, 'influence'=>55, 'unity'=>66}});
    GovtGenerator::generate_stats($govt);
    is($govt->{'seed'},12);
    is_deeply($govt->{'stats'},{'corruption'=>12, 'approval'=>32, 'efficiency'=>44, 'influence'=>55, 'unity'=>66 });

    done_testing();
};


subtest 'test set_secondary_power' => sub {
    my $govt;
    $govt=GovtGenerator::create_govt({'seed'=>41630});
    GovtGenerator::set_secondary_power($govt);
    is($govt->{'seed'},41630);
    is($govt->{'secondary_power'}->{'plot'},"quietly denounces");
    is($govt->{'secondary_power'}->{'power'},'traveler');
    is($govt->{'secondary_power'}->{'subplot_roll'},"86");
    is($govt->{'secondary_power'}->{'subplot'},undef);

    $govt=GovtGenerator::create_govt({'seed'=>2, 'secondary_power'=>{'plot'=>'foo', 'subplot_roll'=>3}});
    GovtGenerator::set_secondary_power($govt);
    is($govt->{'seed'},2);
    is($govt->{'secondary_power'}->{'plot'},"foo");
    is($govt->{'secondary_power'}->{'power'},"traveler");
    is($govt->{'secondary_power'}->{'subplot_roll'},"3");
    is($govt->{'secondary_power'}->{'subplot'},"looking to overthrow the government");

    $govt=GovtGenerator::create_govt({'seed'=>2, 'secondary_power'=>{'plot'=>'foo', 'power'=>'bar', 'subplot_roll'=>3, 'subplot'=>'baz'}});
    GovtGenerator::set_secondary_power($govt);
    is($govt->{'seed'},2);
    is($govt->{'secondary_power'}->{'plot'},"foo");
    is($govt->{'secondary_power'}->{'power'},"bar");
    is($govt->{'secondary_power'}->{'subplot_roll'},"3");
    is($govt->{'secondary_power'}->{'subplot'},"baz");

    done_testing();
};









1;
