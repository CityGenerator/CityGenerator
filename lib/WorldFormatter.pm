
#!/usr/bin/perl -wT
###############################################################################

package WorldFormatter;

###############################################################################

=head1 NAME

    WorldFormatter - used to format the summary.

=head1 DESCRIPTION

 This take a world, strips the important info, and generates a Sumamry.

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( printSummary);

use CGI;
use Data::Dumper;
use List::Util 'shuffle', 'min', 'max';
use POSIX;

=head2 printSummary()

printSummary strips out important info from a City object and returns formatted text.

=cut

###############################################################################
sub printSummary {
    my ($world) = @_;
    my $content="";
    $content.="$world->{'name'} is a $world->{'size'}, $world->{'basetemp'} planet orbiting a $world->{'starsystem_name'}. ";
    $content.="$world->{'name'} has a $world->{'moons_name'}, a $world->{'air'} $world->{'atmosphere'}->{'color'} atmosphere and fresh water is $world->{'freshwater_description'}. ";
    $content.="The surface of the planet is $world->{'surfacewater_percent'}% covered by water. ";
    return $content;
}

1;
