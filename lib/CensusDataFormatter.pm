#!/usr/bin/perl -wT
###############################################################################

package CensusDataFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printCensusData);

###############################################################################

=head1 NAME

    CensusDataFormatter - used to format the census data block

=head1 Synopsis

    use CensusDataFormatter;
    my $string=CensusDataFormatter::printCensusData($city);

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;

###############################################################################

=head2 printCensusData()

printCensusData strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printCensusData {
    my ($city) = @_;
    my $content;
    $content.=   " ".printGeneralInformation($city);
    $content.=   " ".printRacialBreakdown($city);
    $content.=   " ".printMisc($city);

    return $content;
}


###############################################################################

=head2 printGeneralInformation()

Print General Information about the census, including population estimate, elderly and children.

=cut

###############################################################################

sub printGeneralInformation {
    my ($city) = @_;
    my $population=$city->{'population_total'};

    my $content = << "EOF"
                    <h3>General Information</h3>
                    <ul>
                        <li> Pop. Estimate: $population </li>
                        <li> Children: $city->{'children'}->{'percent'}% ($city->{'children'}->{'population'}) </li>
                        <li> Elderly: $city->{'elderly'}->{'percent'}% ($city->{'elderly'}->{'population'}) </li>
                    </ul>
EOF
;
    return $content;
}


###############################################################################

=head2 printRacialBreakdown()

printRacialBreakdown formats details about the races.

=cut

###############################################################################

sub printRacialBreakdown {
    my ($city) = @_;

    my $content = "                    <h3>Racial Breakdown</h3>\n";
       $content.= "                    <ul>\n";
    foreach my $race (sort {$b->{'population'} <=> $a->{'population'}}  @{$city->{'races'}} ){
        $content.="                        <li>$race->{'population'} $race->{'race'} ($race->{'percent'}\%)</li>\n"

    }
       $content.= "                    </ul>\n";
    return $content;
}

###############################################################################

=head2 printMisc()

printMisc formats details about streets around the city.

=cut

###############################################################################

sub printMisc {
    my ($city) = @_;
    my $content = "                    <h3>Misc.</h3>\n";
       $content.= "                    <ul>\n";
       $content.="                        <li>".scalar( keys %{ $city->{'districts'}})." Districts</li>\n";
       $content.="                        <li>$city->{'business_total'} Businesses</li>\n";
       $content.="                        <li>$city->{'specialist_total'} Specialists</li>\n";
       $content.="                        <li>$city->{'housing'}->{'total'} Residences</li>\n";

       $content.= "                    </ul>\n";
    return $content;
}





1;
