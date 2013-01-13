/* **************************************************************** */
/*  Lets generate a worldmap!
/*  The first function, create_map is called by citygenerator to
//* configure all of the maps and add the legend.
/* **************************************************************** */

function create_map(seed, continentcanvas,regioncanvas,names){
    // regionmod determines which of the 10 regions on this continent to use.
    // With a cityid of 744158, the 5 indications which region to focus on
    var regionmod=Math.floor(   (seed%100)/10  );

    // citymod determines which of the 10 cities in this region to use.
    // uses the last  digit of the cityid: 744158 -> 8
    var citymod=Math.floor((seed%10));

    // continent seed refers to which continent we're on- it essentially
    // ignores the last two digits of the cityid: 744158 -> 744100 
    var continentseed=seed -  seed%100;

    // Begin seeding with the continent seed!
    Math.seedrandom(continentseed);

    // The number of cells in a given continent.
    var sites=2000;

    // The width and height are hard-coded here
    var width =350;
    var height=300;
    continentcanvas.height=height;
    continentcanvas.width=width

    // This is the crux of our entire map.
    var map=new WorldMap(width,height,sites);
    map.designateKingdoms(continentseed);    

    map.paintMap(continentcanvas)
    map.drawKingdoms(continentcanvas,true);
    var box=map.kingdoms[regionmod].regionbox;
    map.drawbox(box,continentcanvas,'rgba(255,0,255,1)');
    print_legend(map)

    regioncanvas.height=height;regioncanvas.width=width;
    map.paintBackground(regioncanvas,'#ffffff');
    map.drawRegion(regioncanvas,regionmod);
    map.drawKingdoms(regioncanvas, false);


    map.drawCities(regioncanvas,regionmod,citymod,names);
    document.map=map
}









function build_city(  params      ){

    Math.seedrandom(params.seed)
    var citycanvas=params.canvas

    var width =350;
    var height=300;
    citycanvas.height=height;citycanvas.width=width;
    var citysitecount=100+params.size*10 // should range between 50 cells and 220
    var city=new CityMap(width, height,citysitecount);
    city.render(citycanvas)

    //console.log(document.map.currentcitycell)
    var basecolor=document.map.currentcitycell.color
    document.map.paintBackground(citycanvas,basecolor);
    city.citycells=[]
    for (var i = 0; i < 20+params.size*2; i++) {
        city.citycells.push(city.findCenterCell(citycanvas))
    }
    //console.log(city.citycells)
    for (var i = 0; i < city.citycells.length; i++) {
        var cell=city.citycells[i];
        city.colorPolygon(cell,citycanvas,'highlight','#ffffff',false);
    }
    city.getCityPolygon()
    city.drawCityPolygon(citycanvas,  Math.ceil(params.wallheight/10)   )
    city.drawRoads(citycanvas, params.roads, params.mainroads)
    city.render(citycanvas)
}









function print_legend(map){
    document.getElementById('continentlegend').innerHTML='Legend:'
    for ( var name in map.terrain){
    document.getElementById('continentlegend').innerHTML+='<span style="font-size:10px;background-color:'+map.terrain[name].color+'">'+name +'</span> '
    }


}

WorldMap.prototype.triangulatePosition = function(va,vb,vc){
    var t=Math.random()
    var s=Math.random()
    if (t+s > 1){
        s=1-s
        t=1-t
    }
    var a = 1-s-t
    var b = s
    var c = t
    var randx=va.x*a +vb.x*b + vc.x*c
    var randy=va.y*a +vb.y*b + vc.y*c
    return {x:randx,y:randy}
}
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
WorldMap.prototype.drawTexture = function(canvas){
    var c = canvas.getContext('2d');

    var sim = new SimplexNoise() ;
    //We're gonna track our min and max so we can resize later.
    var min=1;
    var max=0;
    var imageData = c.getImageData(0, 0, canvas.width, canvas.height);
///////////////////////////////////////////////////////////////////////////////////////////
    for (y = 0; y < canvas.height; y++) {
        for (x = 0; x < canvas.width; x++) {
            var inpos=(x + y*canvas.width )*4
            r = imageData.data[inpos]   +( (sim.noise2D(x/50,y/50)*255)-128)*.3     ;
            g = imageData.data[inpos+1] +( (sim.noise2D(x/50,y/50)*255)-128)*.3     ;
            b = imageData.data[inpos+2] +( (sim.noise2D(x/50,y/50)*255)-128)*.3     ;
            a = imageData.data[inpos+3] +( (sim.noise2D(x/50,y/50)*255)-128)*.3     ;

            imageData.data[inpos]   = r;
            imageData.data[inpos+1] = g;
            imageData.data[inpos+2] = b;
            imageData.data[inpos+3] = 128;
        }
    }
        c.putImageData(imageData, 0, 0);
}
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
WorldMap.prototype.drawCities = function(canvas,regionmod,citymod,names){
    
    for (var cityid=0 ; cityid<10 ; cityid++){
        //console.log(cityid+" "+citymod)
        // Using the region and cityid, select a cell and get a list of its corners
        var regioncount=this.kingdoms[regionmod].cells.length;
        var cell=this.kingdoms[regionmod].cells[cityid%regioncount]
        var corners=cell.corners
    
        var color="#888888"
        if (citymod== cityid){
            color='#000000'
            this.currentcitycell=cell
        }
        // Select 3 random corners from the list
        var va=corners.splice( Math.floor(Math.random()*corners.length) ,1)[0];
        var vb=corners.splice( Math.floor(Math.random()*corners.length) ,1)[0];
        var vc=corners.splice( Math.floor(Math.random()*corners.length) ,1)[0];
    
        var point=this.triangulatePosition(va,vb,vc);
        this.paintdot(canvas,point.x,point.y,color);
    }

}
WorldMap.prototype.paintdot = function(canvas,x,y,color){
    var polyfill = canvas.getContext('2d');

    polyfill.strokeStyle=color;
    polyfill.fillStyle=color;
    polyfill.beginPath();
    
    polyfill.moveTo(x-2,y-2);
    polyfill.lineTo(x+2,y-2);
    polyfill.lineTo(x+2,y+2);
    polyfill.lineTo(x-2,y+2);

    polyfill.closePath();
    polyfill.fill();
    polyfill.stroke();
}
WorldMap.prototype.paintMap = function(canvas){
    this.paintBackground(canvas,'#ffffff');
    for (var i=0; i < this.diagram.cells.length ; i++ ){
        this.colorPolygon(this.diagram.cells[i],canvas,'biomes');
    }
    this.drawRivers(canvas);
}


