/* ========================================================================= */
/*  Lets generate a worldmap!
/*  The first function, create_map is called by citygenerator to
/* configure all of the maps and add the legend.
/* ========================================================================= */


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
            worldmap.xoffset=0
            worldmap.yoffset=0
            worldmap.redrawMap(bigcanvas)
            worldmap.drawbox( worldmap.cities[worldmap.currentCityId].bbox ,  bigcanvas,'rgba(255,0,255,1)'  )
            console.log('continent small, make big!')

    }else if (canvas.id == 'region' && worldmap.embiggen !='region'){
            var citybox=worldmap.cities[worldmap.currentCityId].bbox
            worldmap.embiggen='region'  
            bigcanvas.style.display  ='block'
            worldmap.redrawRegion(bigcanvas)
            worldmap.setMultiplier(1)

    }else if (canvas.id == 'city' && worldmap.embiggen != 'city'){
            worldmap.embiggen='city'
            bigcanvas.style.display  ='block'
            citymap.setMultiplier(1)
            citymap.redraw(bigcanvas)
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

function print_text( map ){
    print_legend(map)
    print_neighbors(map);
    print_diplomatic_ties(map);
    console.log(map)
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


