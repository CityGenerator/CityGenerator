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

#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
#########################################################################
if (defined $q->param('debug')) {
    print "seed: $city->{'seed'}\n";
}

# Lets set our primary width and height. 
my $height=300;
my $width=300;

our $img     = GD::Image->new($width,$height);
our $palette = create_palette($img);


my $land= &select_land_pattern($width,$height);



&city_size($width,$height);
&city_shape($city->{'citydiameter'},$land,$width,$height);


$land         = &set_direction($land,$width,$height);
$city->{'map'}= &set_direction($city->{'map'},$width,$height);


$img->filledRectangle( 0, 0, $width, $height, $palette->{'ocean'} );
$img->filledPolygon($land,                    $palette->{'grass'});
$img->filledPolygon($city->{'map'},           $palette->{'wall'});


if (defined $q->param('debug')) {
    exit;
}
if (defined $q->param('test')) {
    $img->string(GD::gdLargeFont,2,10,"Name:$city->{'name'} ($city->{'seed'}) ",$palette->{'text'});
    $img->string(GD::gdLargeFont,2,25,"Pop:$city->{'population'}->{'size'} diameter: $city->{'citydiameter'}",$palette->{'text'});
    $img->string(GD::gdLargeFont,2,40,"Roads:$city->{'streets'}->{'roads'} ($city->{'streets'}->{'mainroads'} main)",$palette->{'text'});
    $img->string(GD::gdLargeFont,2,55,"houses:$city->{'housing'}->{'total'}, business: $city->{'businesstotal'}",$palette->{'text'});
    $img->string(GD::gdLargeFont,2,70,"side:$city->{'location'}->{'coastdirection'}, shape: $city->{'shape'}",$palette->{'text'});
}
&finish();
exit;

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
#######################################################################################################################
sub city_size {
    my ($width,$height)=@_;
    #range from 50px to 220;
    my $basediameter=$width/4+$city->{'size_modifier'}*$width/60;
    $city->{'citydiameter'} = $basediameter;
}

sub plot_rectangle{
    my ($pointtotal,$width,$height, $center,$cityarea,$isrect) =@_ ;
    my $pointcount=0;
    my $origin=$center;
    while($pointcount++ < $pointtotal){
        my $majorjitter=int (d($width/100)-2+$width/100);
        my $minorjitter=int (d($width/100)-2);
        if ($pointcount < $pointtotal*1/4){
            $center->[0]+=   $majorjitter;
            $center->[1]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*2/4){
            $center->[1]+=   $majorjitter*$isrect;
            $center->[0]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*3/4){
            $center->[0]+= - $majorjitter;
            $center->[1]+= - $minorjitter;
        }elsif($pointcount < $pointtotal){
            $center->[1]+= - $majorjitter*$isrect;
            $center->[0]+= - $minorjitter;
        }else{
            $center= $origin ;
        }
        $cityarea->addPt(@$center);
    }
    return $cityarea;
}
sub plot_hexagon{
    my ($pointtotal,$width,$height, $center,$cityarea) =@_ ;
    my $pointcount=0;
    my $origin=$center;
    while($pointcount++ < $pointtotal){
        my $majorXjitter=int $width/100  +  d($width/100)-2;
        my $majorYjitter=int $width/100  +  d($width/100)-2;
        my $minorjitter=int (d($width/100)-2);
        if ($pointcount < $pointtotal*1/6){
            $center->[0]+=   $majorXjitter;
            $center->[1]+=   $majorYjitter;
        }elsif($pointcount < $pointtotal*2/6){
            $center->[1]+=   $majorYjitter;
            $center->[0]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*3/6){
            $center->[0]+= - $majorXjitter;
            $center->[1]+=   $majorYjitter;
        }elsif($pointcount < $pointtotal*4/6){
            $center->[0]+= - $majorXjitter;
            $center->[1]+= - $majorYjitter;
        }elsif($pointcount < $pointtotal*5/6){
            $center->[1]+= - $majorXjitter;
            $center->[0]+=   $minorjitter;
        }elsif($pointcount < $pointtotal*6/6){
            $center->[1]+= - $majorYjitter;
            $center->[0]+=   $majorXjitter;
        }else{
            $center= $origin ;
        }
        $cityarea->addPt(@$center);
    }
    return $cityarea;
}