WorldMap.prototype.designateKingdoms = function(continentseed){
    var colors = [ '255,105,180', '139,0,0', '255,140,0', '255,255,0', '124,252,0', '127,255,212', '95,158,160', '30,144,255', '238,130,238',  '128,0,128'      ];
    this.kingdoms=[];
    for (var i=0 ; i<10 ; i++){
        var kingdom={}
        kingdom.id=i
        kingdom.seed=continentseed+i
        kingdom.color='rgba('+colors[i]+',.3)';

        Math.seedrandom( kingdom.seed   ) ;
        kingdom.capital=this.randomLand();
        while ( kingdom.capital.kingdom ){ // If this cell is already part of a kingdom, choose another
            //console.log('look a new kingdom('+kingdom.seed+")")
            kingdom.capital=this.randomLand();
        }
        kingdom = this.getKingdom( kingdom);

        this.kingdoms.push(kingdom)
    }
    this.boxKingdoms();
    
}
WorldMap.prototype.drawKingdoms = function(canvas, fill){
    for (var i=0 ; i<10 ; i++){
        this.drawKingdom(this.kingdoms[i],canvas, fill)
    }
}

WorldMap.prototype.drawKingdom = function(kingdom,canvas, fill){
    var polyline = canvas.getContext('2d');
    polyline.beginPath();
    for (var i=0; i<kingdom.outline.length; i++){
        var vertex= kingdom.outline[i];
        polyline.lineTo(vertex.x,vertex.y);
    }
    polyline.lineWidth=2;
    polyline.strokeStyle="rgba(0,0,0,0.7)";
    //polyline.fillStyle="rgba(200,0,0,0.3)";
    polyline.fillStyle=kingdom.color;
    polyline.lineCap = 'butt';
    polyline.stroke();
    if (fill){
        polyline.fill();
    }
    polyline.closePath();

}
WorldMap.prototype.boxKingdoms = function(){
    for (var i=0; i < this.kingdoms.length ; i++ ){
        this.boxKingdom(this.kingdoms[i])
    }
}

WorldMap.prototype.boxKingdom = function(kingdom){
    kingdom.box={ minx:100000, miny:100000, maxx:0, maxy:0}
    var fullcellIDs=[];
    //figure out the box for the kingdom an
    for (var k=0; k < kingdom.cells.length ; k++ ){ 
        var cell=kingdom.cells[k];
        fullcellIDs.push(cell.site.voronoiId);
        //check both centers and edges
        for (var j=0; j < cell.halfedges.length ; j++ ){ 
            var he=cell.halfedges[j].edge;
            if (he.rSite != null && fullcellIDs.indexOf(he.rSite.voronoiId) ==-1){fullcellIDs.push(he.rSite.voronoiId);}
            if (he.lSite != null && fullcellIDs.indexOf(he.lSite.voronoiId) ==-1){fullcellIDs.push(he.lSite.voronoiId);}
            kingdom.box=this.setbox(kingdom.box,he.va,he.vb)
        }
    }
    kingdom.regionbox={ minx:100000, miny:100000, maxx:0, maxy:0}
    kingdom.regions=[];
    //console.log(fullcellIDs)
    for (var k=0; k < fullcellIDs.length ; k++ ){ 
        var cell=this.diagram.cells[fullcellIDs[k]];
        kingdom.regions.push(cell);
        for (var j=0; j < cell.halfedges.length ; j++ ){ 
            var he=cell.halfedges[j];
            kingdom.regionbox=this.setbox(kingdom.regionbox,he.edge.va,he.edge.vb)
        }
    }
}

