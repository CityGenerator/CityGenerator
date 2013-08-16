#!/usr/bin/perl -wT
###############################################################################

package EstablishmentGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);
@EXPORT_OK = qw( create_establishment);

#TODO make generate_name method for use with namegenerator
###############################################################################

=head1 NAME

    EstablishmentGenerator - used to generate Establishments

=head1 DESCRIPTION

 This can be used to create a Establishment

=cut

###############################################################################

use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator;
use List::Util 'shuffle', 'min', 'max';
use Lingua::EN::Titlecase;
use POSIX;
use version;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/establishments.xml>

=back

=cut

###############################################################################

my $xml_data            = $xml->XMLin( "xml/data.xml",              ForceContent => 1, ForceArray => ['option'] );
my $establishment_data  = $xml->XMLin( "xml/establishments.xml",    ForceContent => 1, ForceArray => ['option'] );

###############################################################################


=head2 create_establishment()

This method is used to create a simple establishment with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_establishment {
    my ($params) = @_;
    my $establishment = {};
    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $establishment->{$key} = $params->{$key};
        }
    }
    $establishment->{'seed'} = set_seed() if ( !defined $establishment->{'seed'} );

    foreach my $stat (qw( reputation size price popularity)) {
        $establishment->{'stats'}->{$stat} = d(100) if ( !defined $establishment->{'stats'}->{$stat} );
        $establishment->{ $stat . "_description" }
            = roll_from_array( $establishment->{'stats'}->{$stat}, $establishment_data->{$stat}->{'option'} )->{'content'}
            if ( !defined $establishment->{ $stat . "_description" } );
    }

    GenericGenerator::select_features($establishment, $establishment_data);
    select_establishment_type($establishment);
    generate_establishment_name($establishment);


    generate_manager($establishment);

    generate_smell($establishment);
    generate_sight($establishment);
    generate_sound($establishment);
    generate_servicetype($establishment);

    generate_direction($establishment);
    generate_law($establishment);
    generate_graft($establishment);
    generate_condition($establishment);
    generate_district($establishment);
    
    return $establishment;
}

###############################################################################

=head2 select_establishment_type()

    select a type for the establishment.

=cut

###############################################################################
sub select_establishment_type {
    my ($establishment) = @_;
    set_seed( $establishment->{'seed'} );
    $establishment->{'type'}= rand_from_array([keys %{$establishment_data->{'establishment'}->{'option'}}] )   if (!defined $establishment->{'type'});

    my $type=$establishment_data->{'establishment'}->{'option'}->{$establishment->{'type'}};

    $establishment->{'manager_title'}= rand_from_array($type->{'manager'}->{'option'})->{'content'} if (!defined $establishment->{'manager_title'});

    $establishment->{'trailer'}= rand_from_array($type->{'trailer'}->{'option'})->{'content'} if (!defined $establishment->{'trailer'} and defined $type->{'trailer'}->{'option'});

    $establishment->{'manager_class'}= rand_from_array($type->{'npc_class'}->{'option'})->{'content'} if (!defined $establishment->{'manager_class'} and defined $type->{'npc_class'}->{'option'});

    return $establishment;
}


###############################################################################

=head2 generate_establishment_name()

    generate a name for the establishment.

=cut

###############################################################################
sub generate_establishment_name {
    my ($establishment) = @_;
    set_seed( $establishment->{'seed'} );
    my $nameobj = parse_object( $establishment_data->{'name'} );

    my $type = $establishment_data->{'establishment'}->{'option'}->{$establishment->{'type'}};

    $establishment->{'name'}  = "$nameobj->{'content'} $establishment->{'trailer'}" if ( !defined $establishment->{'name'} );
    
    my $tc = Lingua::EN::Titlecase->new( $establishment->{'name'}  );

    $establishment->{'name'} = $tc->title();
    
    return $establishment;
}


###############################################################################

=head2 generate_manager()
 
generate the manager for the establishment
 
=cut

