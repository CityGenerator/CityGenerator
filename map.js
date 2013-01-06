/* **************************************************************** */
/*  Lets generate a worldmap!
/* **************************************************************** */

function create_map(seed, canvas){
    console.log(seed);
    var mod=seed%10
    var continentseed=seed-mod;
    console.log(continentseed);
    Math.seedrandom(continentseed);
    var width =400;
    var height=400;
    var sites=2000;
    canvas.height=height;canvas.width=width
    var map=new WorldMap(width,height,sites);
    map.paintBackground(canvas);
    for (var i=0; i < map.diagram.cells.length ; i++ ){
        map.colorPolygon(i,canvas,'biomes');
    }
    map.drawRivers(canvas);

    map.drawNeighborKingdoms(continentseed,mod,canvas);    

    

}

WorldMap.prototype.drawNeighborKingdoms = function(continentseed,mod,canvas){
    var colors = [   ' 255,105,180 ', ' 139,0,0 ',  ' 255,140,0 ',  ' 255,255,0 ',  ' 124,252,0 ', 
                     ' 127,255,212 ',  '95,158,160  ',  '  30,144,255 ',  '  238,130,238',  '128,0,128  '      ];
    for (var i=0 ; i<10 ; i++){
        Math.seedrandom( continentseed  + i   )    ;
        console.log(colors[i])
        var color='rgba('+colors[i]+',.5)';
        if (i == mod){
            color= 'rgba(200,0,0,.3)';



        var testcell=this.randomLand();
        while ( testcell.kingdom){
            testcell=this.randomLand();
        }
        this.drawKingdom( canvas,color, testcell);
        }

    }
                        

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
        if (! cell.ocean && ! cell.kingdom){
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

WorldMap.prototype.drawKingdom = function(canvas,color,cell){
        var klist=this.getKingdom(cell);
        for (var j=0; j < klist.length ; j++ ){
            this.colorPolygon(klist[j].site.voronoiId,canvas,'highlight', color);
        }
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
            this.colorPolygon(cell.site.voronoiId,canvas,'highlight','rgba(128,128,255,0.5)');
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



WorldMap.prototype.getKingdom = function(cell){
    //choose between 1 and sites/100
    //var maxkingdom=this.diagram.cells.length/100;
    var maxkingdom=50;
    var kingdomlist=[cell];
    for (var i=0; i<maxkingdom; i++){
        //console.log('i '+i+" of "+maxkingdom)
        var parentcellid=Math.floor( Math.random()*kingdomlist.length);
        //console.log("parentcellid "+parentcellid +" of "+kingdomlist.length);

        var parentCell=kingdomlist[parentcellid];
        //console.log(parentCell);
        var sideid=Math.floor( Math.random()*parentCell.halfedges.length); 
        //console.log(sideid);
        var side=parentCell.halfedges[ sideid  ];
        var childcell;

        //console.log("================ lsite:" + side.edge.lSite+" voronoiid "+side.edge.lSite.voronoiId);
        if (         side.edge.lSite != null &&  kingdomlist.indexOf(this.diagram.cells[side.edge.lSite.voronoiId]) == -1 && ! this.diagram.cells[side.edge.lSite.voronoiId].ocean &&this.diagram.cells[side.edge.lSite.voronoiId].kingdom==false ){
            //console.log("lsite: ")
            this.diagram.cells[side.edge.lSite.voronoiId].kingdom=true
            kingdomlist.push(this.diagram.cells[side.edge.lSite.voronoiId]);
        } else if (  side.edge.rSite != null  && kingdomlist.indexOf(this.diagram.cells[side.edge.rSite.voronoiId]) == -1 && ! this.diagram.cells[side.edge.rSite.voronoiId].ocean && this.diagram.cells[side.edge.lSite.voronoiId].kingdom==false){
            //console.log("rsite: ")
            this.diagram.cells[side.edge.rSite.voronoiId].kingdom=true
            kingdomlist.push(this.diagram.cells[side.edge.rSite.voronoiId]);
        }else{
            //console.log("reduce i" +i)
        }
        //console.log(kingdomlist);
    }
    //select random half-edge
    return kingdomlist;
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
        var lesser  = width < height ? width : height;
        var minradius= 1;//Math.sqrt(   Math.pow(lesser,2) + Math.pow(lesser,2))/2 ;
        var adjustedx=x-centerx;
        var adjustedy=y-centery;

        var noise= sim.noise2D(Math.abs(adjustedx),Math.abs(adjustedy));

        // Pythagorean theorem for the win
        cell.radius=1//+  Math.sqrt( Math.pow(adjustedx,2) + Math.pow(adjustedy,2))/30;

        var percent= Math.abs(cell.radius/minradius)  +noise/20;
        cell.debug=adjustedx+" "+adjustedy + " radius:"+cell.radius+"  minradius:"+minradius+" percent: "+percent;

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
        var lesser  = width < height ? width : height;
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
WorldMap.prototype.colorPolygon = function(cellid,canvas,mode,color,noborder){
    var cell = this.diagram.cells[cellid];
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
        ctx.strokeStyle='#aaaaaa';
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
WorldMap.prototype.paintBackground = function(canvas){
        var ctx = canvas.getContext('2d');
        ctx.globalAlpha = 1;
        ctx.fillStyle = 'white';
        ctx.beginPath();
        ctx.rect(0,0,this.width,this.height);
        ctx.fill();
}

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
//
//    function go(){
//    
//        //The go function appears to be the core of the map class
//        //reset();
//        //=== Place Points ===
//            this.points=generateRandomPoints()
//        //=== Improve Points ===
//            improveRandomPonts(this.points);
//        //=== build graph ===
//            //magic happens here.
//            //this.voronoi= new Voronoi(points,null,rectangle); // I do not have this!!!
//            //buildGraph(points,voronoi)
//            //improveCorners();
//    
//        //=== Assign elevations ===
//            assignCornerElevations();
//            assignOceanCoastAndLand();
//            redistributeElevations(landCorners(this.corners));
//            for ( corner in this.corners){
//                if (corner.ocean ||corner.coast){
//                    corner.elevation=0.0;
//                }
//            }
//            assignPolygonElevations();
//        //=== Assign Moisture ===
//            calculateDownslopes();
//            calculate_watersheds();
//            createRivers();
//            assignCornerMoisture();
//            redistributeMoisture(landCorners(this.corners));
//            assignPolygonMoisture();
//        //=== Decorate Map
//            assignBiomes();
//    }
//
//
//    function improveRandomPonts(){
//        //TODO use lloyd relaxation on this.points
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
//        // requires Voronoi voodoo
//    }
//    function improveCorners(){
//        // TODO This is truthfully icing that isn't needed immediately.
//
//    }    
//
//    //I do not currently understand the purpose of this method.
//    function landCorners(){
//        var locations=Array();
//        for (corner in this.corners){
//          if (!corner.ocean && !corner.coast) {
//            locations.push(corner);
//          }
//        }
//        return locations;
//    }
//
//
WorldMap.prototype.assignCornerElevations = function(){


        // TODO yeah this one as well.
    }
//    function redistributeElevations(locations){
//        // TODO yeah this one as well.
//    }
//    function redistributeMoisture(locations){
//        // TODO yeah this one as well.
//    }
//    function assignOceanCoastAndLand(){
//        // TODO
//    }
//    function assignPolygonElevations(){
//        //TODO
//    }
//    function calculateDownslopes(){
//        for (corner in this.corners){
//            //tempcorner finds the lowest adjacent corner to mark as a downslope
//            // and the default is itself.
//            var tempcorner=corner;
//            for (adjacent_corner in corner.adjacent){
//                if (adjacent_corner.elevation <= tempcorner.elevation){
//                    tempcorner=adjacent_corner;
//                }
//            }
//            corner.downslope=tempcorner;
//        }
//    }
//    function calculateWatersheds(){
//        for (corner in this.corners){
//            corner.wathershed=corner
//            if (!corner.ocean && !corner.coast) {
//            corner.watershed=corner.downslope;
//            }
//        }
//        //TODO finish this
//    }
//    function createRivers(){
//        //TODO finish this
//    }
//    function assignCornerMoisture(){
//        //TODO finish this
//    }
//    function assignPolygonMoisture(){
//        //TODO finish this
//    }
//   
// 
//
//
//
