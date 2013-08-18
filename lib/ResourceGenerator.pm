#!/usr/bin/perl -wT
use strict;
use Data::Dumper;
use XML::Simple;
use lib "lib/";
use List::Util 'shuffle', 'min', 'max' ;
use POSIX;
use GenericGenerator;
use GenericGenerator qw( rand_from_array roll_from_array d parse_object seed);
use NPCGenerator;
local $ENV{XML_SIMPLE_PREFERRED_PARSER} = 'XML::Parser';

my $xml = XML::Simple->new();
my $xml_data = $xml->XMLin( "xml/resources.xml", ForceContent => 1, ForceArray => ['option'] );

#print Dumper $xml_data;
#(11:59:46 AM) Jesse Morgan: $city->{'resources'}=[]
#(12:00:07 PM) Jesse Morgan: push @{$city->{'resources'} } , ResourceGenerator::create_resource();
# my $resources->{'resources'}=[]
# $resources->{'resources'}=[]

###############################################################################

=head2 create_resource()

This method is used to create a resource

=over

=item * a seed

=item * a name

=back

=cut

###############################################################################
sub create_resource(){
my $loop = 0;
my $max = d(3);
my $output = '';
my $roll;
    while ($loop < $max) {
       
        $roll = d(3);
        
        if($roll == 1){ # Wildlife
            $output = create_wildlife();   
        }
    
        if($roll == 2){ # Natural
            $output = create_natural();       
        }
    
        if($roll == 3){ # Structure
            $output = create_structure();   
        }
        
        if(d(1) == 1){ 
            $output .= add_visitors();
        }else{
            $output .= '. ';
        }
        
        if(d(6) < 5){ 
            $output .= add_precious();    
        }
        
        print Dumper $output;
        
        $loop++;
    }
}

create_resource();

###############################################################################

=head2 create_structure()

add precious stuff to the narrative

=cut

###############################################################################
sub create_structure {
    my ($content) = @_;
    
    $content = ucfirst(rand_from_array( $xml_data->{'structures'}->{'age'}->{'option'} )->{'content'}) .' ';
    $content .= rand_from_array( $xml_data->{'structures'}->{'option'} )->{'content'} .' ';
    $content .= 'inhabited by ';
    $content .= rand_from_array( $xml_data->{'wildlife'}->{'type'} )->{'content'} .' '. rand_from_array(    $xml_data->{'wildlife'}->{'animal'} )->{'content'} .'s';
    
    return $content;
}

###############################################################################

=head2 create_natural()

add precious stuff to the narrative

=cut

###############################################################################
sub create_natural {
    my ($content) = @_;
    my $natural;
    
    $natural = rand_from_array( $xml_data->{'natural'}->{'type'} );
    $content = '';
    if(d(2) == 1){
        $content .= roll_from_array( d(100), $xml_data->{'scarcity'}->{'option'} )->{'content'} . ' ';
    }
    if(d(2) == 1){
        $content .= rand_from_array( $xml_data->{'natural'}->{'age'}->{'option'} )->{'content'} . ' ';
    }
    $content .= $natural->{'content'} . ' ';
    $content .= rand_from_array( $natural->{'suffix'}->{'option'} )->{'content'};
    
    return ucfirst($content);
}

###############################################################################

=head2 create_wildlife()

add precious stuff to the narrative

=cut

###############################################################################
sub create_wildlife {
    my ($content) = @_;
    my $wildlife;
    
    $content = '';
    if(d(2) == 1){
        $content .= roll_from_array( d(100), $xml_data->{'scarcity'}->{'option'} )->{'content'} . ' ';
    }
    if(d(2) == 1){
        $content .= rand_from_array( $xml_data->{'wildlife'}->{'type'} )->{'content'} . ' ';
    }
    $wildlife = rand_from_array( $xml_data->{'wildlife'}->{'animal'} );
    $content .= $wildlife->{'content'} . ' ' ;
    $content .= $wildlife->{'group'};
    
    return ucfirst($content);
}

###############################################################################

=head2 add_precious()

add precious stuff to the narrative

=cut

###############################################################################
sub add_precious {
    my ($precious) = @_;
    my $who = '';

    if(d(2) == 1){
        $who = NPCGenerator::create_npc()->{'name'} . ' said ';    
    }
    $precious = ' ' . ucfirst($who . rand_from_array( $xml_data->{'precious'}->{'find'} )->{'content'}) . ' ' .
    rand_from_array( $xml_data->{'precious'}->{'type'} )->{'content'} . ' ' .
    rand_from_array( $xml_data->{'precious'}->{'option'} )->{'content'} . ' ' . 
    rand_from_array( $xml_data->{'precious'}->{'post'} )->{'content'} . '.';

#    if (defined $rumor->{'heardit'}){
#       $rumor->{'template'}=$rumor->{'heardit'}." ".$rumor->{'template'};
#    }
#
#    $rumor->{'template'}=ucfirst $rumor->{'template'};
#    
#    if (defined $rumor->{'belief'}){
#       $rumor->{'template'}=$rumor->{'template'}." ".$rumor->{'belief'};
#    }
    
    return $precious;
}

###############################################################################

=head2 add_visitors()

add precious stuff to the narrative

=cut

###############################################################################
sub add_visitors {
    my ($visitors) = @_;

    $visitors = ' that are ';
    $visitors .= rand_from_array( $xml_data->{'feelings'}->{'option'} )->{'content'};
    $visitors .= ' by ';
    $visitors .= rand_from_array( $xml_data->{'groups'}->{'option'} )->{'content'} . '.';
   
    return $visitors;
}


1;
__END__
