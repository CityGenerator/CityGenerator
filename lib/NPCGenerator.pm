#!/usr/bin/perl -wT
###############################################################################

package NPCGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( generate_npc_names get_races names_data create xml_data generate_npc_name );

#TODO make generate_name method for use with namegenerator
###############################################################################

=head1 NAME

    NPCGenerator - used to generate NPCs

=head1 SYNOPSIS

    use NPCGenerator;
    my $npc=NPCGenerator::create();

=cut

###############################################################################

#TODO treat certain data as stats...
use Carp qw(longmess croak);
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use Lingua::EN::Gender;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item * F<xml/data.xml>

=item * F<xml/npcs.xml>

=item * F<xml/npcnames.xml>

=item * F<xml/specialists.xml>

=back

=head1 INTERFACE


=cut

###############################################################################
my $xml_data        = $xml->XMLin( "xml/data.xml",        ForceContent => 1, ForceArray => ['option'] );
my $npc_data        = $xml->XMLin( "xml/npcs.xml",        ForceContent => 1, ForceArray => ['option'] );
my $names_data      = $xml->XMLin( "xml/npcnames.xml",    ForceContent => 1, ForceArray => ['option','allow'] );
my $specialist_data = $xml->XMLin( "xml/specialists.xml", ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 create( params )

Create an NPC Object and fill it out.

=cut

###############################################################################

sub create {
    my ($params) = @_;
    my $npc = {};


    if ( defined $params ) {
        foreach my $key ( keys %$params ) {
            $npc->{$key} = $params->{$key};
        }
    }
    if ( defined $npc->{'seed'} ) {
        $npc->{'seed'} = GenericGenerator::set_seed( $npc->{'seed'} );
    }
    GenericGenerator::set_seed($npc->{'seed'});
    GenericGenerator::generate_stats($npc, $npc_data);
    GenericGenerator::select_features($npc,$npc_data);
    
    set_race($npc);

    generate_npc_name( $npc->{'race'}, $npc );

    #FIXME this if statement is stupid; we should set it when the name is chosen and any is used.
    $npc->{'race'}='oddball'    if ($npc->{'race'} eq 'any' or $npc->{'race'} eq 'other');
    set_reputation($npc);
    set_attitudes($npc);
    set_class($npc);
    set_sex($npc);
    set_profession($npc);
    set_motivation($npc);
    return $npc;
}
###############################################################################

=head2 set_reputation()

Take a provided NPC and set their reputation scope

=cut

###############################################################################

sub set_reputation {
    my ($npc) = @_;
    $npc->{'reputation_scope'} = rand_from_array( $xml_data->{'scope'}->{'option'} )->{'content'};
    return $npc;
}

###############################################################################

=head2 set_race()

Take a provided NPC and set their race

=cut

###############################################################################

sub set_race {
    my ($npc) = @_;

    #Available races is an array of race names.
    $npc->{'available_races'} = [ keys %{ $names_data->{'race'} } ] if ( !defined $npc->{'available_races'} );
    $npc->{'available_races'} = [ shuffle( @{ $npc->{'available_races'} } ) ];

    $npc->{'race'} = rand_from_array( $npc->{'available_races'} ) if ( !defined $npc->{'race'} );
    delete $npc->{'available_races'};
    $npc->{'race'} = lc $npc->{'race'};

    return $npc;
}


###############################################################################

=head2 set_class()

Take a provided NPC and set their class.

=cut

###############################################################################

sub set_class {
    my ($npc) = @_;

    $npc->{'class_roll'} = d(100) if ( !defined $npc->{'class_roll'} );
    $npc->{'class'} = roll_from_array( $npc->{'class_roll'}, $npc_data->{'class'}->{'option'} )->{'content'}
        if ( !defined $npc->{'class'} );

    return $npc;
}




###############################################################################

=head2 set_sex()

Take a provided NPC and select a sex from the list of available choices.

=cut

###############################################################################

sub set_sex {
    my ($npc) = @_;
    my $sex = roll_from_array( &d(100), $npc_data->{'sex'}->{'option'} );

    $npc->{'sex'}     = $sex->{'content'} if ( !defined $npc->{'sex'} );
    $npc->{'pronoun'} = $sex->{'pronoun'} if ( !defined $npc->{'pronoun'} );
    $npc->{'posessivepronoun'}= pronoun ( 'posessive-subjective', $npc->{'sex'} ) if (!defined $npc->{'posessivepronoun'} );
    return $npc;

}


###############################################################################

=head2 set_profession( npc, specialistlist )

Take a provided NPC and select a profession from the list of available choices.

=cut

###############################################################################

sub set_profession {
    my ($npc) = @_;

    #First make sure we have allowed list
    if ( !defined $npc->{'allowed_professions'} || scalar( @{ $npc->{'allowed_professions'} } ) == 0 ) {
        $npc->{'allowed_professions'} = [ keys %{ $specialist_data->{'option'} } ];
    }

    # shuffle that list
    $npc->{'allowed_professions'} = [ shuffle( @{ $npc->{'allowed_professions'} } ) ];

    # select a potential specialty and remove allowed professionals.
    my $specialty = pop @{ $npc->{'allowed_professions'} };
    delete $npc->{'allowed_professions'};

    # at this point we have specialty selected....

    #set profession to $specialty if it's not already set.
    $npc->{'profession'} = $specialty if ( !defined $npc->{'profession'} );


    # If a business is not defined...
    if ( !defined $npc->{'business'} ) {
        #If the profession exisists in the specialist data and has a building name, set the NPC business
        if (defined $specialist_data->{'option'}->{$specialty}->{'building'}){
            $npc->{'business'} = $specialist_data->{'option'}->{$specialty}->{'building'};
        }else{
            $npc->{'business'}=$npc->{'profession'};
        }

        #FIXME if the business has a  comma, split on commas and select one of them.
        #This is bad and you should feel bad.
        if ( $npc->{'business'} =~ /,/x ) {
            my @businesses = shuffle( split( /,/x, $npc->{'business'} ) );
            $npc->{'business'} = pop @businesses;
        }
    }

    

    return $npc;
}

###############################################################################

=head2 set_attitudes( npc )

Take a provided npc structure and set the primary, secondary and ternary attitudes
 that the npc displays.

=cut

###############################################################################

sub set_attitudes {
    my ($npc) = @_;

    # Select a primary attitude;
    my $primary_attitude = rand_from_array( [ keys %{$npc_data->{'attitude'}->{'option'} } ]);
    $npc->{'primary_attitude'} = $primary_attitude  if ( !defined $npc->{'primary_attitude'} );

    if (defined $npc_data->{'attitude'}->{'option'}->{ $npc->{'primary_attitude'}  } ){
        my $primary=$npc_data->{'attitude'}->{'option'}->{ $npc->{'primary_attitude'}  };
        my $secondary_attitude = rand_from_array( [ keys %{$primary->{'option'} } ] );
        $npc->{'secondary_attitude'} = $secondary_attitude if ( !defined $npc->{'secondary_attitude'} );

        if (defined $primary->{'option'}->{ $npc->{'secondary_attitude'}  } ){
            my $secondary=$primary->{'option'}->{ $npc->{'secondary_attitude'}  };
            my $ternary_attitude = rand_from_array( [ keys %{$secondary->{'option'} } ] );
            $npc->{'ternary_attitude'} = $ternary_attitude if ( !defined $npc->{'ternary_attitude'} );
    
        }else{
            $npc->{'ternary_attitude'}= $npc->{'secondary_attitude'} if (!defined $npc->{'ternary_attitude'}) ;
        }
    }else{
        $npc->{'secondary_attitude'}= $npc->{'primary_attitude'} if (!defined  $npc->{'secondary_attitude'});
        $npc->{'ternary_attitude'}= $npc->{'primary_attitude'} if (!defined $npc->{'ternary_attitude'}) ;
    }



    return $npc;
}


###############################################################################

=head2 get_races( )

Return a list of supported races.

=cut

###############################################################################

sub get_races {
    return [ sort keys %{ $names_data->{'race'} } ];
}


###############################################################################

=head2 generate_npc_name( race )

generate an npc name if they're available for that race.

=cut

###############################################################################

sub generate_npc_name {
    my ( $race, $npc ) = @_;
    $race = lc $race;
    if ( !defined $names_data->{'race'}->{$race}){
        $race="any";
    }

    # Check to see if this is a mutt race like any
    if ( defined $names_data->{'race'}->{$race}->{'allow'} ) {
        $race = rand_from_array( $names_data->{'race'}->{$race}->{'allow'} )->{'content'};
    }

    my $racenameparts = $names_data->{'race'}->{$race};

    # NPCs will always have a firstname.        
    $npc->{'firstname'} = parse_object( $racenameparts->{'firstname'} )->{'content'};
    $npc->{'name'} = $npc->{'firstname'};
    if ($npc->{'firstname'} =~/[sxz]$/){
        $npc->{'firstnames'} =$npc->{'firstname'}."'";
    }else{
        $npc->{'firstnames'} =$npc->{'firstname'}."'s";
    }

    
    if ( defined $racenameparts->{'lastname'} ) {
        $npc->{'lastname'} = parse_object( $racenameparts->{'lastname'} )->{'content'};
        $npc->{'name'} = "$npc->{'firstname'} $npc->{'lastname'}";
    }
    return $npc->{'name'};
}

###############################################################################

=head2 generate_npc_names( race, count )

Return a list of count names from the given race.

=cut

###############################################################################

sub generate_npc_names {
    my ( $race, $count ) = @_;

    if ( !grep { /^$race$/x } @{ get_races() } ) {
        $race = 'any';
    }

    if ( defined $count and $count =~ /(\d+)/x ) {
        $count = $1;
    } else {
        $count = 10;
    }

    my @names;
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        GenericGenerator::set_seed( GenericGenerator::get_seed() + $i );
        push @names, generate_npc_name($race);

    }
    return \@names;
}


