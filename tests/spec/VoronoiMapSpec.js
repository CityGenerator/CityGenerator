

describe("VoronoiMap", function() {

    var voronoimap;

    beforeEach(function() {
        Math.seedrandom(100);
        voronoimap=new VoronoiMap(500,500,1000);
    });

    it("should have a width of 500", function() {
      expect(voronoimap.width).toBe(500);
    });
    it("should have a height of 500", function() {
        expect(voronoimap.height).toBe(500);
    });
    describe("should use setMultiplier", function() {
        it("to have an xmultiplier of 1, then 5, then 7", function() {
            expect(voronoimap.xmultiplier).toBe(1);
            voronoimap.setMultiplier(5)
            expect(voronoimap.xmultiplier).toBe(5);
            voronoimap.setMultiplier(7,1)
            expect(voronoimap.xmultiplier).toBe(7);
        });
        it("to have a ymultiplier of 1, then 5, then 1", function() {
            expect(voronoimap.ymultiplier).toBe(1);
            voronoimap.setMultiplier(5)
            expect(voronoimap.ymultiplier).toBe(5);
            voronoimap.setMultiplier(7,1);                // 7 is set for the x multiplier
            expect(voronoimap.ymultiplier).toBe(1);
        });
    });
    
    it("should have a xoffset and yoffset of 0", function() {
        expect(voronoimap.yoffset).toBe(0);
        expect(voronoimap.xoffset).toBe(0);
    });
    
    it("should have 13 colors", function() {
        expect(voronoimap.colors.length).toBe(13);
        expect(voronoimap.colors[0]).toEqual('255,105,100');
    });
    it("should create a diagram when buildgraph is run", function() {
        voronoimap.diagram=undefined
        expect(voronoimap.diagram).toBe(undefined);
        voronoimap.buildGraph()
        expect(voronoimap.diagram).not.toBe(undefined);
    });
    describe("should generate points", function() {
        var points;
        beforeEach(function() {
            points=voronoimap.generateRandomPoints(100);
        });
        it("should generate 100 points", function() {
            expect(points.length).toBe(100);
        });
        it("should have a known first point", function() {
            expect(points[0].x).toBe(376.6);
            expect(points[0].y).toBe(472.8);
        });
        
    });
    describe("should improve points", function() {
        it("from a known location to a new known location", function() {
            var site=voronoimap.diagram.cells[0].site
            expect(site.x).toBe(196);
            expect(site.y).toBe(3);
            voronoimap.improveRandomPoints();
            site=voronoimap.diagram.cells[0].site
            expect(site.x).toBe(199);
            expect(site.y).toBe(4);
        });
        
    });
    describe("resize the graph", function() {
        it("with cell 10 moving in a known manner", function() {
            expect(voronoimap.diagram.cells[10].site.x).toBe(301);
            expect(voronoimap.diagram.cells[10].site.y).toBe(6);
            voronoimap.resizeGraph(100,100)
            expect(voronoimap.diagram.cells[10].site.x).toBe(69);
            expect(voronoimap.diagram.cells[10].site.y).toBe(1);
        });
    });


});








