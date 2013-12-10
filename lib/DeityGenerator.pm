#!/usr/bin/perl -wT
package DeityGenerator;

use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION $XS_VERSION $TESTING_PERL_ONLY);
use base qw(Exporter);

###############################################################################

=head1 NAME

    DeityGenerator - used to generate Deities

=head1 SYNOPSIS

    use DeityGenerator;
    my $deity1=DeityGenerator::create();
    my $deity2=DeityGenerator::create($parameters);

=cut

###############################################################################


use Carp;
use CGI;
use Data::Dumper;
use Exporter;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object );
use List::Util 'shuffle';
use CityGenerator;
use Clone qw(clone);
use NPCGenerator;
use POSIX;
use Template;
use version;
use XML::Simple;

my $xml = XML::Simple->new();
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

###############################################################################

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Data files

The following datafiles are used by DeityGenerator.pm:

=over

=item F<xml/data.xml>

=item F<xml/deities.xml>

=back

=head1 INTERFACE 


=cut

###############################################################################

my $xml_data      = $xml->XMLin( "xml/data.xml",    ForceContent => 1, ForceArray => ['option'] );
my $deity_data    = $xml->XMLin( "xml/deities.xml",  ForceContent => 1, ForceArray => ['option'] );

###############################################################################

=head2 Core Methods

The following methods are used to create the core of the deity structure.

=head3 create()

This method is used to create a simple deity with nothing more than:

=over

=item * a seed

=back

=cut

###############################################################################
sub create {
    my ($params) = @_;
    my $deity = {};

    if ( ref $params eq 'HASH' ) {
        foreach my $key ( sort keys %$params ) {
            $deity->{$key} = $params->{$key};
        }
    }

    if ( !defined $deity->{'seed'} ) {
        $deity->{'seed'} = GenericGenerator::set_seed();
    }
    GenericGenerator::set_seed( $deity->{'seed'} );
    $deity=NPCGenerator::create($deity);
    GenericGenerator::generate_stats($deity,$deity_data);
    GenericGenerator::select_features($deity,$deity_data);

    $deity->{'holy symbol'} = parse_object($deity_data->{'holysymbol'})->{'content'} if (!defined $deity->{'holy symbol'} );

    set_max_stats($deity);
    set_portfolios($deity);
    set_subsects($deity);
    return $deity;
}

###############################################################################

=head3 set_subsects()

select features that have subsects.

=cut

###############################################################################
sub set_subsects {
    my ($deity)=@_;
    $deity->{'sect'} = [] if (!defined $deity->{'sect'} );
    if(scalar(@{$deity->{'portfolio'}}) > 2 ){
        $deity->{'sect_count'}=d(scalar @{$deity->{'portfolio'}})-1 if (!defined $deity->{'sect_count'});
        my $count=$deity->{'sect_count'};
        for (my $i=0; $i<$count; $i++){
            if (d(100)< $deity->{'stats'}->{'devotion'}){
               my $type=rand_from_array($deity_data->{'culttype'}->{'option'})->{'content'};
               my $acceptance=roll_from_array(d(100),$deity_data->{'acceptance'}->{'option'})->{'content'};
               push @{ $deity->{'sect'} }, { 
                                            'name'=> $deity->{'portfolio'}->[$i],
                                            'type'=>$type,
                                            'acceptance'=>$acceptance };
            }
        }
    }
    return $deity;
}

###############################################################################

=head3 set_max_stats()

select the best and worst stats

=cut

###############################################################################
sub set_max_stats {
    my ($deity)=@_;
    if (!defined $deity->{'best_stat'}){
        foreach my $stat (keys %{$deity->{'stats'}} ){
            if (!defined  $deity->{'best_stat'}   or    $deity->{'stats'}->{$stat} > $deity->{'stats'}->{$deity->{'best_stat'}} ){
                $deity->{'best_stat'}=$stat;
            }
        }
    }
    if (!defined $deity->{'worst_stat'}){
        foreach my $stat (keys %{$deity->{'stats'}} ){
            if (!defined  $deity->{'worst_stat'}   or    $deity->{'stats'}->{$stat} < $deity->{'stats'}->{$deity->{'worst_stat'}} ){
                $deity->{'worst_stat'}=$stat;
            }
        }
    }
    return $deity;
}


###############################################################################

=head3 set_portfolios()

select portfolios from the allowed portfolios

=cut

###############################################################################
sub set_portfolios {
    my ($deity)=@_;
    $deity->{'allowed_portfolio'}=clone($deity_data->{'portfolio'}->{'option'}) if (!defined $deity->{'allowed_portfolio'} );
    $deity->{'allowed_portfolio'} = [shuffle( @{$deity->{'allowed_portfolio'}} )];

    $deity->{'portfoliovalue'}= $deity_data->{'portfoliovalue'}->{'option'}->{$deity->{'importance_description'}}->{'content'} if (!defined   $deity->{'portfoliovalue'});
    $deity->{'portfolio'} = [] if (!defined $deity->{'portfolio'});
    while ($deity->{'portfoliovalue'} >=0 and scalar(@{$deity->{'portfolio'}}) < 6 and @{$deity->{'allowed_portfolio'}} >0 ){
        my $portfolio=pop @{$deity->{'allowed_portfolio'}};

        if ($portfolio->{'value'} <= $deity->{'portfoliovalue'}  ){
            $deity->{'portfoliovalue'}-= $portfolio->{'value'};
            push @{$deity->{'portfolio'}}, $portfolio->{'content'};
        }
    }
    $deity->{'allowed_portfolio'}=undef;

    return $deity;
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
