#!/usr/bin/perl -w
use strict;
use CGI;
use Data::Dumper;
use GD::Polyline;
use List::Util 'shuffle', 'min', 'max' ;
use POSIX;
use XML::Simple;
###################################################
# Using findbin to locate our new City.pm module
use FindBin qw/$Bin/;
BEGIN {
    # A rather useless regex, but whatever. 
    # Who woulda throught checking for taint stinks? :D
    if ($Bin =~ m!([\w\.\-/]+)!) {
        $Bin = $1;
    } else {
        print STDOUT "Bad directory $Bin\n";
    }
}
use lib "$Bin/";
###################################################
use City 'build_city', 'd','rand_from_array', 'rand_from_array' ;

my $xml = new XML::Simple;

###########################################################
# Yes, this is sloppy. I am aware, but it's also unique.
# Unique, Ubiquitous Singletons.
our $q = CGI->new;
our $xml_data = $xml->XMLin(   "../data.xml", ForceContent => 1, ForceArray  =>[]  );
our $names_data = $xml->XMLin(   "../names.xml", ForceContent => 1, ForceArray  =>[]  );

#########################################################################
# First thing we need to do is establish a city skeleton of information,
# then fill it in as needed by each subsection of the sample text.
#########################################################################
our $city=build_city($q->param('cityid'));



if (defined $q->param('debug')) {
print "seed: $city->{'seed'}\n";
}
my $height=500;
my $width=500;

our $img = GD::Image->new($width,$height);
our $palette = {
    # create a new image
    # allocate some colors
    'grass' => $img->colorAllocate(17,83,7),
    'ocean' => $img->colorAllocate(14,43,104),
    'road'  => $img->colorAllocate(66,30,3),
    'wall'  => $img->colorAllocate(97,97,97),
};

&draw_ocean($width,$height);
my $land= &select_land_pattern($width,$height);

my $size=&city_size($width,$height);
$city->{'map'}= &city_shape($size,$land,$width,$height);


$land         = &set_direction($land,$width,$height);
$city->{'map'}= &set_direction($city->{'map'},$width,$height);


$img->filledPolygon($land,$palette->{'grass'});
$img->filledPolygon($city->{'map'},$palette->{'wall'});


if (defined $q->param('debug')) {
    exit;
}
$img->string(GD::gdLargeFont,2,10,"$city->{'seed'}",$palette->{'wall'});
&finish();
exit;

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
sub city_size {
    my ($width,$height)=@_;
    #range from 50px to 220;
    my $basediameter=100+$city->{'size_modifier'}*10;
    $img->string(GD::gdLargeFont,2,40,$basediameter,$palette->{'wall'});
    return $basediameter;
}

sub city_shape{
    my ($size,$land,$width,$height)=@_;
    my $cityarea = new GD::Polyline;

    my $pointtotal=$size/2;
    my $pointcount=0;

    # if polysize > 4, there is a body of water.
    print "size: $size\n" if (defined $q->param('debug')  );

    my $center=[$width/2,$height/2];
    if ($land->length>4){
        $center=[$land->getPt($land->length/2-2) ]  ;
    }
#    $center->[0]=int $center->[0];
#    $center->[1]=int $center->[1]+$size/2 -10 + d(10)*5 ;
    my $origin=$center;
    if ( $city->{'shape'} eq "a square" or 1 ){
        while($pointcount++ < $pointtotal){
            my $majorjitter=d(5)-2+5;
            my $minorjitter=d(5)-2;
            if ($pointcount < $pointtotal*1/4){
                $center->[0]+=   $majorjitter;
                $center->[1]+=   $minorjitter;
            }elsif($pointcount < $pointtotal*2/4){
                $center->[1]+=   $majorjitter;
                $center->[0]+=   $minorjitter;
            }elsif($pointcount < $pointtotal*3/4){
                $center->[0]+= - $majorjitter;
                $center->[1]+= - $minorjitter;
            }elsif($pointcount < $pointtotal){
                $center->[1]+= - $majorjitter;
                $center->[0]+= - $minorjitter;
            }else{
                $center= $origin ;
            }
                $cityarea->addPt(@$center);
        }

    }elsif ( $city->{'shape'} eq "a circular" or 1 ){
        print Dumper $center if (defined $q->param('debug')  );
        print " $center->[0]      ". int ($center->[1] -$size/2) ."\n" if (defined $q->param('debug')  );
        while($pointcount++ < $pointtotal){
            $cityarea->addPt( $center->[0] +d(10)-5  , int ($center->[1] -$size/2)+d(10)-5 );
            #$cityarea->addPt( $center->[0]   , int ($center->[1] -$size/2) );
            $cityarea->rotate( 3.14159*2/$pointtotal , @$center); 
        }
    }
#        print Dumper $cityarea if (defined $q->param('debug')  );

    

##    <option>a circular</option>
##    <option>an ovalar</option>
##    <option>a square</option>
##    <option>a pear-shaped</option>
##    <option>a rectangular</option>
##    <option>a hexagonal</option>
#
    return $cityarea;

}


