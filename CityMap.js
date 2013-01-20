
/* ========================================================================= */
/* CityMap is the base object for generating the city map. 
/* TODO This should be abstracted out with WorldMap
/* ========================================================================= */
CityMap.prototype = Object.create(VoronoiMap.prototype);
CityMap.prototype.constructor = CityMap;

function  CityMap(width,height,num_points,params,color) {
    VoronoiMap.call(this,width,height,num_points)
    this.isport=params.isport
    this.coastdirection=params.coastdirection
    this.wallheight=params.wallheight
    this.roads=params.roads
    this.mainroads=params.mainroads
    this.color=color
}







/* ========================================================================= */
/* designateCity takes a canvas and a cell count and builds an array
/* of cells around the center of the canvas.
/* ========================================================================= */

CityMap.prototype.designateCity = function(canvas,citycellcount){
    this.citycells=[]
    for (var i = 0; i < Math.floor( citycellcount) ; i++) {
        this.citycells.push(this.findCenterCell(canvas))
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

CityMap.prototype.redraw = function(canvas){
    // From here, draw out all the parts we designated above.
    this.paintBackground(canvas,this.color);
//    this.drawCoast(canvas, this.isport, this.coastdirection)
    this.paintCells(canvas,this.citycells,'rgba(255,255,255,1)',true)

    this.drawCityWalls(canvas,  Math.ceil(this.wallheight/10)   )

//    this.render(canvas)
    this.drawRoads(canvas, this.roads, this.mainroads)

    // rainbows and unicorn farts go here.
}




/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

CityMap.prototype.generateDistricts = function(districts){
    // rainbows and unicorn farts go here.
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

CityMap.prototype.drawCoast = function(canvas, isport, coastdirection){
    if ( isport ){
        var percentwater= ( 25 + Math.round(Math.random()*15))/100;
        var water=[];
        console.log(this.diagram)
        var targetcount=Math.round( this.diagram.cells.length * percentwater ) -this.citycells.length/2
        while (water.length< targetcount){
    
            var target={site:{  x:canvas.width/2,  y:canvas.height/2 } }
            var target=this.findCenterCell(canvas)
    
            for (var i=0 ; i< this.diagram.cells.length; i++){
                var cell=this.diagram.cells[i]
                var tweak=Math.random()*30
                if ( ! cell.incity && ! cell.water){
                    if ( coastdirection=='north' && cell.site.y+tweak < target.site.y ){
                        target=cell;
                    }else if ( coastdirection =='south' && cell.site.y+tweak > target.site.y ){
                        target=cell;
                    }else if ( coastdirection =='east'  && cell.site.x+tweak > target.site.x ){
                        target=cell;
                    }else if ( coastdirection =='west'  && cell.site.x+tweak < target.site.x ){
                        target=cell;
                    } else if ( coastdirection=='northeast' && cell.site.y+tweak < target.site.y && cell.site.x+tweak > target.site.x  ){
                        target=cell;
                    }else if ( coastdirection =='southeast' && cell.site.y+tweak > target.site.y && cell.site.x+tweak > target.site.x  ){
                        target=cell;
                    }else if ( coastdirection =='northwest' && cell.site.y+tweak < target.site.y && cell.site.x+tweak < target.site.x  ){
                        target=cell;
                    }else if ( coastdirection =='southwest' && cell.site.y+tweak > target.site.y && cell.site.x+tweak < target.site.x  ){
                        target=cell;
                    }
                }
            }
            if (target == null){
                console.log('target was null, no idea why; reduce our goal to prevent infinite loops if things are bad.')
                targetcount-- // something is wrong if this happens
            }else{
                target.water=true
                water.push(target)
            }
        }
        for (var i=0 ; i< water.length; i++){
            this.paintCell( canvas, water[i] ,'rgba(55,55,222,1)', true );
        }
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

CityMap.prototype.findCenterCell = function(canvas){

    var centerx = canvas.width/2;
    var centery = canvas.height/2;

    var closestpoint;
    var shortestradius=10000;

    for (var i=0; i<this.diagram.cells.length; i++) {
        var cell=this.diagram.cells[i];
        var x = cell.site.x
        var y = cell.site.y

        var adjustedx=x-centerx + (Math.random()*x - x/2)/4 ;
        var adjustedy=y-centery + (Math.random()*y - y/2)/4 ;
        var radius=  Math.sqrt( Math.pow(adjustedx,2) + Math.pow(adjustedy,2));
        if (!cell.incity && !cell.inwater &&    shortestradius> radius ){
            shortestradius=radius
            closestpoint=cell
        }
    }
    closestpoint.incity=true
    return closestpoint
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

CityMap.prototype.drawRoads = function(canvas,roads,mainroads){
    var corners=[]
    // TODO change this loop to randomly push corners on so
    // that a single road is not always going west.
    for(var i=0; i<this.outline.length; i++){
        corners.push(this.outline[i])
    }
    var roadwidth=3

    for (var i=0; i<roads; i++){
        if (mainroads-->0){
            roadwidth=6
        }else{
            roadwidth=3
        }
        var va= corners[    Math.floor(i/roads*corners.length)     ]
        this.drawRoad(canvas,va,roadwidth);
    }
}


/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

CityMap.prototype.drawRoad = function(canvas,va,roadwidth){
    var road=[va]
    var loop=30

    var focus;
    var minx=Math.min(va.x,this.width-va.x);
    var miny=Math.min(va.y,this.height-va.y);

    var targetva=null
    var candidatecells=[]
    var cells=this.diagram.cells
    var isdry=true



    if (minx/this.width < miny/this.height){ // X is closer than Y
                console.log('refactorin the road')
        if ( minx == va.x ) {
            while (va.x >0 && isdry ){ //bear west
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate

                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    if (candidatecells[i].water){
                        isdry=false
                        console.log('you hit water!')
                        break
                    }
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.x < va.x){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                    road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.x < va.x){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }else{
            while (va.x <this.width && isdry ){//bear east
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate
                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    if (candidatecells[i].water){
                        isdry=false
                        console.log('you hit water!')
                        break
                    }
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.x > va.x){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.x > va.x){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }
    }else{    
        if ( miny == va.y ) {
            while (va.y >0 && isdry ){ // bear north
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate

                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    if (candidatecells[i].water){
                        isdry=false
                        console.log('you hit water!')
                        break
                    }
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.y < va.y){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.y < va.y){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }else{
            while (va.y <this.height && isdry ){//bear south
                for (var i=0; i < cells.length; i++){
                    if ( cells[i].corners.indexOf(va) != -1   ){// va is found on this cell, make it a candidate
                        candidatecells.push(cells[i])
                    }
                }
                for (var i=0; i < candidatecells.length; i++){
                    if (candidatecells[i].water){
                        isdry=false
                        console.log('you hit water!')
                        break
                    }
                    for (var j=0; j < candidatecells[i].halfedges.length; j++){
                        var edge=candidatecells[i].halfedges[j].edge
                        if ( edge.va == va  ){
                            if ( edge.vb.y > va.y){
                                va=edge.vb
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        } else if ( edge.vb ==va  ){
                            if ( edge.va.y > va.y){
                                va=edge.va
                                if (this.outline.indexOf(va) != -1){
                                    road=[]
                                }
                                road.push(va)
                            }
                        }
                    }
                }
            }
        }
    }


    var c = canvas.getContext('2d');
//    c.scale(this.scale,this.scale);


    c.strokeStyle='#5E2605';
    c.lineWidth=roadwidth*this.xmultiplier;
    c.beginPath();
    var originalposition=null
    for (var j=0; j < road.length; j++){
        c.lineTo(this.xoffset+this.xmultiplier*road[j].x, this.yoffset+this.ymultiplier*road[j].y);
    }
    c.lineCap = 'butt';
    c.stroke()
    this.paintDot(canvas, road[0].x, road[0].y, roadwidth/2,'rgba(100,100,100,.9)') // final gateway

}



/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

CityMap.prototype.drawCityWalls = function(canvas,wallsize){
    var polyline = canvas.getContext('2d');
//    polyline.scale(this.scale,this.scale);

    polyline.beginPath();
    for (var i=0; i<this.outline.length; i++){
        var vertex= this.outline[i];
        polyline.lineTo(this.xoffset+this.xmultiplier*vertex.x,this.yoffset+this.ymultiplier*vertex.y);
    }
    polyline.lineWidth=wallsize;
    polyline.strokeStyle="rgba(0,0,0,0.7)";
    polyline.fillStyle=this.color;
    polyline.lineCap = 'butt';
    polyline.stroke();
    //    polyline.fill();
    polyline.closePath();

}


/* ========================================================================= */
/* Determine if halfedge has a side that is not in the kingdom list
/* TODO this should be refactored to be more generic
/* ========================================================================= */

CityMap.prototype.isKingdomEdge = function(ids,halfedge){
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

//TODO refactor with getKingdomPolygon
CityMap.prototype.generateCityWalls = function(){
    var ids=[]
    for (var i=0; i < this.citycells.length ; i++ ){ ids.push(this.citycells[i].site.voronoiId)}
    //Get a list of all external edges
    var edges=[];
    for (var i=0; i < this.citycells.length ; i++ ){
        var cell=this.citycells[i];
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

    this.outline=[pos];
    var maxfail=edges.length;
    while(edges.length >0){
        var testedge=edges.pop()
        if (testedge.edge.va == pos ){
                pos=testedge.edge.vb;
                this.outline.push(pos);
                maxfail=edges.length;
        }else if (testedge.edge.vb == pos ){
                pos=testedge.edge.va;
                this.outline.push(pos);
                maxfail=edges.length;
        }else{
            maxfail--;
            if (maxfail== 0){
                break;
            }
            edges.unshift(testedge);
        }
    }
    return this;
}