WorldMap.prototype.setbox = function(box, va, vb){
    box.maxx=Math.ceil(Math.max( box.maxx,va.x,vb.x));
    box.maxy=Math.ceil(Math.max( box.maxy,va.y,vb.y));
    box.minx=Math.floor(Math.min(box.minx,va.x,vb.x));
    box.miny=Math.floor(Math.min(box.miny,va.y,vb.y));
    return box
}
WorldMap.prototype.drawbox = function(box,canvas,color){
    var polyline = canvas.getContext('2d');
    polyline.beginPath();
    polyline.lineTo(box.minx,box.miny);          polyline.lineTo(box.maxx,box.miny);
    polyline.lineTo(box.maxx,box.maxy);          polyline.lineTo(box.minx,box.maxy);
    polyline.lineTo(box.minx,box.miny);
    polyline.lineWidth=2;
    polyline.strokeStyle=color;
    polyline.lineCap = 'butt';
    polyline.stroke();
    polyline.closePath();

}
WorldMap.prototype.getKingdom = function(kingdom){
    var maxkingdom=100;
    kingdom.cells=[kingdom.capital];

    if (kingdom.id==2){
        //console.log(kingdom)
    }


    for (var i=0; i<maxkingdom; i++){
        // Select a random cell from the kingdom.cells list
        var parentCell= kingdom.cells[  Math.floor( Math.random()*kingdom.cells.length) ];

        // select a random side from our parent cell
        var side=parentCell.halfedges[ Math.floor( Math.random()*parentCell.halfedges.length)  ].edge;

        var cells=this.diagram.cells;

        if ( side.lSite != null &&  side.rSite != null ) {
            var target;
            if (kingdom.cells.indexOf(cells[side.lSite.voronoiId]) == -1) {
                // if lSite isn't in the list, it's our target
                target=cells[side.lSite.voronoiId]
            } else if (kingdom.cells.indexOf(cells[side.rSite.voronoiId]) == -1) {
                // if rSite isn't in the list, it's our target
                target=cells[side.rSite.voronoiId]
            }else{
                // the left side was found and the right side was found- this was a bunk edge.
            }
            if (target.ocean || target.kingdom){
                // this cell is useless
            }else{
                target.kingdom=true
                kingdom.cells.push(target);
            }
        
        }else{
            //This cell is of no use to us.
        }

    }
    kingdom=this.getKingdomPolygon(kingdom);
    return kingdom;
}
// Determine if halfedge has a side that is not in the kingdom list
WorldMap.prototype.isKingdomEdge = function(ids,halfedge){
    if (  ids.indexOf( halfedge.edge.lSite.voronoiId) ==-1 || ids.indexOf( halfedge.edge.rSite.voronoiId) ==-1  ){
        return true
    }else{
        return false
    }
}

WorldMap.prototype.getKingdomPolygon = function(kingdom){
        // Get a list of all IDs for the kingdom
        var ids=[]
        for (var i=0; i < kingdom.cells.length ; i++ ){ ids.push(kingdom.cells[i].site.voronoiId)}
        //Get a list of all external edges
        var edges=[];
        for (var i=0; i < kingdom.cells.length ; i++ ){
            var cell=kingdom.cells[i];
            for (var j=0; j < cell.halfedges.length ; j++ ){
                var he=cell.halfedges[j];
                if (  this.isKingdomEdge(ids,he) ){
                    edges.push(he);
                }
            }    
        }

        //loop through the edges and push them onto the outline list for drawing later
        var minx=1000000
        var pos;
        for (var i=0; i < edges.length ; i++ ){
            minx=Math.min(minx,edges[i].edge.va.x, edges[i].edge.va.x)
            if (edges[i].edge.va.x == minx){
                pos=edges[i].edge.va
            } else if (edges[i].edge.vb.x == minx){
                pos=edges[i].edge.vb
            }
        }
 
        kingdom.outline=[pos];
        var maxfail=edges.length;
        while(edges.length >0){
            var testedge=edges.pop()
            if (testedge.edge.va == pos ){
                    pos=testedge.edge.vb; 
                    kingdom.outline.push(pos);
                    maxfail=edges.length;
            }else if (testedge.edge.vb == pos ){
                    pos=testedge.edge.va; 
                    kingdom.outline.push(pos);
                    maxfail=edges.length;
            }else{
                maxfail--;
                if (maxfail== 0){
                    break;
                }
                edges.unshift(testedge);
            }
        }
        return kingdom;
}





