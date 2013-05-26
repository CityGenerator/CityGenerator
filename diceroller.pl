#!/usr/bin/perl -wT
###############################################################################

use strict;
use warnings;


use Carp;
use CGI;
use Data::Dumper;
use lib "lib/";
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use Math::Complex ':pi';
use NPCGenerator;
use RegionGenerator;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;
#set_seed(1);

my @highestset=[];
my $highestsum=0;
my $highestcount=0;
my @lowestset=[];
my $lowestsum=1000;
my $lowestcount=0;

my $chartotal=100000;

my $metasum=0;

for  (my $char=1; $char<=$chartotal; $char++){
    my $stattotal=6;
    my @charstats;
    my $statsum=0;
    for  (my $stat=1; $stat<=$stattotal; $stat++){
        my $total=0;
        my @dice;
        #print "rolled ";
        for( my $count=1 ; $count <=4 ; $count++){
           my $die=&d(6) ;
            #print "$die ";
            if ($die == 1){
                $count --;
            }else{
                $total+=$die;
                push @dice, $die;
            }
        }
        #print ".\n";
        @dice = reverse  sort @dice;
        my $dud= pop @dice;
        $total-=$dud;
        #print "rolled: ".join (", ",@dice)." for a total of $total\n";
        push @charstats,$total;
        $statsum+=$total;
    }
    $metasum+=$statsum;
    #print "char stats: ".join (", ",sort @charstats)."  total:".$statsum."\n";
    if ($statsum> $highestsum){
        @highestset=@charstats;
        $highestsum=$statsum;
        $highestcount=1;
    }elsif ($statsum> $highestsum ){
        $highestcount++;
    }
    if ($statsum< $lowestsum){
        @lowestset=@charstats;
        $lowestsum=$statsum;
        $lowestcount=1;
    }elsif ($statsum> $lowestsum ){
        $lowestcount++;
    }
}
my $metaavg=$metasum/$chartotal;

print "average meta sum of $metaavg\n";
print "highest set( $highestsum): ".join (", ",sort @highestset)." $highestcount times \n";
print "lowest set( $lowestsum): ".join (", ",sort @lowestset)."  $lowestcount times \n";



