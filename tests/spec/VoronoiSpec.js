

describe("Voronoi", function() {

    var voronoi;
    var diagram;
    beforeEach(function() {
        voronoi=new Voronoi();
    });




    it("should have no cells when created", function() {
        expect(voronoi.cells.length).toBe(0);
    });

    describe("when computing a simple set, the diagram", function() {
        var bbox={xl:0,xr:100,yt:0,yb:100 };
        var points=[
            {x:5, y:10 },
            {x:20, y:20 },
            {x:30, y:80 },
            {x:50, y:50 },
            {x:80, y:30 },
            {x:10, y:10 },
            {x:90, y:20 },
            {x:40, y:70 },
            {x:5, y:50 },
            {x:80, y:20 },
        ];
        beforeEach(function() {
            diagram=voronoi.compute(points, bbox);
        });
        it("should have 10 cells ", function() {
            expect(diagram.cells.length).toBe(points.length);
        });
        it("should have 31 edges ", function() {
            expect(diagram.edges.length).toBe(31);
        });
	    describe("Cell 0", function() {
            var cell;
            beforeEach(function() {
                cell=diagram.cells[0];
            });
	        it("should have a known area ", function() {
	            expect(cell.area).toBe(206.25);
	        });
	        it("should be a border ", function() {
	            expect(diagram.cells[0].border).toBe(true);
	        });
	        it("should have 3 corners ", function() {
	            expect(diagram.cells[0].corners.length).toBe(3);
	        });
	        it("should have site coordinates of 5,10 ", function() {
	            expect(diagram.cells[0].site.x).toBe(5);
	            expect(diagram.cells[0].site.y).toBe(10);
	        });
	        describe("halfedge 0", function() {
                var halfedge;
                var edge;
                beforeEach(function() {
                    halfedge=cell.halfedges[0]
                    edge=halfedge.edge
                });
    	        it("has a known angle", function() {
    	            expect(halfedge.angle).toBe(1.5707963267948966);
    	        });
    	        it("has an lSite of 5,50, voronoiID 6", function() {
    	            expect(edge.lSite.x).toBe(5);
    	            expect(edge.lSite.y).toBe(50);
    	            expect(edge.lSite.voronoiId).toBe(6);
    	        });
    	        it("has an rSite of 5,10, voronoiID 0", function() {
    	            expect(edge.rSite.x).toBe(5);
    	            expect(edge.rSite.y).toBe(10);
    	            expect(edge.rSite.voronoiId).toBe(0);
    	        });
    	        it("come from site 5,10, voronoiId 0", function() {
    	            expect(halfedge.site.x).toBe(5);
    	            expect(halfedge.site.y).toBe(10);
    	            expect(halfedge.site.voronoiId).toBe(0);
    	        });
    	        it("should have a va located at 2.5,30", function() {
    	            expect(edge.va.x).toBe(2.5);
    	            expect(edge.va.y).toBe(30);
    	        });
    	        it("should have a vb located at 0,30", function() {
    	            expect(edge.vb.x).toBe(0);
    	            expect(edge.vb.y).toBe(30);
    	        });
	        });
	    });
	    describe("Cell 7", function() {
	        it("should not be a border ", function() {
	            expect(diagram.cells[7].border).toBe(false);
	        });
	        it("should have 3 corners ", function() {
	            expect(diagram.cells[7].corners.length).toBe(5);
	        });
	        it("should have 5 halfedges ", function() {
	            expect(diagram.cells[7].halfedges.length).toBe(5);
	        });
	        it("should have a voronoiId ", function() {
	            expect(diagram.cells[7].site.voronoiId).toBe(7);
	        });
	        it("should have site coordinates of 50,50 ", function() {
	            expect(diagram.cells[7].site.x).toBe(50);
	            expect(diagram.cells[7].site.y).toBe(50);
	        });
	
	    });

    });


});