function  WorldMap(width,height,point_count) {
    // Base Parameters
    this.width=width;
    this.height=height;
    this.num_points = point_count;
    this.terrain=[];
    this.terrain['Snow']                        ={color:'#F8F8F8'};
    this.terrain['Tundra']                      ={color:'#DDDDBB'};
    this.terrain['Bare']                        ={color:'#BBBBBB'};
    this.terrain['Scorched']                    ={color:'#999999'};
    this.terrain['Taiga']                       ={color:'#708C33'};

    this.terrain['Shrubland']                   ={color:'#CEE797'};
    this.terrain['Grassland']                   ={color:'#91C15E'};

    this.terrain['Subtropical Desert']          ={color:'#D2BCA3'};

    this.terrain['Temperate Desert']            ={color:'#D7D29A'};
    this.terrain['Temperate Deciduous Forest']  ={color:'#286D1B'};
    this.terrain['Temperate Rain Forest']       ={color:'#088814'};

    this.terrain['Tropical Seasonal Forest']    ={color:'#0D813C'};
    this.terrain['Tropical Rain Forest']        ={color:'#13602D'};
    //TODO I should add oceans here...    
    // default constant values
    this.lake_threshold=0.3;
    this.num_lloyd_iterations=2;

    // These are important bits to track
    this.points=Array();
    this.centers=Array();
    this.voronoi = new Voronoi();


    // Now lets actually make stuff. 
    //First generate points,
    this.generateRandomPoints();
    // then compute the virinoi
    this.buildGraph();
    //
}


/* **************************************************************** */
/*  buildGraph uses the points, width and height that were 
/*  previously set to generate a voronoi diagram.
/*  From there, the edges, centers and corners are calculated.
/* **************************************************************** */
WorldMap.prototype.buildGraph = function(){
    this.diagram = this.voronoi.compute(this.points, {xl:0,xr:this.width,yt:0,yb:this.height });
    this.improveRandomPoints();
    this.assignElevations();
    this.assignCoast();
    this.assignMoisture();
    this.assignTerrain();
    this.assignDownslopes();
    this.assignRivers();
}

WorldMap.prototype.randomLand = function(){
    var randomcell=null;
    while ( randomcell ==null){
        var cell=this.diagram.cells[ Math.floor(  Math.random()*this.diagram.cells.length  )   ];
        if (! cell.ocean && ! cell.kingdom && (cell.river || cell.lake || Math.random() >.5) ){
            randomcell=cell;
        }

    }
    return randomcell;    
}

WorldMap.prototype.assignRivers = function(){
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        if (! cell.ocean  && cell.river==false && cell.moisture > .5 && Math.random() > .9){
            this.setRiver(cell);
        }
    }
}