sub roughen_polygon{

}

sub select_land_pattern{
    my ($width,$height)=@_;
    $width=$width*2;
    $height=$height*2;
    my $poly = new GD::Polyline;

    #FIXME coast is currently the only one supported, hence the "or 1"
    if ($city->{'location'}->{'name'} eq "on the coast"  or 1){
        # Set base distances
        my ($xbase, $ybase, $xcur, $ycur, $length)= (0,0,0,0,0);
        my $totaldistance=$width;

        #Determine the total distance that needs to be traveled.
        $totaldistance=$width;
        $poly->addPt(0,0);
        while ($length < $totaldistance){
            my $lengthmod=  &d(20)-5;
            my $depthmod=   &d(24)-12;
            $xcur+=$lengthmod;
            $length=$xcur;
            $ycur=min( $ybase+100,  max( $ycur+$depthmod, $ybase-50));

            $poly->addPt($xbase+$xcur,$ybase+$ycur);
        }
        $poly->addPt($width,$height);
        $poly->addPt(0,$height);
        $poly->offset(-$width/4,100);
    
    }
#$poly->transform($sx,$rx,$sy,$ry,$tx,$ty);
#Run each vertex of the polygon through a transformation matrix, where 
#sx and sy are the X and Y scaling factors, 
#rx and ry are the X and Y rotation factors, and 
#tx and ty are X and Y offsets. 
#See the Adobe PostScript Reference, page 154 for a full explanation, or experiment.

#  print Dumper $poly if (defined $q->param('debug')  );

 return $poly;
}
sub set_direction{
    my ($poly,$width,$height)=@_;
    $width=$width/2;
    $height=$height/2;

    my $side=$q->param('side')||"north" ;
    if ($side eq 'north'){

    }elsif($side eq 'northeast'){
        $poly->rotate(3.14159/4,$width,$height) ;

    }elsif($side eq 'east'){
        $poly->rotate(3.14159/2,$width,$height) ;

    }elsif($side eq 'southeast'){
        $poly->rotate(3.14159*3/4,$width,$height) ;

    }elsif($side eq 'south'){
        $poly->rotate(3.14159,$width,$height) ;

    }elsif($side eq 'southwest'){
        $poly->rotate(3.14159*5/4,$width,$height) ;

    }elsif($side eq 'west'){
        $poly->rotate(3.14159*3/2,$width,$height) ;

    }elsif($side eq 'northwest'){
        $poly->rotate(3.14159*7/4,$width,$height) ;
    }
    return $poly;
}
sub draw_ocean(){
    my ($width,$height)=@_;
    $img->filledRectangle( 0, 0, $width, $height, $palette->{'ocean'} );
}

sub finish {
    # make sure we are writing to a binary stream
    $img->interlaced( 'true' );
    binmode STDOUT;
    print $q->header( 'image/png' );
    # Convert the image to PNG and print it on standard output
    print $img->png;
}

