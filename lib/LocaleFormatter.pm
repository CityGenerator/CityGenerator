#!/usr/bin/perl -wT
###############################################################################

package LocaleFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printLandmarks printTaverns );

###############################################################################

=head1 NAME

    LocaleFormatter - used to format information about various locals.

=head1 DESCRIPTION

 This takes a city and prettily formats Taverns and Landmarks.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use Lingua::EN::Inflect qw( A ) ;
use POSIX;
use version;


###############################################################################

=head2 printLandmarks()

printLandmarks strips out Landmark info and formats it.

=cut

###############################################################################
sub printLandmarks {
    my ($city) = @_;
    my $content="";
    my $locale=$city->{'locale'};
    return $content;
}

###############################################################################

=head2 printTaverns()

printTaverns strips out Tavern information and formats it.

=cut

###############################################################################
sub printTaverns {
    my ($city) = @_;
    my $content="";
#    if  (scalar(@taverns) >0 ){
#        $content.="<p>Taverns are often central gathering places for the citizens. In $city->{'name'} can find the following taverns:</p>\n";
#        $content.="<ul class='one-column'>";
#        foreach $tavern ($city->{'taverns'}){
#
#        }
#
#        $content.="</li></ul>";
#    }else{
#        $content.="<p>There are no taverns in this town.</p>\n";
#    }
#



    return $content;
}
#sub describe_tavern{
#    my ($tavern,$tavernpoptotal)=@_;
#    #max =d(12+4 )+10=26
#    my $tavernmod= &d($city->{'size_modifier'}+$tavern->{'population'})*2 + $city->{'time'}->{'bar_mod'}  ;
#
#    my $tavernpop=max(0,  min(  int($city->{'population'}->{'size'}/2),   $tavernmod  )  );
#    if ($tavernpoptotal+$tavernpop <= int($city->{'population'}->{'size'}/2)){
#        $tavern->{'pop_count'}= $tavernpop;
#        $tavernpoptotal+=$tavernpop;
#    }
#    my $name="";
#    if ( defined $tavern->{'bartender'}->{'fullname'} ){ $name=" named ".$tavern->{'bartender'}->{'fullname'}  }
#    return ("<strong>$tavern->{'name'}</strong> is a $tavern->{'size'}, $tavern->{'condition'} tavern where the $tavern->{'class'} gather. The bar is owned by $tavern->{'bartender'}->{'race'}->{'article'} ".lc($tavern->{'bartender'}->{'race'}->{'content'})."$name who seems $tavern->{'bartender'}->{'behavior'}. The law $tavern->{'legal'} the patrons, however most violence is handled by $tavern->{'violence'}. Goods are $tavern->{'costdescription'}. You'll find $tavern->{'pop_count'} citizen(s) here.", $tavernpoptotal);
#}

1;
