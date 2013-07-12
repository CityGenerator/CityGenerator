#!/usr/bin/perl -wT
###############################################################################

package TavernGenerator;

#TODO make generate_name method for use with namegenerator
###############################################################################

=head1 NAME

    TavernGenerator - used to generate Taverns

=head1 DESCRIPTION

 This can be used to create a Tavern

=cut

###############################################################################

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
require Exporter;

@ISA       = qw(Exporter);
@EXPORT_OK = qw( create_tavern);

use CGI;
use Data::Dumper;
use GenericGenerator qw(set_seed rand_from_array roll_from_array d parse_object seed);
use NPCGenerator ;
use List::Util 'shuffle', 'min', 'max';
use POSIX;
use XML::Simple;

my $xml = XML::Simple->new();

###############################################################################

=head1 Data files

The following datafiles are used by CityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/npcnames.xml>

=item F<xml/taverns.xml>

=back

=cut

###############################################################################
# FIXME This needs to stop using our
our $xml_data    = $xml->XMLin( "xml/data.xml",     ForceContent => 1, ForceArray => ['option'] );
our $names_data  = $xml->XMLin( "xml/npcnames.xml", ForceContent => 1, ForceArray => ['option'] );
our $tavern_data = $xml->XMLin( "xml/taverns.xml",  ForceContent => 1, ForceArray => ['option'] );

###############################################################################


=head2 create_tavern()

This method is used to create a simple tavern with nothing more than:

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_tavern {
    my ($params) = @_;
    my $tavern={};
    if (ref $params eq 'HASH'){
        foreach my $key (sort keys %$params){
            $tavern->{$key}=$params->{$key};
        }
    }

    $tavern->{'seed'}=set_seed() if(!defined $tavern->{'seed'});
    $tavern->{'cost_mod'}={}  if(!defined $tavern->{'cost_mod'});
    $tavern->{'pop_mod'}={}  if(!defined $tavern->{'pop_mod'});
    generate_tavern_name($tavern);
    return $tavern;
}


###############################################################################

=head2 generate_tavern_name()

    generate a name for the tavern.

=cut

###############################################################################
sub generate_tavern_name {
    my ($tavern) = @_;
    set_seed($tavern->{'seed'});
    my $nameobj= parse_object( $tavern_data->{'name'} );
    $tavern->{'name'}=$nameobj->{'content'}   if (!defined $tavern->{'name'} );
    return $tavern;
}

###############################################################################
 
=head2 generate_size()
 
generate the size category of the tavern
 
=cut
 
###############################################################################
 
sub generate_size {
    my ($tavern)=@_;

    $tavern->{'size'} = rand_from_array( [keys %{  $tavern_data->{'size'}->{'option'} }] ) if (!defined $tavern->{'size'});
    my $size= $tavern_data->{'size'}->{'option'} ->{ $tavern->{'size'}  };

    $tavern->{'size_cost_mod'}      = $size->{'cost_mod'}   if  (!defined $tavern->{'size_cost_mod'} );
    $tavern->{'cost_mod'}->{'size'} = $size->{'cost_mod'}   if  (!defined $tavern->{'cost_mod'}->{'size'} );

    $tavern->{'size_pop_mod'}      = $size->{'pop_mod'}   if  (!defined $tavern->{'size_pop_mod'} );
    $tavern->{'pop_mod'}->{'size'} = $size->{'pop_mod'}   if  (!defined $tavern->{'pop_mod'}->{'size'} );
    
    return $tavern;
}

###############################################################################
 
=head2 generate_condition()
 
generate the condition category of the tavern
 
=cut
 
###############################################################################
 
sub generate_condition {
    my ($tavern)=@_;

    $tavern->{'condition'} = rand_from_array( [keys %{  $tavern_data->{'condition'}->{'option'} }] ) if (!defined $tavern->{'condition'});

    my $condition= $tavern_data->{'condition'}->{'option'} ->{ $tavern->{'condition'}  };
    $tavern->{'condition_cost_mod'}      = $condition->{'cost_mod'}   if  (!defined $tavern->{'condition_cost_mod'} );
    $tavern->{'cost_mod'}->{'condition'} = $condition->{'cost_mod'}   if  (!defined $tavern->{'cost_mod'}->{'condition'} );

    return $tavern;

}

###############################################################################
 
=head2 generate_violence()
 
generate the violence category of the tavern
 
=cut
 
###############################################################################
 
sub generate_violence {
    my ($tavern)=@_;

    $tavern->{'violence'} = rand_from_array( $tavern_data->{'violence'}->{'option'}  )->{'type'} if (!defined $tavern->{'violence'});
    return $tavern;

}


###############################################################################
 
=head2 generate_law()
 
generate the law category of the tavern
 
=cut
 
###############################################################################
 
sub generate_law {
    my ($tavern)=@_;

    $tavern->{'law'} = rand_from_array( $tavern_data->{'law'}->{'option'}  )->{'type'} if (!defined $tavern->{'law'});
    return $tavern;

}

###############################################################################
 
=head2 generate_entertainment()
 
generate the entertainment category of the tavern
 
=cut
 
###############################################################################
 
sub generate_entertainment {
    my ($tavern)=@_;

    $tavern->{'entertainment'} = rand_from_array( $tavern_data->{'entertainment'}->{'option'}  )->{'type'} if (!defined $tavern->{'entertainment'});
    return $tavern;

}

###############################################################################
 
=head2 generate_bartender()
 
generate the bartender for the tavern
 
=cut
 
###############################################################################
 
sub generate_bartender {
    my ($tavern)=@_;

    if (!defined $tavern->{'bartender'}){

        $tavern->{'bartender'}=NPCGenerator::create_npc();
        #TODO flesh out npc here, need to add to NPCGenerator.
    }

    return $tavern;

}


1;
