
#!/usr/bin/perl -wT
###############################################################################

package CityscapeFormatter;

###############################################################################

=head1 NAME

    CityscapeFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a city, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( printCityscape);

use CGI;
use Data::Dumper;
use List::Util 'shuffle', 'min', 'max';
use POSIX;

###############################################################################

=head2 printCityscape()

printCityscape strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printCityscape {
    my ($city) = @_;
    my $content="";
    my $mainroads = $city->{'streets'}->{'mainroads'} == 0 ? "none": $city->{'streets'}->{'mainroads'};
    $mainroads = $mainroads eq "1" ? "1 is": $mainroads." are";
    my $roads = $city->{'streets'}->{'roads'} == 1 ? "is 1 road": "are ".$city->{'streets'}->{'roads'}." roads";

    $content="There $roads leading to $city->{'name'}; $mainroads major.";

    return $content;
}



###############################################################################

=head2 printWalls()

printWalls formats details about walls around the city.

=cut

###############################################################################

sub printWalls {
    my ($city) = @_;
    my $content = "No walls currently surround the city.";

    if   ( $city->{'walls'}->{'content'} ne 'none'){
        $content = "Visitors are greeted with a ".$city->{'walls'}->{'content'}. " that is ".$city->{'walls'}->{'height'}." feet tall. The city wall protects the core $city->{'protected_percent'}% of the city, with $city->{'tower_count'} towers spread along the $city->{'border_length'} kilometer wall.";
    }

    return $content;
}

1;
