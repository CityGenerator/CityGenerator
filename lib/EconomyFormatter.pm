
#!/usr/bin/perl -wT
###############################################################################

package EconomyFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printResources printBusinesses);

###############################################################################

=head1 NAME

    EconomyFormatter - used to format the economy.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Summary of economy details.

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use Lingua::Conjunction;
use Lingua::EN::Inflect qw(A PL_N);
use Lingua::EN::Numbers qw(num2en);
use Number::Format;
use POSIX;
use version;

###############################################################################

=head2 printResources()

printResources strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printResources {
    my ($city) = @_;
    my $content="";
    if  (scalar(@{$city->{'resources'}}) >0 ){
        $content.="<p>$city->{'name'} is known for the following resources:</p>\n";
        $content.="<ul class='threecolumn'>";
        foreach my $resource (  @{  $city->{'resources'} } ){
            $content.="<li>".$resource->{'content'}."</li>";
        }

        $content.="</ul>";
    }else{
        $content.="<p>There are no resources worth mentioning.</p>\n";
    }

    return $content;
}

sub printBusinesses {
    my ($city) = @_;
    my $content="";
    if  (scalar( keys %{$city->{'businesses'} }   ) >0 ){
        $content.="<p>You can find the following establishments in $city->{'name'}:</p>\n";
        $content.="<ul class='threecolumn'>";
        foreach my $resource ( keys %{$city->{'businesses'} }  ){
            my @resources = split(/,/, $resource)  ;
            @resources=shuffle( @resources);
            my $resourcename=pop @resources;
            my $count=$city->{'businesses'}->{$resource}->{'count'};
            $content.="<li>$count ".PL_N($resourcename, $count)."</li>";
        }

        $content.="</ul>";
    }else{
        $content.="<p>There are no businesses worth mentioning.</p>\n";
    }

    return $content;
}


1;
