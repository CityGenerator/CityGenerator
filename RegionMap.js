/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype = Object.create(VoronoiMap.prototype);
RegionMap.prototype.constructor = RegionMap;


function  RegionMap(width,height,points) {
//    VoronoiMap.call(this,width,height,num_points)
    this.width=width;
    this.height=height;
    this.num_points=points.length
    // These are important bits to track
    this.voronoi = new Voronoi();

    //First generate points,
    this.points=points;

    // then compute the virinoi
    this.buildGraph();

    // Base Parameters

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

//    this.assignElevations();
//    this.assignCoast();
//    this.assignMoisture();
//    this.assignTerrain();
//    this.assignDownslopes();
//    this.assignRivers();
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.drawTexture = function(canvas){
    var c = canvas.getContext('2d');
//    c.scale(this.scale,this.scale);

    var sim = new SimplexNoise() ;
    //We're gonna track our min and max so we can resize later.
    var min=1;
    var max=0;
    var imageData = c.getImageData(0, 0, canvas.width, canvas.height);
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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.drawCities = function(canvas,regionmod,citymod,names){
    
    for (var cityid=0 ; cityid<10 ; cityid++){
        //console.log(cityid+" "+citymod)
        // Using the region and cityid, select a cell and get a list of its corners
        var regioncount=this.kingdoms[regionmod].cells.length;
        //FIXME I think something is wrong with cell selection; cities seem grouped.
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
        this.paintDot(canvas,point.x,point.y,2,color);
    }

}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.paintMap = function(canvas){
    this.paintBackground(canvas,'#ffffff');
    console.log(this)
    for (var i=0; i < this.diagram.cells.length ; i++ ){
        this.colorPolygon(this.diagram.cells[i],canvas,'biomes');
    }
//    this.drawRivers(canvas);
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.designateKingdoms = function(continentseed){
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

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.boxKingdoms = function(){
    for (var i=0; i < this.kingdoms.length ; i++ ){
        this.boxKingdom(this.kingdoms[i])
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.boxKingdom = function(kingdom){
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

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.setbox = function(box, va, vb){
    box.maxx=Math.ceil(Math.max( box.maxx,va.x,vb.x));
    box.maxy=Math.ceil(Math.max( box.maxy,va.y,vb.y));
    box.minx=Math.floor(Math.min(box.minx,va.x,vb.x));
    box.miny=Math.floor(Math.min(box.miny,va.y,vb.y));
    return box
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.drawKingdoms = function(canvas, fill){
    for (var i=0 ; i<10 ; i++){
        this.drawKingdom(this.kingdoms[i],canvas, fill)
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.drawKingdom = function(kingdom,canvas, fill){
    var polyline = canvas.getContext('2d');
//    polyline.scale(this.scale,this.scale);

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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.getKingdom = function(kingdom){
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
            }
            if ( ! target.ocean && ! target.kingdom){
                target.kingdom=true
                kingdom.cells.push(target);
            }
        }

    }
    kingdom=this.getKingdomPolygon(kingdom);
    return kingdom;
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

// Determine if halfedge has a side that is not in the kingdom list
RegionMap.prototype.isKingdomEdge = function(ids,halfedge){
    if (  ids.indexOf( halfedge.edge.lSite.voronoiId) ==-1 || ids.indexOf( halfedge.edge.rSite.voronoiId) ==-1  ){
        return true
    }else{
        return false
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.getKingdomPolygon = function(kingdom){
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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.randomLand = function(){
    var randomcell=null;
    while ( randomcell ==null){
        var cell=this.diagram.cells[ Math.floor(  Math.random()*this.diagram.cells.length  )   ];
        if (! cell.ocean && ! cell.kingdom && (cell.river || cell.lake || Math.random() >.5) ){
            randomcell=cell;
        }

    }
    return randomcell;    
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.getNeighbors = function(cell){
    var neighborIDs = cell.getNeighborIDs();
    var neighbors=[];
    for (var i=0; i<neighborIDs.length; i++){
        neighbors.push(this.diagram.cells[neighborIDs[i]]);
    }
    return neighbors;
}


/* ========================================================================= */
/*  redraw what this should look like on a given canvas 
/*  
/* ========================================================================= */

//RegionMap.prototype.redraw = function(canvas,scale){
//    if (scale == undefined) {
//        scale=this.scale
//    }
//    this.paintBackground(canvas,'#ffffff',scale);
//    this.paintMap(canvas)
//    this.drawKingdoms(canvas,true);
//    this.drawbox(this.kingdoms[this.currentRegion].regionbox,canvas,'rgba(255,0,255,1)');
//
//}
//

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.clone = function(worldmap){
    for (var i =0; i<worldmap.diagram.cells.length;i++){
        var oldcell=worldmap.diagram.cells[i];
        var newcell=this.diagram.cells[i];
        newcell.elevation = oldcell.elevation
        newcell.moisture = oldcell.moisture
        newcell.radius = oldcell.radius
        newcell.river = oldcell.river
        newcell.lake = oldcell.lake
        newcell.coast = oldcell.coast
        newcell.kingdom = oldcell.kingdom
        newcell.upslope = oldcell.upslope
        newcell.color = oldcell.color
        newcell.border = oldcell.border
    }
    this.kingdoms=[]
    for (var i =0; i<worldmap.kingdoms.length;i++){
//        var oldkingdom=worldmap.kingdoms[i];
//        var newkingdom={cells:[]};
//        for (var j =0; j<kingdom.cells.length;j++){
//            var newcell=kingdom.cells[i];
//            var oldcell=kingdom.cells[i];
//            newcell.elevation = oldcell.elevation
//            newcell.moisture = oldcell.moisture
//            newcell.radius = oldcell.radius
//            newcell.river = oldcell.river
//            newcell.lake = oldcell.lake
//            newcell.coast = oldcell.coast
//            newcell.kingdom = oldcell.kingdom
//            newcell.upslope = oldcell.upslope
//            newcell.color = oldcell.color
//            newcell.border = oldcell.border
//            newkingdom.cells.push(newcell)
//        }
//        newkingdom.regionbox=worldmap.kingdoms[i].regionbox;
//        newkingdom.kingdombox=worldmap.kingdoms[i].kingdombox;
//        this.kingdoms.push[kingdom]
    }


}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.drawRegion = function(canvas,kingdomid){
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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.translateregion = function(box,canvas){
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




/* ========================================================================= */
/*  getTerrain Given an elevation and moisture, select the proper terrain type
/* 
/* ========================================================================= */

RegionMap.prototype.getTerrain = function(elevation,moisture) {
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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.getTerrainColor = function(tname) {
    return this.terrain[tname].color;
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.getOceanColor = function(obj){
    var c= parseInt(Math.floor((obj.elevation)*128));
    return 'rgb(' + c + "," + c + ", 255)";
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

RegionMap.prototype.colorPolygon = function(cell,canvas,mode,color,noborder){
    if (color == undefined){
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
//    polyfill.scale(this.scale,this.scale);

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


