/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype = Object.create(VoronoiMap.prototype);
WorldMap.prototype.constructor = WorldMap;

function  WorldMap(params, canvas) {
    params.canvas=canvas;
    var width=params.canvas.width
    var height=params.canvas.height
    this.canvas=params.canvas

    this.seed=params.seed

    VoronoiMap.call(this,params);

    this.bbox= {xl:0,xr:width,yt:0,yb:height}
}

/* ========================================================================= */
/* 
/* 
/* ========================================================================= */

WorldMap.prototype.draw_borders = function(){
    var polyline = this.canvas.getContext('2d');
    polyline.save()
    polyline.strokeStyle='ffffff';
    polyline.fillStyle='00ffff';
    for (var j=0; j < this.diagram.cells.length ; j++ ){
        polyline.beginPath();

        var cell=this.diagram.cells[j];
        for (var i=0; i<cell.halfedges.length; i++) {

            var vertexa=cell.halfedges[i].getStartpoint();
            polyline.lineTo(this.xmultiplier*vertexa.x,this.ymultiplier*vertexa.y);
            var vertexb=cell.halfedges[i].getEndpoint();
            polyline.lineTo(this.xmultiplier*vertexb.x,this.ymultiplier*vertexb.y);
        }
        polyline.closePath();
        polyline.stroke();
        polyline.fill();
    }
    polyline.restore()
}