sub plot_circular{
    my ($pointtotal,$width,$height, $center,$size,$cityarea)=@_ ;
    my $pointcount=0;
    $center->[0]=int $center->[0];
    $center->[1]=int $center->[1]+$size/2 -($width/50); + d($width/50)*10 ;
    while($pointcount < $pointtotal){
        $cityarea->addPt( $center->[0] + d(10)-5  ,      $center->[1] -$size/2 +d(10)-5   )     ;
        $cityarea->rotate( 3.14159*2/$pointtotal , @$center);
        $pointcount++;
    }
    return $cityarea;
}
sub plot_oval{
    my ($pointtotal,$width,$height, $center,$size,$cityarea)=@_ ;
    my $pointcount=0;
    $center->[0]=int $center->[0];
    $center->[1]=int $center->[1]+$size/2 -($width/50); + d($width/50)*10 ;
    while($pointcount < $pointtotal){
        $cityarea->addPt( $center->[0] + d(10)-5  ,      $center->[1] -$size/2 +d(10)-5   )     ;
        $cityarea->rotate( 3.14159*2/$pointtotal , @$center);
        $pointcount++;
    }
    return $cityarea;
}
sub city_shape{
    my ($size,$land,$width,$height)=@_;
    my $cityarea = new GD::Polyline;

    my $pointtotal=int($size/2);

    # if polysize > 4, there is a body of water.
    print "size: $size\n" if (defined $q->param('debug')  );

    my $center=[$width/2,$height/2];
    if ($land->length>4){
        $center=[$land->getPt($land->length/2-2) ]  ;
    }
    if ( $city->{'shape'} eq "a square" ){
        $cityarea=plot_rectangle($pointtotal,$width,$height, $center,$cityarea,1 ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 
    }elsif ( $city->{'shape'} eq "a rectangular" ){
        $cityarea=plot_rectangle($pointtotal,$width,$height, $center,$cityarea,2 ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 
    }elsif ( $city->{'shape'} eq "a hexagonal" ){
        $cityarea=plot_hexagon($pointtotal,$width,$height, $center,$cityarea ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 

    #circular is currently the default
    }elsif ( $city->{'shape'} eq "an oval" or 1 ){
        $cityarea=plot_oval($pointtotal,$width,$height, $center,$size,$cityarea ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 

    #circular is currently the default
    }elsif ( $city->{'shape'} eq "a circular" or 1 ){
        $cityarea=plot_circular($pointtotal,$width,$height, $center,$size,$cityarea ) ;
        $cityarea->rotate( 3.14159*2/(&d(100)) , $cityarea->centroid()); 

    }
#        print Dumper $cityarea if (defined $q->param('debug')  );

   $cityarea->scale(1.2, 1.2, $cityarea->centroid())  ;

##    <option>an ovalar</option>
##    <option>a pear-shaped</option>
#
$city->{'map'}=$cityarea;

}


sub roughen_polygon{

}

sub select_land_pattern{
    my ($width,$height)=@_;
    $width=$width*2;
    $height=$height*2;
    my $poly = new GD::Polyline;

    #FIXME coast is currently the only one supported, hence the "or 1"
    if ($city->{'location'}->{'name'} eq "on the coast"  or d(5) > 2){
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
            $ycur=min( $ybase+($width/5),  max( $ycur+$depthmod, $ybase-($width/10)));

            $poly->addPt($xbase+$xcur,$ybase+$ycur);
        }
        $poly->addPt($width,$height);
        $poly->addPt(0,$height);
        $poly->offset(-$width/4,($width/5));
    }else{
        $poly->addPt(0,0);
        $poly->addPt($width,0);
        $poly->addPt($width,$height);
        $poly->addPt(0,$height);
        $poly->offset(-$width/4,-$height/4,);
    
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

    my $side=$q->param('side')||$city->{'location'}->{'coastdirection'} ;
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


###############################################################################
#
# finish - The final steps needed to print out the image.
#
###############################################################################

sub finish {
    # make sure we are writing to a binary stream
    $img->interlaced( 'true' );
    binmode STDOUT;
    print $q->header( 'image/png' );
    # Convert the image to PNG and print it on standard output
    print $img->png;
}
###############################################################################
#
# create_palette - a list of all the colors we plan on using.
#
###############################################################################

sub create_palette{
    my ($img)=@_;
return {
    # create a new image
    # allocate some colors
    'grass' => $img->colorAllocate(17,83,7),
    'ocean' => $img->colorAllocate(14,43,104),
    'road'  => $img->colorAllocate(66,30,3),
    'wall'  => $img->colorAllocate(97,97,97),
    'text'  => $img->colorAllocate(0,0,0),
    };
}
