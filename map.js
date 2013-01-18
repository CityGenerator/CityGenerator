

/* ========================================================================= */
/*  Lets generate a worldmap!
/*  The first function, create_map is called by citygenerator to
/* configure all of the maps and add the legend.
/* ========================================================================= */

function create_map( params ){
    // regionmod determines which of the 10 regions on this continent to use.
    // With a cityid of 744158, the 5 indications which region to focus on
    var regionmod=Math.floor(   (params.seed%100)/10  );

    // citymod determines which of the 10 cities in this region to use.
    // uses the last  digit of the cityid: 744158 -> 8
    var citymod=Math.floor((params.seed%10));

    // continent seed refers to which continent we're on- it essentially
    // ignores the last two digits of the cityid: 744158 -> 744100 
    var continentseed=params.seed -  params.seed%100;

    // Begin seeding with the continent seed!
    Math.seedrandom(continentseed);

    var canvas=params.canvas

    // The number of cells in a given continent.
    var sites=2000;

    // The width and height are hard-coded here
    console.log(canvas)
    // This is the crux of our entire map.
    var map=new WorldMap(canvas.width,canvas.height,sites);
    map.designateKingdoms(continentseed);    

    map.paintMap(canvas)
    map.drawKingdoms(canvas,true);
    var box=map.kingdoms[regionmod].regionbox;
    map.drawbox(box,canvas,'rgba(255,0,255,1)');
    print_legend(map)

    return map
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

function print_legend(map){
    document.getElementById('continentlegend').innerHTML='Legend:'
    for ( var name in map.terrain){
    document.getElementById('continentlegend').innerHTML+='<span style="font-size:10px;background-color:'+map.terrain[name].color+'">'+name +'</span> '
    }
}


/* ========================================================================= */
/* build_city is called by CityGenerator to build the city map. We pass in
/* everything via the params object to make things easier.
/* ========================================================================= */

function build_city(  params  ){

    // Step 1) we need to set our seed to ensure consistency
    Math.seedrandom(params.seed)

    var citycanvas=params.canvas

    // hardcoded map sizes
    citycanvas.height=150;
    citycanvas.width=180;

    //Set the total number of cells and the city cell count
    var totalcellcount = 200 + params.size*20 // should range between 150 cells and 440
    var citycellcount  = Math.floor(totalcellcount*(20+params.size)/100);

    // Generate our base CityMap
    var city=new CityMap(  citycanvas.width, citycanvas.height, totalcellcount  );
    // Generate the key parts of the city.
    city.designateCity(citycanvas,citycellcount);
    city.generateCityWalls()
    city.generateDistricts(params.districts);


    // From here, draw out all the parts we designated above.
    city.paintBackground(citycanvas,params.continentmap.currentcitycell.color);
    city.drawCoast(citycanvas, params.isport, params.coastdirection)
    city.paintCells(citycanvas,city.citycells,'rgba(255,255,255,1)',false)

    city.drawCityWalls(citycanvas,  Math.ceil(params.wallheight/10)   )

    city.render(citycanvas)
    city.drawRoads(citycanvas, params.roads, params.mainroads)
    return city
}


/* ========================================================================= */
/* build_region is called by CityGenerator to build the region map.
/* We pass in everything via the params object to make things easier.
/* ========================================================================= */

function build_region(  params  ){

    // Step 1) we need to set our seed to ensure consistency
    Math.seedrandom(params.seed)

    // regionmod determines which of the 10 regions on this continent to use.
    // With a cityid of 744158, the 5 indications which region to focus on
    var regionmod=Math.floor(   (params.seed%100)/10  );

    // citymod determines which of the 10 cities in this region to use.
    // uses the last  digit of the cityid: 744158 -> 8
    var citymod=Math.floor((params.seed%10));

    var canvas=params.canvas;

    // use our continent map
    var map=params.continentmap;

    // hardcoded map sizes
    canvas.height=150;
    canvas.width=180;
//    regioncanvas.height=continentcanvas.height;
//    regioncanvas.width=continentcanvas.width;

    map.paintBackground(canvas,'#ffffff');
    map.drawRegion(canvas,regionmod);
    map.drawKingdoms(canvas, false);

    map.drawCities(canvas,regionmod,citymod,params.citynames);

    // Generate our base RegionMap
}