WorldMap.prototype.setRiver = function(cell){
    cell.river=true;
    if ( !cell.ocean && cell.downslope.site != cell.site  ){
        this.setRiver(cell.downslope);
    }else if (cell.downslope == cell ){
        cell.lake=true;
    }

}
WorldMap.prototype.assignCoast = function(){
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        if (! cell.ocean){
            for (var i=0; i<cell.halfedges.length; i++){
                var edge=cell.halfedges[i].edge;
                if (this.diagram.cells[edge.lSite.voronoiId].ocean || this.diagram.cells[edge.rSite.voronoiId].ocean){
                    cell.coast=true;
                }
            }
        }
    }
}
WorldMap.prototype.assignDownslopes = function(){
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        this.setDownslope(cell);
    }
}
WorldMap.prototype.getNeighbors = function(cell){
    var neighborIDs = cell.getNeighborIDs();
    var neighbors=[];
    for (var i=0; i<neighborIDs.length; i++){
        neighbors.push(this.diagram.cells[neighborIDs[i]]);
    }
    return neighbors;
}
WorldMap.prototype.setDownslope = function(cell){
    var neighborIDs = cell.getNeighborIDs();
    cell.downslope=cell;
    for (var i=0; i<neighborIDs.length; i++){
        var neighbor=this.diagram.cells[neighborIDs[i]];
        if (neighbor.elevation > cell.downslope.elevation ){
            cell.upslope.push(neighbor);
        }
        if (! cell.ocean && neighbor.ocean){
            // if you're on land and your neighbor is ocean, mark it as downslope and exit the loop.
            cell.downslope=neighbor;
            break; 
        }else if (neighbor.elevation < cell.downslope.elevation ){
            //otherwise check if the neighbor is lower than the previous low point.
            cell.downslope=neighbor;
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

WorldMap.prototype.drawRegion = function(canvas,kingdomid){
    // First find bounding box
    var kingdom=this.kingdoms[kingdomid];

    var box= kingdom.regionbox;
    //console.log(box)
    this.translateregion(box,canvas);

    var regions=this.diagram.cells;

    var points=this.getKingdomPolygon(kingdom);
    if (kingdomid==7){

    }
    //console.log("regionid:"+kingdomid)

    for (var i=0; i < regions.length ; i++ ){
        this.colorPolygon(regions[i],canvas,'biomes');
    }
    // translate cell details over


}
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
WorldMap.prototype.translateregion = function(box,canvas){
    for (var i=0; i < this.diagram.cells.length ; i++ ){ 
        var cell=this.diagram.cells[i];
        
        canvas.height=(box.maxy-box.miny)/(box.maxx-box.minx)*canvas.width

        cell.site.x=this.translatePoint(cell.site.x,box.minx,box.maxx,canvas.width);
        cell.site.y=this.translatePoint(cell.site.y,box.miny,box.maxy,canvas.height);
        for (var j=0; j < cell.halfedges.length ; j++ ){ 
            var edge=cell.halfedges[j].edge;
            if (edge.va.wastranslated != true){
                edge.va.wastranslated=true
                edge.va.x=this.translatePoint(edge.va.x,box.minx,box.maxx,canvas.width);
                edge.va.y=this.translatePoint(edge.va.y,box.miny,box.maxy,canvas.height);
            }
            if (edge.vb.wastranslated != true){
                edge.vb.wastranslated=true
                edge.vb.x=this.translatePoint(edge.vb.x,box.minx,box.maxx,canvas.width);
                edge.vb.y=this.translatePoint(edge.vb.y,box.miny,box.maxy,canvas.height);
            }
        }
    }
}

///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
WorldMap.prototype.translatePoint = function(x,min,max,width){
    return Math.round(      (x-min)*width/(max-min)    );
}


///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
WorldMap.prototype.box = function(cells){
    var minx=100000;
    var miny=100000;
    var maxx=0;
    var maxy=0;
    var fullcellIDs=[]
    for (var i=0; i < cells.length ; i++ ){ 
        var cell=cells[i];
        fullcellIDs.push(cell.site.voronoiId);
        //check both centers and edges
        for (var j=0; j < cell.halfedges.length ; j++ ){ 
            var he=cell.halfedges[j].edge;
            if (he.rSite != null && fullcellIDs.indexOf(he.rSite.voronoiId) ==-1){fullcellIDs.push(he.rSite.voronoiId);}
            if (he.lSite != null && fullcellIDs.indexOf(he.lSite.voronoiId) ==-1){fullcellIDs.push(he.lSite.voronoiId);}
            maxx=Math.ceil(Math.max(maxx,he.va.x,he.vb.x));
            maxy=Math.ceil(Math.max(maxy,he.va.y,he.vb.y));
            minx=Math.floor(Math.min(minx,he.va.x,he.vb.x));
            miny=Math.floor(Math.min(miny,he.va.y,he.vb.y));
        }
    }

    for (var i=0; i < fullcellIDs.length ; i++ ){ 
        var cell=this.diagram.cells[fullcellIDs[i]];
        this.region.push(cell);
        for (var j=0; j < cell.halfedges.length ; j++ ){ 
            var he=cell.halfedges[j];
            maxx=Math.ceil(Math.max(maxx,he.edge.va.x,he.edge.vb.x));
            maxy=Math.ceil(Math.max(maxy,he.edge.va.y,he.edge.vb.y));
            minx=Math.floor(Math.min(minx,he.edge.va.x,he.edge.vb.x));
            miny=Math.floor(Math.min(miny,he.edge.va.y,he.edge.vb.y));
        }
    }

    return {minx:minx,miny:miny,maxx:maxx,maxy:maxy};
}

WorldMap.prototype.drawRivers = function(canvas){
    var ctx = canvas.getContext('2d');

    for (var i=0; i<this.diagram.cells.length; i++){
        var cell=this.diagram.cells[i];
        if ( cell.river ){
            ctx.strokeStyle='rgba(128,128,255,0.5)';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(cell.site.x,cell.site.y);
            ctx.lineTo(cell.downslope.site.x,cell.downslope.site.y);
            ctx.closePath();
            ctx.stroke();
        }
        if ( cell.lake){
            this.colorPolygon(cell,canvas,'highlight','rgba(128,128,255,0.5)');
        }
    }
}

WorldMap.prototype.drawDownslopes = function(canvas){
    var ctx = canvas.getContext('2d');

    for (var i=0; i<this.diagram.cells.length; i++){
        var cell=this.diagram.cells[i];
        if ( ! cell.ocean && cell.site != cell.downslope.site ){
            ctx.lineCap = 'round';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(cell.site.x,cell.site.y);
            ctx.lineTo(cell.downslope.site.x,cell.downslope.site.y);
            ctx.closePath();
            ctx.stroke();
        } else if ( ! cell.ocean && cell.site == cell.downslope.site){
            ctx.lineCap = 'round';
            ctx.lineWidth = 5;
            ctx.beginPath();
            ctx.moveTo(cell.site.x,cell.site.y);
            ctx.lineTo(cell.site.x+3,cell.site.y+3);
            ctx.closePath();
            ctx.stroke();


        }
    }
}


/* **************************************************************** */
/*  generateRandomPoints  generate a random set of points using
/*  the previously provided width, height, and number of points.
/* **************************************************************** */
WorldMap.prototype.generateRandomPoints = function(){
    var points = [];
    var margin=0;
    for (var i=0; i<this.num_points; i++) {
        points.push({
                    x:Math.round((Math.random()*(this.width  -margin*2) )*10)/10 +margin,
                    y:Math.round((Math.random()*(this.height -margin*2) )*10)/10 +margin
                    });
    }
    this.points=points;
}      
/* **************************************************************** */
/*  assignMoisture for each cell, assign moisture which is a
/*  combination of elevation and simplex noise
/* **************************************************************** */
WorldMap.prototype.assignMoisture = function() {
    var sim = new SimplexNoise() ;
    //We're gonna track our min and max so we can resize later.
    var min=1;
    var max=0;
    
    for (cellid in this.diagram.cells){

        // Lets use some easier-to-remember variables
        var cell   = this.diagram.cells[cellid];
        var width  = this.width;
        var height = this.height;
        var x = cell.site.x;
        var y = cell.site.y;
        var centerx = width/2;
        var centery = height/2;
        var adjustedx=x-centerx;
        var adjustedy=y-centery;

        var noise= sim.noise2D(Math.abs(adjustedx),Math.abs(adjustedy));

        // Pythagorean theorem for the win
        cell.radius=1//+  Math.sqrt( Math.pow(adjustedx,2) + Math.pow(adjustedy,2))/30;

        var percent= Math.abs(cell.radius)  +noise/20;
        cell.debug=adjustedx+" "+adjustedy + " radius:"+cell.radius+"   percent: "+percent;

        percent=Math.pow(percent,2)-.6+sim.noise2D(x/150,y/150)/2;
        cell.moisture=Math.round( percent*300)/100 ;

        // If this moisture is a new min or max moisture, lets track it.
        if (cell.moisture < min){min=cell.moisture};
        if (cell.moisture > max){max=cell.moisture};
    }
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        cell.moisture=Math.round(  (cell.moisture-min)/(max-min)*100)/100;
    }
    
}

/* **************************************************************** */
/*  assignTerrain using elevation and moisture, set the proper
/*  terrain for each cell.
/* **************************************************************** */
WorldMap.prototype.assignTerrain = function() {
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        var pelevation=cell.elevation;
        var pmoisture=cell.moisture;
        if (cell.coast){
            pmoisture= pmoisture*0.7;
        }
        cell.terrain=this.getTerrain(pelevation,pmoisture);
    }
}
/* **************************************************************** */
/*  getTerrain Given an elevation and moisture, select the proper terrain type
/*
/* **************************************************************** */
WorldMap.prototype.getTerrain = function(elevation,moisture) {
    var terrain=[ //This is a very ugly hack.
            ['Subtropical Desert','Grassland','Tropical Seasonal Forest','Tropical Seasonal Forest','Tropical Rain Forest','Tropical Rain Forest'],
            ['Temperate Desert','Grassland','Grassland','Temperate Deciduous Forest','Temperate Deciduous Forest','Temperate Rain Forest'],
            ['Temperate Desert','Temperate Desert','Shrubland','Shrubland','Taiga','Taiga'],
            ['Scorched','Bare','Tundra','Snow','Snow','Snow'],
            ];
    var pelevation=Math.floor((elevation)*3 ); 
    var pmoisture=Math.floor((moisture)*5);
    //console.log("----------")
    //console.log(pelevation+"  "+pmoisture+" "+terrain[pelevation])
    return terrain[pelevation][pmoisture];
}

WorldMap.prototype.getTerrainColor = function(tname) {
    return this.terrain[tname].color;
}


/* **************************************************************** */
/*  assignElevations for each cell, assign an elevation which is a
/*  combination of radial distance from the center and simplex noise
/* **************************************************************** */
WorldMap.prototype.assignElevations = function() {
    var sim = new SimplexNoise() ;

    //We're gonna track our min and max so we can resize later.
    var min=1;
    var max=0;
    var landmin=1;
    var landmax=0;
    var oceanmin=1;
    var oceanmax=0;
    
    for (cellid in this.diagram.cells){

        // Lets use some easier-to-remember variables

        var cell   = this.diagram.cells[cellid];
        cell.elevation=this.getSitePercent(cell.site,sim);
        // If this elevation is a new min or max elevation, lets track it.
        if (cell.elevation < min){min=cell.elevation};
        if (cell.elevation > max){max=cell.elevation};

        for (cornerid in cell.corners){
            var corner=cell.corners[cornerid];
            corner.elevation=this.getSitePercent(corner,sim);
            // If this elevation is a new min or max elevation, lets track it.
            if (corner.elevation < min){min=corner.elevation};
            if (corner.elevation > max){max=corner.elevation};
        }

    }

    // re-examine the cells and adjust to a 0-1 range, then 
    // set the cell to ocean if its value is >.5 or is a border
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        //adjust min and max to be on the proper scale.
        cell.elevation=(cell.elevation-min)/(max-min);
        if (cell.elevation > .5 || cell.border){
            cell.ocean=true;
            if (cell.elevation < oceanmin){oceanmin=cell.elevation};
            if (cell.elevation > oceanmax){oceanmax=cell.elevation};
        }else{
            if (cell.elevation < landmin){landmin=cell.elevation};
            if (cell.elevation > landmax){landmax=cell.elevation};
        }
        for (cornerid in cell.corners){
            var corner=cell.corners[cornerid];
                corner.elevation=(corner.elevation-min)/(max-min);
            if (corner.elevation > .5 ){
                corner.ocean=true;
                if (corner.elevation < oceanmin){oceanmin=corner.elevation};
                if (corner.elevation > oceanmax){oceanmax=corner.elevation};
            }else{
                if (corner.elevation < landmin){landmin=corner.elevation};
                if (corner.elevation > landmax){landmax=corner.elevation};
            }
    
        }
    }
    //Because two loops wasn't enough, resize scales for ocean and land seperately
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        if (cell.ocean){
            cell.elevation=1-(cell.elevation-oceanmin)/(oceanmax-oceanmin);
        }else{
            cell.elevation=1-(cell.elevation-landmin)/(landmax-landmin);
        }
        for (cornerid in cell.corners){
            var corner=cell.corners[cornerid];
                corner.elevation=(corner.elevation-min)/(max-min);
            if (corner.ocean ){
                corner.elevation=1-(corner.elevation-oceanmin)/(oceanmax-oceanmin);
            }else{
                corner.elevation=1-(corner.elevation-landmin)/(landmax-landmin);
            }
    
        }
    }

}

