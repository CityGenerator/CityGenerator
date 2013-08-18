#!/usr/bin/perl -wT
###############################################################################

package GenericGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( get_seed set_seed rand_from_array roll_from_array d parse_object parse_template select_features seed generate_stats);

###############################################################################

=head1 NAME

    GenericGenerator - Base package used by other Generators

=head1 SYNOPSIS

    use GenericGenerator;
    GenericGenerator::set_seed();

=cut

###############################################################################

#TODO add a bound function- bound(1,100,$val)
use Carp;
use Data::Dumper;
use Exporter;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use Carp qw(longmess);
###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

No datafiles are directly used by GenericGenerator.

=cut

#Yes, I know this is bad. I'm aware. Yes, I know.
# that's why I want to make this a class.
our $seed;


=head1 INTERFACE


=cut

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the city structure.




###############################################################################

=head2 get_seed()

Return the $seed value

=cut

###############################################################################
sub get_seed {

    return $seed;
}

###############################################################################

=head2 set_seed()

Check the parameters for cityID and set the seed accordingly.
This is what allows us to return to previously generated hosts.

=cut

###############################################################################
sub set_seed {
    my ($newseed) = @_;

    if ( ( !defined $newseed ) or $newseed !~ m/^\d+$/x ) {
        $newseed = int rand(1000000);
    }
    $seed = $newseed;
    srand $seed;
    return $seed;
}


###############################################################################

=head2 rand_from_array()

Select a random item from an array.

=cut

###############################################################################
sub rand_from_array {
    my ($array) = @_;
    if ( ref $array ne 'ARRAY' ) {
        croak "you passed in something that wasn't an array reference. @!".longmess();
    }
    return $array->[ rand @$array ];
}

###############################################################################

=head2 roll_from_array()

When passed a roll and a list of items, check the min and max properties of 
each and select the one that $roll best fits otherwise use the first item.

=cut

###############################################################################
sub roll_from_array {
    my ( $roll, $items ) = @_;
    my $selected_item = $items->[0];
    for my $item (@$items) {

        if ( defined $item->{'min'} and defined $item->{'max'} ) {
            if ( $item->{'min'} <= $roll and $item->{'max'} >= $roll ) {
                $selected_item = $item;
                last;
            }
        } elsif ( !defined $item->{'min'} && !defined $item->{'max'} ) {
            $selected_item = $item;
            last;
        } elsif ( !defined $item->{'min'} ) {
            if ( $item->{'max'} >= $roll ) {
                $selected_item = $item;
                last;
            }
        } else {
            if ( $item->{'min'} <= $roll ) {
                $selected_item = $item;
                last;
            }
        }
    }
    return $selected_item;
}

###############################################################################

=head2 d()

This serves the function of rolling a dice- a d6, d10, etc.

=cut

###############################################################################
sub d {
    my ($die) = @_;

    # d as in 1d6
    if ( $die =~ /^\d+$/x ) {
        return int( rand($die) + 1 );
    } elsif ( $die =~ /^(\d+)d(\d+)$/x ) {
        my $dicecount = $1;
        $die = $2;
        my $total = 0;
        while ( $dicecount-- > 0 ) {
            $total += &d($die);
        }
        return $total;
    } else {
        croak "$die is not a valid dice format.";

    }
}

###############################################################################

=head2 parse_object()

A horribly named subroutine to parse out and randomly select the parts. This
method is really the crux of the name generation stuff.

=cut