###############################################################################
sub generate_manager {
    my ($establishment) = @_;
    if ( !defined $establishment->{'manager'} ) {

        $establishment->{'manager'} = NPCGenerator::create_npc(
            {   'profession'=>$establishment->{'manager_title'},
                'business'=>$establishment->{'type'},
                'class'=>$establishment->{'manager_class'}
            });

        #TODO flesh out npc here, need to add to NPCGenerator.
    }

    return $establishment;

}


###############################################################################

=head2 generate_smell()
 
generate the smell category of an establishment
 
=cut

###############################################################################
sub generate_smell {
    my ($establishment) = @_;

    my $type = $establishment_data->{'establishment'}->{'option'}->{$establishment->{'type'}};
    $establishment->{'smell'} = rand_from_array($type->{'smell'}->{'option'})->{'content'} if ( defined $type->{'smell'} ); 
    
    return $establishment;

}


###############################################################################

=head2 generate_sight()
 
generate the sight category of an establishment
 
=cut

###############################################################################
sub generate_sight {
    my ($establishment) = @_;

    my $type = $establishment_data->{'establishment'}->{'option'}->{$establishment->{'type'}};
    $establishment->{'sight'} = rand_from_array($type->{'sight'}->{'option'})->{'content'} if ( defined $type->{'sight'} );
    
    return $establishment;

}


###############################################################################

=head2 generate_sound()
 
generate the sound category of an establishment
 
=cut

###############################################################################
sub generate_sound {
    my ($establishment) = @_;

    my $type = $establishment_data->{'establishment'}->{'option'}->{$establishment->{'type'}};
    $establishment->{'sound'} = rand_from_array($type->{'sound'}->{'option'})->{'content'} if ( defined $type->{'sound'} );
    
    return $establishment;

}


###############################################################################

=head2 generate_servicetype()
 
generate the service type of an establishment
 
=cut

###############################################################################
sub generate_servicetype {
    my ($establishment) = @_;

    my $type = $establishment_data->{'establishment'}->{'option'}->{$establishment->{'type'}};
    $establishment->{'service_type'} = rand_from_array($type->{'service'}->{'option'})->{'content'} if ( !defined $establishment->{'service_type'} and defined $type->{'service'} );
    
    return $establishment;

}


###############################################################################

=head2 generate_law()
 
generate the law of an establishment
 
=cut

###############################################################################
sub generate_law {
    my ($establishment) = @_;

    my $data = $xml_data->{'laws'};
    $establishment->{'enforcer'} = rand_from_array($data->{'enforcer'}->{'option'})->{'content'} if (!defined $establishment->{'enforcer'} );
    
    return $establishment;

}


###############################################################################

=head2 generate_graft()
 
generate the graft of an establishment
 
=cut

###############################################################################
sub generate_graft {
    my ($establishment) = @_;

    $establishment->{'graft'} = rand_from_array($xml_data->{'laws'}->{'graft'}->{'option'})->{'content'} if ( !defined $establishment->{'graft'} );
    
    return $establishment;

}


###############################################################################

=head2 generate_condition()
 
generate the condition of an establishment
 
=cut

###############################################################################
sub generate_condition {
    my ($establishment) = @_;

    $establishment->{'condition'} = rand_from_array($xml_data->{'condition'}->{'option'})->{'content'} if (! defined $establishment->{'condition'}  );
    
    return $establishment;

}




###############################################################################

=head2 generate_direction()
 
generate the direction of an establishment
 
=cut

###############################################################################
sub generate_direction {
    my ($establishment) = @_;

    $establishment->{'direction'} = rand_from_array($xml_data->{'direction'}->{'option'})->{'content'} if (!defined $establishment->{'direction'});
    
    return $establishment;

}


###############################################################################

=head2 generate_district()
 
generate the sound category of an establishment 
 
=cut

###############################################################################
sub generate_district {
    my ($establishment) = @_;

    $establishment->{'district'} = $establishment_data->{'establishment'}->{'option'}->{$establishment->{'type'}}->{'district'};
    
    return $establishment;

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