WorldMap.prototype.getSitePercent = function(site, sim){
        // Lets use some easier-to-remember variables
        var width  = this.width;
        var height = this.height;
        var x = site.x;
        var y = site.y;
        var centerx = width/2;
        var centery = height/2;
        var lesser  = Math.min(width, height);
        var minradius= Math.sqrt(   Math.pow(lesser,2) + Math.pow(lesser,2))/2 ;
        var adjustedx=x-centerx;
        var adjustedy=y-centery;

        // Pythagorean theorem for the win
        var radius=  Math.sqrt( Math.pow(adjustedx,2) + Math.pow(adjustedy,2));
        var percent= Math.abs(radius/minradius) ;
        // Reduce the percentage by half and pad it with simplex noise
        percent= percent/2  +   sim.noise2D(x/200,y/200)/4;

        return Math.round( percent*100)/100 ;
}


/* **************************************************************** */
/*  colorCorner make an ugly square given a corner and a canvas
/*  to draw on.
/* **************************************************************** */
WorldMap.prototype.colorCorner = function(corner,canvas,mode,color){
    if (color == null){
        if (mode=='elevation'){  //note that there is a two-tone color difference between land and ocean
            //not intentional, but s exxpected.
                var c= parseInt(Math.floor(corner.elevation*128))*2;
                corner.color= 'rgb(' + c + "," + c + "," + c + ")";
        }else if (mode=='moisture'){ 
            var c= parseInt(Math.floor(corner.moisture*128))*2;
            corner.color= 'rgb(' + c + "," + c + "," + c + ")";

        }else if (mode=='biomes'){ 
            if (corner.elevation < .5){
                corner.color=this.getOceanColor(corner);
            }else{
               corner.color='#00ff00';
            }
        }else if (mode=='land elevation'){ 
            if (corner.elevation < .5){
                corner.color=this.getOceanColor(corner);
            }else{
                var c= parseInt(Math.floor(corner.elevation*128))*2; //The closer the elevation is to 0
                corner.color= 'rgb(' + c + "," + c + "," + c + ")";
            }
        }
    }else{
        corner.color=color;
    }
    var polyfill = canvas.getContext('2d');

    polyfill.strokeStyle='#ff00ff';
    polyfill.fillStyle='#ff00ff';
    polyfill.beginPath();
    polyfill.lineTo(corner.x-1,corner.y-1);
    polyfill.lineTo(corner.x+1,corner.y-1);
    polyfill.lineTo(corner.x+1,corner.y+1);
    polyfill.lineTo(corner.x-1,corner.y+1);


    polyfill.closePath();
    polyfill.fill();
    polyfill.stroke();

}
/* **************************************************************** */
/*  colorPolygon make a pretty polygon given a cellid and a canvas
/*  to draw on.
/* **************************************************************** */
WorldMap.prototype.colorPolygon = function(cell,canvas,mode,color,noborder){
    if (color == null){
        if (mode=='elevation'){  //note that there is a two-tone color difference between land and ocean
            //not intentional, but s exxpected.
                var c= parseInt(Math.floor(cell.elevation*128))*2;
                cell.color= 'rgb(' + c + "," + c + "," + c + ")";
        }else if (mode=='moisture'){ 
            var c= parseInt(Math.floor(cell.moisture*128))*2;
            cell.color= 'rgb(' + c + "," + c + "," + c + ")";

        }else if (mode=='biomes'){ 
            if (cell.ocean){
                cell.color=this.getOceanColor(cell);
            }else{
               cell.color=this.terrain[ cell.terrain].color;
            }
        }else if (mode=='land elevation'){ 
            if ( cell.ocean){
                cell.color=this.getOceanColor(cell);
            }else{
                var c= parseInt(Math.floor(cell.elevation*128))*2; //The closer the elevation is to 0
                cell.color= 'rgb(' + c + "," + c + "," + c + ")";
            }
        }
    }else{
        cell.color=color;
    }
    var polyfill = canvas.getContext('2d');

    polyfill.fillStyle=cell.color;
    polyfill.strokeStyle=cell.color;
    polyfill.beginPath();
    // draw a line for each edge, A to B.
    for (var i=0; i<cell.halfedges.length; i++) {

        var vertexa=cell.halfedges[i].getStartpoint();
        polyfill.lineTo(vertexa.x,vertexa.y);
        var vertexb=cell.halfedges[i].getEndpoint();
        polyfill.lineTo(vertexb.x,vertexb.y);
    }
    //close the path and fill it in with the provided color
    polyfill.closePath();
    polyfill.fill();
    if (!noborder){
        polyfill.stroke();
    }
}

