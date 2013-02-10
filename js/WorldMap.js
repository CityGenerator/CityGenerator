/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype = Object.create(VoronoiMap.prototype);
WorldMap.prototype.constructor = WorldMap;

function  WorldMap(width,height,num_points,seed,cities,regions) {
    VoronoiMap.call(this,width,height,num_points)
    // regionmod determines which of the 10 regions on this continent to use.
    // With a cityid of 744158, the 5 indications which region to focus on
    this.currentRegionId=Math.floor(   (seed%100)/10  );

    // citymod determines which of the 10 cities in this region to use.
    // uses the last  digit of the cityid: 744158 -> 8
    this.currentCityId=Math.floor(seed%100);

    this.seed=seed

    this.cities=cities;
    this.regions=regions;

    // continent seed refers to which continent we're on- it essentially
    // ignores the last two digits of the cityid: 744158 -> 744100 
    this.currentContinentId = seed -  seed%100;

    var minregion=num_points/200
    var maxregion=num_points/2

    this.maxregion= Math.random()*(maxregion-minregion)+minregion
    console.log('max region size: ' +this.maxregion)
    // Base Parameters
    //TODO refactor terrain
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

    this.assignElevations();
    this.assignCoast();
    this.assignMoisture();
    this.assignTerrain();
    this.assignDownslopes();
    this.assignRegions()
    this.assignCities();
    this.assignRivers();
    this.area=this.sumLandArea(this.diagram.cells);
    this.closeneighbors=this.findNeighborCities(this.currentCityId,4);
}
WorldMap.prototype.sumLandArea = function(cells){
    var area=0
    for (var i = 0; i<cells.length ; i++){
        var cell=cells[i]
        if (!cell.ocean){
            area+=Math.abs(cell.area);
        }
    }
    return area
}

WorldMap.prototype.findNeighborCities = function(cityid,count){
    var city=this.cities[cityid];
    var neighbors=[]
    for (var i = 0; i<this.cities.length ; i++){
        if (i != this.currentCityId){
            var neighbor = this.cities[i];
            neighbor.distance = Math.sqrt( Math.pow(city.point.x - neighbor.point.x,2) +  Math.pow(city.point.y - neighbor.point.y ,2)    );
            neighbors.push( neighbor );
        }
    }
    neighbors.sort(compare)

    neighbors.shift()// the closest city is itself, so cut it out.

    if (count != undefined){
        return neighbors.splice( 0 ,count);
    }
    return neighbors

}
    function compare(a,b) {
        return  (a.distance < b.distance) ? -1 : 1
    }

WorldMap.prototype.redrawRegion = function(canvas){
//XXX
    var citybox=this.cities[this.currentCityId].box
    this.xoffset=-citybox.minx*2.5
    this.yoffset=-citybox.miny*2.5
    this.setMultiplier(2.5)
    this.redraw(canvas)
    this.setMultiplier(2.5)
    this.drawCityName(canvas,this.cities[this.currentCityId])
    this.setMultiplier(1)
    this.xoffset=0
    this.yoffset=0

}
 
WorldMap.prototype.drawCityName = function(canvas,city){
    var context = canvas.getContext('2d');
    context.fillStyle="rgba(0,0,0,1)";
    context.font = "bold 12px Arial" ;
    var nameoffset= city.name.length*12/4
    //context.fillText(city.name, this.xoffset+this.xmultiplier*city.cell.site.x-nameoffset, this.yoffset+this.ymultiplier*city.cell.site.y);
    context.fillText(city.name, this.xoffset+this.xmultiplier*city.cell.site.x -nameoffset , this.yoffset+this.ymultiplier*city.cell.site.y+10 );
    console.log( city.name )
    console.log( this.xoffset+" "+this.xmultiplier+" "+city.cell.site.x+" ="+(   this.xoffset+this.xmultiplier*city.cell.site.x) )
    console.log( this.yoffset+" "+this.ymultiplier+" "+city.cell.site.y+" ="+(   this.yoffset+this.ymultiplier*city.cell.site.y) )
    console.log( city.cell.site.x )

}
/* ========================================================================= */ 
/*  redraw what this should look like on a given canvas 
/*  
/* ========================================================================= */ 
 