###############################################################################
sub parse_object {
    my ($object) = @_;
    my $newobj = { 'content' => '' };

    # We currently only care about 4 parts; FIXME to pull this list dynamically
    foreach my $part (qw/title pre root post trailer/) {

        # Make sure that the part exists for this object.
        if ( defined $object->{$part} ) {

            my $newpart;

            # If the object is an array, we're going to shuffle
            # the array and select one of the elements.
            if ( ref( $object->{$part} ) eq 'ARRAY' ) {

                # Shuffle the array and pop one element off
                my @parts = shuffle( @{ $object->{$part} } );
                $newpart = pop(@parts);

                # If the object is a Hash, we presume that there's only one choice
            } elsif ( ref( $object->{$part} ) eq 'HASH' and $object->{$part}->{'content'} ) {

                # rename for easier handling
                $newpart = $object->{$part};
            }

            # make sure the element has content;
            # ignore it if it doesn't.
            if ( defined $newpart->{'content'} ) {
                if (

                    # If no chance is defined, add it to the list.
                    ( !defined $object->{ $part . '_chance' } ) or

                    # If chance is defined, compare it to
                    # the roll, and add it to the list.
                    ( &d(100) <= $object->{ $part . '_chance' } )
                    )
                {

                    $newobj->{$part} = $newpart->{'content'};
                    if ( $part eq 'title' ) {
                        $newpart->{'content'} = "$newpart->{'content'} ";
                    } elsif ( $part eq 'trailer' ) {
                        $newpart->{'content'} = " $newpart->{'content'}";
                    }
                    $newobj->{'content'} .= $newpart->{'content'};
                }
            }
        }
    }

    #FIXME Sloppy as hell but it resolves the multiplying spaces issue
    $newobj->{'content'} =~ s/\s+/ /xg;

    # return the slimmed down version
    return $newobj;
}


###############################################################################

=head2 generate_stats()

generate the stats and their descriptions from the xml

=cut

###############################################################################
sub generate_stats {
    my ($ds, $xml) = @_;

    #Loop through each tag underneath stats- it's important that <stat> does NOT have any attributes
    foreach my $statname (keys %{ $xml->{'stats'} } ){
        #Simplify the reference for reading pleasure.
        my $stat=$xml->{'stats'}->{$statname};

        # select one of the stats options.
        $ds->{'stats'}->{$statname}=d(100) if (!defined $ds->{'stats'}->{$statname} );
        my $statoption= roll_from_array($ds->{'stats'}->{$statname}, $stat->{'option'});
        $ds->{$statname."_description"}= $statoption->{'content'} if (!defined $ds->{$statname."_description"});
    }
    return $ds;
}



###############################################################################

=head2 select_features()

Set the given features from the xml

=cut

###############################################################################
sub select_features {
    my ($ds, $xml) = @_;
    # ds means datastructure. nice and generic.

    #Loop through each tag underneath feature- it's important that <feature> does NOT have any attributes
    foreach my $featurename (keys %{ $xml->{'feature'} } ){

        #Simplify the reference for reading pleasure.
        my $feature=$xml->{'feature'}->{$featurename};
        # select one of the feature's options.
        my $featureoption= rand_from_array($feature->{'option'});

        #if this feature has a chance attribute, create a feature_roll
        if (defined $feature->{'chance'} ){
            $ds->{$featurename."_roll"} = d(100) if (!defined $ds->{$featurename."_roll"}); 
        }
        # if no chance is defined or our roll is less than the chance, add this feature to the datastructure
        if (!defined $feature->{'chance'} || $ds->{$featurename."_roll"} <= $feature->{'chance'} ){
            # If the feature isn't already defined, assign the content.
            $ds->{$featurename}= $featureoption->{'content'} if (!defined $ds->{$featurename});

            # If this featureoption has a type, assign it as well if we don't already have one.
            if (defined $featureoption->{'type'}){
                $ds->{$featurename."_type"} = $featureoption->{'type'}  if (!defined $ds->{$featurename."_type"}); 
            }
        }
    }
    return $ds;
}


###############################################################################

=head2 parse_template()

parse a structures template and fill it with it's bretheren.

=cut

###############################################################################
sub parse_template{
    my ($ds, $tmplname)=@_;

    if (!defined $tmplname){
        $tmplname='template';
    }

    my $tt_obj = Template->new();
    my $content="";
    my $tmpl="$ds->{$tmplname}";
    my $template=$ds->{'template'};

    $tt_obj->process(\$tmpl, $ds, \$content ) || die "Template bad? $tmpl\n$tt_obj->error()";
    
    #NOTE because of the way process() runs, 'template' is wiped out.
    # while tmplname may be 'template', we need to set it twice in case it's not. Fugly, I know.
    $ds->{'template'}=$template;
    $ds->{$tmplname}=$content;

    return $ds;
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