/* **************************************************************** */
/*  render uses the edges from the diagram, then mark the points.
/* **************************************************************** */
WorldMap.prototype.getOceanColor = function(obj){
                var c= parseInt(Math.floor((obj.elevation)*128));
                return 'rgb(' + c + "," + c + ", 255)";
//    if (cell.elevation <.6){
//        return '#5588ff';
//    }else if (cell.elevation <.7){
//        return '#4477ff';
//    }else{
//        return '#3366ff';
//    }
}


/* **************************************************************** */
/*  render uses the edges from the diagram, then mark the points.
/* **************************************************************** */
WorldMap.prototype.render = function(canvas){
    var ctx = canvas.getContext('2d');
   
    //First lets draw all of the edges.
    // This can probably be refactored
    ctx.strokeStyle="rgba(0,0,0,.5)";
    ctx.lineWidth=1;
    ctx.beginPath();
    var edges = this.diagram.edges;
    var iEdge = edges.length;
    var edge, v;
    while (iEdge--) {
        edge = edges[iEdge];
        v = edge.va;
        ctx.moveTo(v.x,v.y);
        v = edge.vb;
        ctx.lineTo(v.x,v.y);
        }
    ctx.stroke();

    // Now lets draw some red dots at the 
    // point for each cell (note, not the center)
    // This can probably be refactored
    ctx.fillStyle = '#faa';
    ctx.beginPath();
    var msites = this.points,
        iSite = this.points.length;
    while (iSite--) {
        v = msites[iSite];
        //TODO this doesn't need to be a rectangle; simplify with a dot if possible
        ctx.rect(v.x-2/3,v.y-2/3,2,2);
        }
    ctx.fill();

    //TODO add the centers to the render list.
}