WorldMap.prototype.redraw = function(canvas,scale){
    if (scale !=undefined){
        this.setMultiplier(scale)
    }
    this.paintBackground(canvas,'#ffffff');
    this.paintMap(canvas)
    this.drawRegions(canvas,true); 
    this.drawCities(canvas);
    var citybox=this.cities[this.currentCityId].box
    
    this.drawbox( citybox,  canvas,'rgba(255,0,255,1)'  )
    this.setMultiplier(1)
//ype.setbox = function(box, va, vb){
} 

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.drawTexture = function(canvas){
    var c = canvas.getContext('2d');

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

WorldMap.prototype.assignCities = function(){
    for (var cityid=0 ; cityid<this.cities.length ; cityid++){
        var city=this.cities[cityid];
        var cityregionID=Math.floor(   (city.seed%100)/10  );

        var cellcount=this.regions[cityregionID].cells.length;

        var randomCellID=Math.floor( Math.random()*cellcount  )
        city.cell=this.regions[cityregionID].cells[randomCellID]

        var corners=[]
        for (var i=0; i<city.cell.corners.length ; i++){
            corners.push(i);
        }
        city.color="rgba(0,0,0,.2)"
        if (  this.seed == city.seed  ){
            city.color="rgba(250,0,0,1)"
            this.currentcitycell=city.cell
        } else if ( this.currentRegionId == cityregionID ){
            city.color="rgba(0,0,0,.5)"

        }

        var cornerIDa =Math.floor(Math.random()*corners.length)
        var va=city.cell.corners[ corners.splice( cornerIDa ,1)[0]];
        var cornerIDb =Math.floor(Math.random()*corners.length)
        var vb=city.cell.corners[ corners.splice( cornerIDb ,1)[0]];
        var cornerIDc =Math.floor(Math.random()*corners.length)
        var vc=city.cell.corners[ corners.splice( cornerIDc ,1)[0]];

        city.point=this.triangulatePosition(va,vb,vc);
        city.box={  minx:city.point.x-36,
                    maxx:city.point.x+36, 
                    miny:city.point.y-30,
                    maxy:city.point.y+30}
        //kingdom.cities.push(city)
        this.cities[cityid]=city
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.drawCities = function(canvas){
    for (var cityid=0 ; cityid<this.cities.length ; cityid++){
        var city=this.cities[cityid]
        this.paintDot(canvas,city.point.x,city.point.y,1,city.color);
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.paintMap = function(canvas){
    for (var i=0; i < this.diagram.cells.length ; i++ ){
        this.colorPolygon(this.diagram.cells[i],canvas,'biomes');
    }
    this.drawRivers(canvas);
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.assignRegions = function(){
    for (var i=0 ; i<this.regions.length ; i++){
        var region=this.regions[i]
        region.id=i
        region.color='rgba('+this.colors[i]+',.3)'

        Math.seedrandom( region.seed   ) ;
        region.capital=this.randomLand();
        while ( region.capital.region ){ // If this cell is already part of a kingdom, choose another
            region.capital=this.randomLand();
        }

        region = this.getRegion( region);
        this.boxRegion(region)
        region.area=this.sumLandArea(region.cells);
        region.center=this.calculateCenter(region);
        this.regions[i]=region
    }
    
}
WorldMap.prototype.calculateCenter = function(region){
    var x=0
    var y=0
    for (var i=0; i<region.outline.length; i++){
        var vertex= region.outline[i];
        x+=vertex.x
        y+=vertex.y
    }
    return {x:x/region.outline.length, y:y/region.outline.length}

}
/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.drawRegions = function(canvas, fill){
    for (var i=0 ; i<10 ; i++){
        this.drawRegion(this.regions[i],canvas, fill)
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.drawRegion = function(region,canvas, fill){
    var polyline = canvas.getContext('2d');
    polyline.beginPath();
    for (var i=0; i<region.outline.length; i++){
        var vertex= region.outline[i];
        polyline.lineTo(this.xoffset+this.xmultiplier*vertex.x,this.yoffset+this.ymultiplier*vertex.y);
    }
    polyline.lineWidth=1;
    polyline.strokeStyle="rgba(0,0,0,1)";
    polyline.fillStyle=region.color;
    polyline.lineCap = 'butt';
    polyline.closePath();
    polyline.stroke();
    if (fill){
        polyline.fill();
    }
    polyline.fillStyle="rgba(0,0,0,"+(1/this.xmultiplier*4)+")";
    polyline.font = "bold "+(this.xmultiplier*3+9  )+"px Arial" ;

    var nameoffset= region.name.length*(this.xmultiplier*3+9)/4
    polyline.fillText(region.name, this.xoffset+this.xmultiplier*region.center.x-nameoffset, this.yoffset+this.ymultiplier*region.center.y);
}
/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.boxRegion = function(region){
    region.box={ minx:100000, miny:100000, maxx:0, maxy:0}
    var fullcellIDs=[];
    //figure out the box for the kingdom an
    for (var k=0; k < region.cells.length ; k++ ){ 
        var cell=region.cells[k];
        fullcellIDs.push(cell.site.voronoiId);
        //check both centers and edges
        for (var j=0; j < cell.halfedges.length ; j++ ){ 
            var he=cell.halfedges[j].edge;
            if (he.rSite != null && fullcellIDs.indexOf(he.rSite.voronoiId) ==-1){fullcellIDs.push(he.rSite.voronoiId);}
            if (he.lSite != null && fullcellIDs.indexOf(he.lSite.voronoiId) ==-1){fullcellIDs.push(he.lSite.voronoiId);}
            region.box=this.setbox(region.box,he.va,he.vb)
        }
    }
    region.regionbox={ minx:100000, miny:100000, maxx:0, maxy:0}
    region.regions=[];
    for (var k=0; k < fullcellIDs.length ; k++ ){ 
        var cell=this.diagram.cells[fullcellIDs[k]];
        region.regions.push(cell);
        for (var j=0; j < cell.halfedges.length ; j++ ){ 
            var he=cell.halfedges[j];
            region.regionbox=this.setbox(region.regionbox,he.edge.va,he.edge.vb)
        }
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.setbox = function(box, va, vb){
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

WorldMap.prototype.drawbox = function(box,canvas,color){
    var polyline = canvas.getContext('2d');
    polyline.beginPath();
    polyline.lineTo(this.xoffset+this.xmultiplier*box.minx,this.yoffset+this.ymultiplier*box.miny);          
    polyline.lineTo(this.xoffset+this.xmultiplier*box.maxx,this.yoffset+this.ymultiplier*box.miny);
    polyline.lineTo(this.xoffset+this.xmultiplier*box.maxx,this.yoffset+this.ymultiplier*box.maxy);
    polyline.lineTo(this.xoffset+this.xmultiplier*box.minx,this.yoffset+this.ymultiplier*box.maxy);
    polyline.closePath();
    polyline.lineWidth=2;
    polyline.strokeStyle=color;
    polyline.lineCap = 'butt';
    polyline.stroke();

}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.getRegion = function(region){
    region.cells=[region.capital];

    for (var i=0; i<this.maxregion; i++){
        // Select a random cell from the region.cells list
        var parentCell= region.cells[  Math.floor( Math.random()*region.cells.length) ];

        // select a random side from our parent cell
        var side=parentCell.halfedges[ Math.floor( Math.random()*parentCell.halfedges.length)  ].edge;

        var cells=this.diagram.cells;

        if ( side.lSite != null &&  side.rSite != null ) {
            var target;
            if (region.cells.indexOf(cells[side.lSite.voronoiId]) == -1) {
                // if lSite isn't in the list, it's our target
                target=cells[side.lSite.voronoiId]
            } else if (region.cells.indexOf(cells[side.rSite.voronoiId]) == -1) {
                // if rSite isn't in the list, it's our target
                target=cells[side.rSite.voronoiId]
            }
            if ( ! target.ocean && ! target.region){
                target.region=true
                region.cells.push(target);
            }
        }

    }
    region=this.getRegionPolygon(region);
    return region;
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

// Determine if halfedge has a side that is not in the region list
WorldMap.prototype.isRegionEdge = function(ids,halfedge){
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

WorldMap.prototype.getRegionPolygon = function(region){
    // Get a list of all IDs for the region
    var ids=[]
    for (var i=0; i < region.cells.length ; i++ ){ ids.push(region.cells[i].site.voronoiId)}
    //Get a list of all external edges
    var edges=[];
    for (var i=0; i < region.cells.length ; i++ ){
        var cell=region.cells[i];
        for (var j=0; j < cell.halfedges.length ; j++ ){
            var he=cell.halfedges[j];
            if (  this.isRegionEdge(ids,he) ){
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
 
    region.outline=[pos];
    var maxfail=edges.length;
    while(edges.length >0){
        var testedge=edges.pop()
        if (testedge.edge.va == pos ){
                pos=testedge.edge.vb; 
                region.outline.push(pos);
                maxfail=edges.length;
        }else if (testedge.edge.vb == pos ){
                pos=testedge.edge.va; 
                region.outline.push(pos);
                maxfail=edges.length;
        }else{
            maxfail--;
            if (maxfail== 0){
                break;
            }
            edges.unshift(testedge);
        }
    }
    return region;
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.randomLand = function(){
    var randomcell=null;
    while ( randomcell ==null){
        var cell=this.diagram.cells[ Math.floor(  Math.random()*this.diagram.cells.length  )   ];
        if (! cell.ocean && ! cell.region && (cell.river || cell.lake || Math.random() >.5) ){
            randomcell=cell;
        }

    }
    return randomcell;    
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.assignRivers = function(){
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        if (! cell.ocean  && cell.river==false && cell.moisture > .5 && Math.random() > .9){
            this.setRiver(cell);
        }
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.setRiver = function(cell){
    cell.river=true;
    if ( !cell.ocean && cell.downslope.site != cell.site  ){
        this.setRiver(cell.downslope);
    }else if (cell.downslope == cell ){
        cell.lake=true;
    }

}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.assignDownslopes = function(){
    for (cellid in this.diagram.cells){
        var cell   = this.diagram.cells[cellid];
        this.setDownslope(cell);
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.getNeighbors = function(cell){
    var neighborIDs = cell.getNeighborIDs();
    var neighbors=[];
    for (var i=0; i<neighborIDs.length; i++){
        neighbors.push(this.diagram.cells[neighborIDs[i]]);
    }
    return neighbors;
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

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




/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.drawRivers = function(canvas){

    for (var i=0; i<this.diagram.cells.length; i++){
        var ctx = canvas.getContext('2d');
        var cell=this.diagram.cells[i];
        if ( cell.river ){
            ctx.strokeStyle='rgba(128,128,255,0.5)';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(this.xoffset+this.xmultiplier*cell.site.x,          this.yoffset+this.ymultiplier*cell.site.y);
            ctx.lineTo(this.xoffset+this.xmultiplier*cell.downslope.site.x,this.yoffset+this.ymultiplier*cell.downslope.site.y);
            ctx.closePath();
            ctx.stroke();
        }
        if ( cell.lake){
            this.colorPolygon(cell,canvas,'highlight','rgba(128,128,255,0.5)');
        }
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.drawDownslopes = function(canvas){
    var ctx = canvas.getContext('2d');

    for (var i=0; i<this.diagram.cells.length; i++){
        var cell=this.diagram.cells[i];
        if ( ! cell.ocean && cell.site != cell.downslope.site ){
            ctx.lineCap = 'round';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(this.xoffset+this.xmultiplier*cell.site.x,           this.yoffset+this.ymultiplier*cell.site.y);
            ctx.lineTo(this.xoffset+this.xmultiplier*cell.downslope.site.x, this.yoffset+this.ymultiplier*cell.downslope.site.y);
            ctx.stroke();
        } else if ( ! cell.ocean && cell.site == cell.downslope.site){
            ctx.lineCap = 'round';
            ctx.lineWidth = 5;
            ctx.beginPath();
            ctx.lineTo(this.xoffset+this.xmultiplier*cell.site.x,    this.yoffset+this.ymultiplier*cell.site.y);
            ctx.lineTo(this.xoffset+this.xmultiplier*(cell.site.x+3),this.yoffset+this.ymultiplier*(cell.site.y+3));
            ctx.stroke();
        }
    }
}


/* ========================================================================= */
/*  assignMoisture for each cell, assign moisture which is a
/*  combination of elevation and simplex noise
/* ========================================================================= */

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


/* ========================================================================= */
/*  assignTerrain using elevation and moisture, set the proper
/*  terrain for each cell.
/* ========================================================================= */

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


/* ========================================================================= */
/*  getTerrain Given an elevation and moisture, select the proper terrain type
/* 
/* ========================================================================= */

WorldMap.prototype.getTerrain = function(elevation,moisture) {
    var terrain=[ //This is a very ugly hack.
            ['Subtropical Desert','Grassland','Tropical Seasonal Forest','Tropical Seasonal Forest','Tropical Rain Forest','Tropical Rain Forest'],
            ['Temperate Desert','Grassland','Grassland','Temperate Deciduous Forest','Temperate Deciduous Forest','Temperate Rain Forest'],
            ['Temperate Desert','Temperate Desert','Shrubland','Shrubland','Taiga','Taiga'],
            ['Scorched','Bare','Tundra','Snow','Snow','Snow'],
            ];
    var pelevation=Math.floor((elevation)*3 ); 
    var pmoisture=Math.floor((moisture)*5);
    return terrain[pelevation][pmoisture];
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.getTerrainColor = function(tname) {
    return this.terrain[tname].color;
}


/* ========================================================================= */
/*  assignElevations for each cell, assign an elevation which is a
/*  combination of radial distance from the center and simplex noise
/* ========================================================================= */
WorldMap.prototype.assignElevations = function() {
    var sim = new SimplexNoise() ;
    //TODO refactor this method
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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

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


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.getOceanColor = function(obj){
    var c= parseInt(Math.floor((obj.elevation)*128));
    return 'rgb(' + c + "," + c + ", 255)";
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

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
        polyfill.lineTo(this.xoffset+this.xmultiplier*vertexa.x,this.yoffset+this.ymultiplier*vertexa.y);
        var vertexb=cell.halfedges[i].getEndpoint();
        polyfill.lineTo(this.xoffset+this.xmultiplier*vertexb.x,this.yoffset+this.ymultiplier*vertexb.y);
    }
    //close the path and fill it in with the provided color
    polyfill.closePath();
    polyfill.fill();
    if (!noborder){
        polyfill.stroke();
    }
}


