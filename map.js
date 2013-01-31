/* ========================================================================= */
/*  Lets generate a worldmap!
/*  The first function, create_map is called by citygenerator to
/* configure all of the maps and add the legend.
/* ========================================================================= */

function build_continent( params ){
    console.log('start building continent')
    // regionmod determines which of the 10 regions on this continent to use.
    // With a cityid of 744158, the 5 indications which region to focus on
    var regionmod=Math.floor(   (params.seed%100)/10  );

    // citymod determines which of the 10 cities in this region to use.
    // uses the last  digit of the cityid: 744158 -> 8
    var citymod=Math.floor(params.seed%10);

    // continent seed refers to which continent we're on- it essentially
    // ignores the last two digits of the cityid: 744158 -> 744100 
    var continentseed=params.seed -  params.seed%100;

    // Begin seeding with the continent seed!
    Math.seedrandom(continentseed);
    // This is the crux of our entire map.
    var map=new WorldMap(params.canvas.width,params.canvas.height,params.sites,params.seed,params.neighbors,params.neighborRegions);

    print_legend(map)
    print_neighbors(map);
    print_diplomatic_ties(map);
    console.log(map)
    return map
}


/* ========================================================================= */
/* build_region is called by CityGenerator to build the region map.
/* We pass in everything via the params object to make things easier.
/* ========================================================================= */

function build_region( params ){
    var map=document.continentmap
    map.redrawRegion(document.getElementById('region'))
}


/* ========================================================================= */
/* build_city is called by CityGenerator to build the city map. We pass in
/* everything via the params object to make things easier.
/* ========================================================================= */

function build_city(  params  ){

    // Step 1) we need to set our seed to ensure consistency
    Math.seedrandom(params.seed)

    // Generate our base CityMap
    var map=new CityMap(  params.canvas.width, params.canvas.height, params, document.continentmap.currentcitycell.color  );
    // Generate the key parts of the city.

    map.redraw(document.getElementById('city'),1/3)
    print_Citylegend(map)
    return map
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

function embiggen( canvas ){
    var bigcanvas=document.getElementById('bigmap')
    var worldmap=document.continentmap
    var citymap=document.citymap
    console.log(bigcanvas)
    if (canvas.id == 'continent' && worldmap.embiggen !='continent'){
            worldmap.embiggen='continent'
            bigcanvas.style.display  ='block'
            worldmap.setMultiplier(1)
            worldmap.redraw(bigcanvas)
            console.log('continent small, make big!')


    }else if (canvas.id == 'region' && worldmap.embiggen !='region'){
            var citybox=worldmap.cities[worldmap.currentCityId].box
            var multiplier=2.5*3
            worldmap.xoffset=-citybox.minx*multiplier
            worldmap.yoffset=-citybox.miny*multiplier
            worldmap.embiggen='region'  
            bigcanvas.style.display  ='block'
            worldmap.redraw(bigcanvas,multiplier)
            worldmap.setMultiplier(multiplier)
            worldmap.drawCityName(bigcanvas,worldmap.cities[worldmap.currentCityId])

            worldmap.xoffset=0
            worldmap.yoffset=0

    }else if (canvas.id == 'city' && worldmap.embiggen != 'city'){
            worldmap.embiggen='city'
            bigcanvas.style.display  ='block'
            citymap.redraw(bigcanvas,1)
            console.log('city small, make big!')

    }else{
            document.continentmap.embiggen=""

            bigcanvas.style.display  ='none'



            console.log('hide all the things')

    }


}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

function print_diplomatic_ties(map){
    var diplomaticdiv=document.getElementById('diplomatic_ties_text')
    diplomaticdiv.innerHTML=map.cities[map.currentCityId].name+" has the following diplomatic relations:<ul> \n"
    for ( var i = 0 ; i < map.closeneighbors.length ; i++){
        var neighbor=map.closeneighbors[i];
        diplomaticdiv.innerHTML+="<li> "+neighbor.relation+" <a href='?cityid="+neighbor.seed+"'> "+neighbor.name+"</a></li> \n"
    }
    diplomaticdiv.innerHTML+="</ul> \n"
}




/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

function print_neighbors(map){
    var neighbordiv=document.getElementById('neighboring_cities')
    neighbordiv.innerHTML="Neighboring cities include: \n"
    for ( var i = 0 ; i < map.closeneighbors.length ; i++){
        var neighbor=map.closeneighbors[i];
        neighbordiv.innerHTML+="<a href='?cityid="+neighbor.seed+"'> "+neighbor.name+"</a> \n"
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

function print_legend(map){
    document.getElementById('continentlegend').innerHTML='Legend:'
    for ( var name in map.terrain){
        document.getElementById('continentlegend').innerHTML+='<span style="font-size:10px;color:#000;background-color:'+map.terrain[name].color+'">'+name +'</span> '
    }
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

function print_Citylegend(map){
    document.getElementById('citylegend').innerHTML='Legend:'
    for (var i=0; i < map.districts.length; i++ ){
        var district=map.districts[i];
        document.getElementById('citylegend').innerHTML+='<span style="font-size:10px;color:#000;background-color:'+district.color+'">'+district.name +'</span> '
    }
}