/* **************************************************************** */
/*  paintBackground is relatively simple- it just draws the 
/*  background rectangle.
/* **************************************************************** */
WorldMap.prototype.paintBackground = function(canvas,color){
        var ctx = canvas.getContext('2d');
        ctx.globalAlpha = 1;
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.rect(0,0,canvas.width,canvas.height);
        ctx.fill();
}

WorldMap.prototype.improveRandomPoints = function(){
    var points=[];
    for (var i = 0; i < this.num_lloyd_iterations; i++) {
        points=[];
        for(cellid in this.diagram.cells) {
            var cell = this.diagram.cells[cellid];
            cell.site.x = 0.0;
            cell.site.y = 0.0;
            var count=0;
            for (hedgeid in cell.halfedges) {
                var he = cell.halfedges[hedgeid];
                var hestart=he.getStartpoint();
                if (hestart.x != NaN && hestart.y != NaN){
                    cell.site.x += hestart.x||0;
                    cell.site.y += hestart.y||0;
                    count++;
                }
                var heend=he.getEndpoint();
                if (heend.x != NaN && heend.y != NaN){

                    cell.site.x += heend.x||0;
                    cell.site.y += heend.y||0;
                    count++;
                }
            }
            var px = parseInt(cell.site.x / count);
            var py = parseInt(cell.site.y / count);
            points.push({x:px,
                        y:py
                        });
        }
        
        this.voronoi.reset();
        this.points=points;
        this.diagram = this.voronoi.compute(this.points, {xl:0,xr:this.width,yt:0,yb:this.height });
    }
}
