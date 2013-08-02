#!/usr/bin/perl -wT
###############################################################################

package MapJSONFormatter;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( printCityMapJSON);

###############################################################################

=head1 NAME

    MapJSONFormatter - convert an object to a json string for js parsing.

=head1 DESCRIPTION

 This take a city, (or other object), strip out the mappy bits, and return json

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;

=head2 printCityMapJSON()

printCityMapJSON strips out important info from a City object and returns formatted JSON text

=cut

###############################################################################
sub printCityMapJSON {
    my ($city) = @_;
    my $mapdata;
# Things we might care about:
# overall city size determines scale
# 1sq km city
# each cell= 1 hectare?
    


    my $content = "";

    return $content;
}

1;

__END__


=head1 AUTHOR

Jesse Morgan (morgajel)  C<< <morgajel@gmail.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013, Jesse Morgan (morgajel) C<< <morgajel@gmail.com> >>. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation version 2
of the License.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=head1 DISCLAIMER OF WARRANTY

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=cut
