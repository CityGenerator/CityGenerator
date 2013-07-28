#!/usr/bin/perl -wT
###############################################################################

package PeopleFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printCitizens printTravelers);

###############################################################################

=head1 NAME

    PeopleFormatter - used to format people details

=head1 DESCRIPTION

 Prints and formats details about the people citizens and travelers

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use Lingua::EN::Inflect qw( A PL_N ) ;
use POSIX;
use version;

###############################################################################

=head2 printCitizens()

printCitizens strips out important info from a City object and returns details about citizens

=cut

###############################################################################
sub printCitizens {
    my ($city) = @_;
    my $content;
    if (scalar( @{$city->{'citizens'} } ) == 0 ){
        $content="None are of note.";
    }else{

        $content.="The following citizens are worth mentioning: \n";
        $content.="<ul> \n";
        foreach my $citizen ( @{$city->{'citizens'}} ){
            if ($citizen->{'race'} eq 'other'){
                $citizen->{'race'}="oddball";
            }
            $content.="<li>";
            if ( defined $citizen->{'name'}){
                $content.="<b>".$citizen->{'name'}."</b> is ".A( lc($citizen->{'race'}))." ";
            }else{
                $content.="A ".$citizen->{'noname'}." ";
            }
            $content.="who is known in ".$citizen->{'scope'}." as being ".A($citizen->{'skill'})." $citizen->{'profession'}. \n";
            $content.=ucfirst($citizen->{'pronoun'})." appears ".$citizen->{'behavior'}.". \n";
            $content.="</li>";
        }
    }

    $content.="</ul>";

    return $content;
}

###############################################################################

=head2 printTravelers()

printTravelers strips out important info from a City object and returns details 
about people travelers.

=cut

###############################################################################
sub printTravelers {
    my ($city) = @_;
    my $content;
    $content.="Children account for $city->{'children'}->{'percent'}% ($city->{'children'}->{'people'}), and the elderly account for $city->{'elderly'}->{'percent'}% ($city->{'elderly'}->{'people'}) of this $city->{'age_description'} city. \n";

    return $content;
}





1;
