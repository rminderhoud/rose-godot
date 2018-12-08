tool
extends Reference


class Tile:
    var brush_id = null
    var tile_idx = null
    var tile_set = null
    var tile_id = null
    
    func _init():
        self.brush_id = -1
        self.tile_id = -1
        self.tile_set = -1
        self.tile_id = -1
        
var width = null
var height = null
var tiles = null

func _init():
    self.width = 0
    self.height = 0
    self.tiles = []
    
func read(f):
    self.width = f.get_32()
    self.height = f.get_32()
    
    for h in range(self.height):
        var row = []
        for w in range(self.width):
            var t = Tile.new()
            t.brush_id = f.get_8()
            t.tile_idx = f.get_8()
            t.tile_set = f.get_8()
            t.tile_id = f.get_32()
            row.append(t)
        self.tiles.append(row)
