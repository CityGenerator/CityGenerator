#!/usr/bin/perl -wT
###############################################################################
#
package TestCritterFormatter;

use strict;
use warnings;

use CritterGenerator;
use Data::Dumper;
use Exporter;
use CritterFormatter;
use Test::More;
use XML::Simple;

use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( );


subtest 'Test Critter Summary' => sub {
    my $critter = CritterGenerator::create( { seed => 1 } );
    my $crittertext = CritterFormatter::printSummary($critter);
    like($crittertext,"/The .+ is a.+ .+ .+ that .+.\n Adventurers should be wary of its .+ .+, and it's reported .+.\n /");
    done_testing();
};

subtest 'Test Critter Description' => sub {
    my $critter = CritterGenerator::create( { seed => 1 } );
    $critter->{'covering'}=undef;
    $critter->{'subtype'}=undef;
    my $crittertext = CritterFormatter::printDescription($critter);
    like($crittertext,"/The .+ appears to be a?? .+ .+ that .+\.\n /"       );
    like($crittertext,"/It .+ with its .+\.\n When confronted, it .+\.\n/"  );

    $critter->{'covering'}="hair";
    $critter->{'subtype'}="is a dog";
    $crittertext = CritterFormatter::printDescription($critter);
    like($crittertext,"/The .+ appears to be a?? .+ .+ that .+\.\n /"       );
    like($crittertext,"/Its .+ body is covered with .+, .+ .+\.\n It .+\.\n /"       );
    like($crittertext,"/It .+ with its .+\.\n When confronted, it .+\.\n/"  );

    done_testing();
};
subtest 'Test Critter Data' => sub {
    my $critter = CritterGenerator::create( { seed => 1 } );
    my $crittertext = CritterFormatter::printData($critter);
    is($crittertext, "");
    done_testing();
};

done_testing();
1;