###############################################################################

=head2 set_motivation

set the motivation for the NPC.

=cut

###############################################################################

sub set_motivation {

    # FIXME This is fucking ugly code.
    my ($npc) = @_;

    # Find the initial motivation if you don't have one.
    $npc->{'motivation'} = rand_from_array( [ keys %{ $npc_data->{'motivation'}->{'motive'} } ] )
        if ( !defined $npc->{'motivation'} );

    # If it's a "known" motivation
    if ( defined $npc_data->{'motivation'}->{'motive'}->{ $npc->{'motivation'} } ) {

        # select a motivation_detail if you don't already have one
        $npc->{'motivation_detail'}
            = rand_from_array( $npc_data->{'motivation'}->{'motive'}->{ $npc->{'motivation'} }->{'option'} )
            ->{'content'}
            if ( !defined $npc->{'motivation_detail'} );
    } else {

        # since it's an unknown motivation- i.e. a jibberish one not in the XML,
        # we don't have any details we can use unless they were already passed in, so use an empty string.
        $npc->{'motivation_detail'} = "" if ( !defined $npc->{'motivation_detail'} );
    }

    # Using a specific variable for the detail to control whether or not there's a space
    my $detail = "";
    if ( $npc->{'motivation_detail'} ne "" ) {

        # Add a space if motivation_detail is not empty
        $detail = " $npc->{'motivation_detail'}";
    }

    # Append detail to motivation to create the description
    $npc->{'motivation_description'} = $npc->{'motivation'} . $detail if ( !defined $npc->{'motivation_description'} );


    return $npc;
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
