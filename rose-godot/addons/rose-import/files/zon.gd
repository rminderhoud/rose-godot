tool
extends Reference


enum ZoneType {
    Grass = 0,
    Mountain = 1,
    MountainVillage = 2,
    BoatVillage = 3,
    Login = 4,
    MountainGorge = 5,
    Beach = 6,
    JunonDungeon = 7,
    LunaSnow = 8,
    Birth = 9,
    JunonField = 10,
    LunaDungeon = 11,
    EldeonField = 12,
    EldeonField2 = 13,
    JunonPyramids = 14,
}

enum ZoneBlockType {
    BasicInfo = 0,
    EventPoints = 1,
    Textures = 2,
    Tiles = 3,
    Economy = 4,
}

enum ZoneTileRotation {
    Unkown = 0,
    None = 1,
    FlipHorizontal = 2,
    FlipVertical = 3,
    Flip = 4,
    Clockwise90 = 5,
    CounterClockwise90 = 6,
}

class ZonePosition:
    var position = null
    var is_used = null
    
    func _init():
        self.position = Vector2(0.0, 0.0)
        self.is_used = false

class ZoneEventPoint:
    var position = null
    var name = null
    
    func _init():
        self.position = Vector3(0.0, 0.0, 0.0)
        self.name = ""

class ZoneTile :
    var layer1 = null
    var layer2 = null
    var offset1 = null
    var offset2 = null
    var blend = null
    var rotation = null
    var tile_type = null

    func _init():
        self.layer1 = -1
        self.layer2 = -1
        self.offset1 = -1
        self.offset2 = -1
        self.blend = false
        self.rotation = ZoneTileRotation.None
        self.tile_type = -1
        

var zone_type = null
var width= null
var height= null
var grid_count= null
var grid_size= null
var start_position = null
var positions = null
var event_points = null
var textures = null
var tiles = null
var name = null
var is_underground = null
var background_music= null
var sky= null
var economy_tick_rate= null
var population_base= null
var population_growth_rate= null
var metal_consumption= null
var stone_consumption= null
var wood_consumption= null
var leather_consumption= null
var cloth_consumption= null
var alchemy_consumption= null
var chemical_consumption= null
var medicine_consumption= null
var food_consumption= null

func _init():
     self.zone_type = ZoneType.Grass
     self.width = 0
     self.height= 0
     self.grid_count = 0
     self.grid_size = 0.0
     self.start_position = Vector2(0, 0)
     self.positions = []
     self.event_points = []
     self.textures = []
     self.tiles = []
     self.name = ""
     self.is_underground = false
     self.background_music = ""
     self.sky= ""
     self.economy_tick_rate = 0
     self.population_base = 0
     self.population_growth_rate = 0
     self.metal_consumption = 0
     self.stone_consumption = 0
     self.wood_consumption = 0
     self.leather_consumption = 0
     self.cloth_consumption= 0
     self.alchemy_consumption= 0
     self.chemical_consumption= 0
     self.medicine_consumption= 0
     self.food_consumption= 0

func read(f):
    var block_count = f.get_32()
    
    var blocks = []
    for i in range(block_count):
        var block_type = f.get_32()
        var offset = f.get_32()
        blocks.append([block_type, offset])
        
    for block_data in blocks:
        var block_type = block_data[0]
        var block_offset = block_data[1]
        
        f.seek(block_offset)
        
        match block_type:
            ZoneBlockType.BasicInfo:
                self.zone_type = f.get_32()
                self.width = f.get_32()
                self.height = f.get_32()
                self.grid_size = f.get_float()
                self.start_position = f.get_vector2_i32()
                
                for h in range(self.height):
                    var row = []
                    for w in range(self.width):
                        row.append(ZonePosition.new())
                    self.positions.append(row)
                
                for w in range(self.width):
                    for h in range(self.width):
                        self.positions[h][w].is_used = (f.get_8() == 1)
                        self.positions[h][w].position = f.get_vector2_f32()
            
            ZoneBlockType.EventPoints:
                var count = f.get_32()
                for i in range(count):
                    var p = ZoneEventPoint.new()
                    p.position = f.get_vector3_f32()
                    p.name = f.get_string_u8()
                    self.event_points.append(p)
            
            ZoneBlockType.Textures:
                var count = f.get_32()
                for i in range(count):
                    self.textures.append(f.get_string_u8())
                    
            ZoneBlockType.Tiles:
                var count = f.get_32()
                for i in range(count):
                    var t = ZoneTile.new()
                    t.layer1 = f.get_32()
                    t.layer2 = f.get_32()
                    t.offset1 = f.get_32()
                    t.offset2 = f.get_32()
                    t.blend = (f.get_32() == 1)
                    t.rotation = f.get_32()
                    t.tile_type  = f.get_32()
                    self.tiles.append(t)
            
            ZoneBlockType.Economy:
                self.name = f.get_string_u8()
                self.is_underground = (f.get_32() == 1)
                self.background_music = f.get_string_u8()
                self.sky = f.get_string_u8()
                self.economy_tick_rate = f.get_32()
                self.population_base = f.get_32()
                self.population_growth_rate = f.get_32()
                self.metal_consumption = f.get_32()
                self.stone_consumption = f.get_32()
                self.wood_consumption = f.get_32()
                self.leather_consumption = f.get_32()
                self.cloth_consumption= f.get_32()
                self.alchemy_consumption= f.get_32()
                self.chemical_consumption= f.get_32()
                self.medicine_consumption= f.get_32()
                self.food_consumption = f.get_32()
