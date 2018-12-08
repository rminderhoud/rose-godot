tool
extends Reference


enum BlockType {
    MapInfo = 0,
    MapObject = 1,
    Npc = 2,
    Building = 3,
    Sound = 4,
    Effect = 5,
    MapAnimation = 6,
    WaterPatch = 7,
    MonsterSpawn = 8,
    WaterPlane = 9,
    WarpPoint = 10,
    MapCollisionObject = 11,
    EventObject = 12,
}

class Block:
    var name = null
    var warp_id = null
    var event_id = null
    var object_type = null
    var object_id = null
    var map_position = null
    var position = null
    var rotation = null
    var scale = null
    
    func _init():
        self.name = ""
        self.warp_id = -1
        self.event_id = -1
        self.object_type = -1
        self.object_id = -1
        self.map_position = Vector2(0, 0)
        self.position = Vector3(0, 0, 0)
        self.rotation = Quat(0, 0, 0, 1)
        self.scale = Vector3(0, 0, 0)
        
    func read(f):
        self.read_base(f)
        self.read_extra(f)
        
    func read_base(f):
        self.name = f.get_string_u8()
        self.warp_id = f.get_16()
        self.event_id = f.get_16()
        self.object_type = f.get_32()
        self.object_id = f.get_32()
        self.map_position = f.get_vector2_i32()
        self.rotation = f.get_quat()
        self.position = f.get_vector3_f32()
        self.scale = f.get_vector3_f32()
    
    func read_extra(f):
        pass

class MapObject extends Block:
    func read_extra(f):
        pass

class Npc extends Block:
    var ai = null
    var con = null
    
    func _init():
        self.ai = -1
        self.con = ""
        ._init()
    
    func read_extra(f):
        self.ai = f.get_32()
        self.con = f.get_string_u8()
        
class Building extends Block:
    func read_extra(f):
        pass

class Sound extends Block:
    var path = null
    var sound_range = null
    var interval = null
    
    func _init():
        self.path = ""
        self.sound_range = -1
        self.interval = -1
        ._init()
        
    func read_extra(f):
        self.path = f.get_string_u8()
        self.sound_range = f.get_32()
        self.interval = f.get_32()

class Effect extends Block:
    var path = null
    
    func _init():
        self.path = ""
        ._init()
    
    func read_extra(f):
        self.path = f.get_string_u8()

class MapAnimation extends Block:
    func read_extra(f):
        pass

class MonsterSpawn extends Block:
    var spawn_name = null
    var normal_spawns = null
    var tactical_spawns = null
    var interval = null
    var limit = null
    var spawn_range = null
    var tactic_points = null
    
    class MonsterSpawnPoint:
        var name = null
        var monster = null
        var count = null
        
        func _init():
            self.name = ""
            self.monster = ""
            self.count = ""
            
    func _init():
        self.spawn_name = ""
        self.normal_spawns = []
        self.tactical_spawns = []
        self.interval = 0
        self.limit = 0
        self.spawn_range = 0
        self.tactic_points = 0
        ._init()
        
    func read_extra(f):
        self.spawn_name = f.get_string_u8()
        
        var normal_count = f.get_32()
        for i in range(normal_count):
            var spawn = MonsterSpawnPoint.new()
            spawn.name = f.get_string_u8()
            spawn.monster = f.get_32()
            spawn.count = f.get_32()
            self.normal_spawns.append(spawn)
        
        var tactical_count = f.get_32()
        for i in range(tactical_count):
            var spawn = MonsterSpawnPoint.new()
            spawn.name = f.get_string_u8()
            spawn.monster = f.get_32()
            spawn.count = f.get_32()
            self.tactical_spawns.append(spawn)
        
        self.interval = f.get_32()
        self.limit = f.get_32()
        self.spawn_range = f.get_32()
        self.tactic_points = f.get_32()

class WarpPoint extends Block:
    func read_extra(f):
        pass

class MapCollisionObject extends Block:
    func read_extra(f):
        pass
        
class EventObject extends Block:
    var qsd = null
    var lua = null
    
    func _init():
        self.qsd = ""
        self.lua = ""
        ._init()

    func read_extra(f):
        self.qsd = f.get_string_u8()
        self.lua = f.get_string_u8()

class WaterPlane:
    var start = null
    var end = null
    
    func _init():
        self.start = Vector3(0, 0, 0)
        self.end = Vector3(0, 0, 0)
    
    func read(f):
        self.start = f.get_vector3_f32()
        self.end = f.get_vector3_f32()

class WaterPatch:
    var has_water = null
    var height = null
    var type = null
    var id = null
    var reserved = null
    
    func _init():
        self.has_water = false
        self.height = 0
        self.type = -1
        self.id = -1 
        self.reserved = 0
    
    func read(f):
        self.has_water = f.get_bool()
        self.height = f.get_float()
        self.type = f.get_32()
        self.id = f.get_32()
        self.reserved = f.get_32()
         
var map_position = null
var zone_position = null
var world_matrix = null
var name = null
var water_size = null
var water_planes = null
var map_objects = null
var npcs = null
var buildings = null
var sounds = null
var effects = null
var animations = null
var water_patches = null
var monster_spawns = null
var warp_points = null
var collision_objects = null
var event_objects = null

func _init():
    self.map_position = Vector2(0, 0)
    self.zone_position = Vector2(0, 0)
    self.world_matrix = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0]
    ]
    self.name = ""
    self.water_size = 0.0
    self.water_planes = []
    self.map_objects = []
    self.npcs = []
    self.buildings = []
    self.sounds = []
    self.effects = []
    self.animations = []
    self.water_patches = []
    self.monster_spawns = []
    self.warp_points = []
    self.collision_objects = []
    self.event_objects = []
    
func read(f):
    var block_count = f.get_32()
    var block_offsets = []
    
    for i in range(block_count):
        var header = {}
        header["type"] = f.get_32()
        header["offset"] = f.get_32()
        block_offsets.append(header)
    
    for header in block_offsets:
        var block_type = header["type"]
        var block_offset = header["offset"]
        
        f.seek(block_offset)
        
        match block_type:
            BlockType.MapInfo:
                self.map_position = f.get_vector2_i32()
                self.zone_position = f.get_vector2_i32()
                self.world_matrix = f.get_matrix4()
                self.name = f.get_string_u8()
            BlockType.WaterPatch:
                var width = f.get_32()
                var height = f.get_32()
                
                for h in range(height):
                    var row = []
                    for w in range(width):
                        var water_patch = WaterPatch.new()
                        water_patch.read(f)
                        row.append(water_patch)
                    self.water_patches.append(row)
                    
            BlockType.WaterPlane:
                self.water_size = f.get_float()
        
        #TODO: Loop for entries for the specific blocks
        var entry_count = f.get_32()
        for i in range(entry_count):
            match block_type:
                BlockType.MapObject:
                    var map_object = MapObject.new()
                    map_object.read(f)
                    self.map_objects.append(map_object)
                BlockType.Npc:
                    var npc = Npc.new()
                    npc.read(f)
                    self.npcs.append(npc)
                BlockType.Building:
                    var building = Building.new()
                    building.read(f)
                    self.buildings.append(building)
                BlockType.Sound:
                    var sound = Sound.new()
                    sound.read(f)
                    self.sounds.append(sound)
                BlockType.Effect:
                    var effect = Effect.new()
                    effect.read(f)
                    self.effects.append(effect)
                BlockType.MapAnimation:
                    var map_animation = MapAnimation.new()
                    map_animation.read(f)
                    self.animations.append(map_animation)
                BlockType.MonsterSpawn:
                    var monster_spawn = MonsterSpawn.new()
                    monster_spawn.read(f)
                    self.monster_spawns.append(monster_spawn)
                BlockType.WaterPlane:
                    var water_plane = WaterPlane.new()
                    water_plane.read(f)
                    self.water_planes.append(water_plane)
                BlockType.WarpPoint:
                    var warp_point = WarpPoint.new()
                    warp_point.read(f)
                    self.warp_points.append(warp_point)
                BlockType.MapCollisionObject:
                    var collision_object = MapCollisionObject.new()
                    collision_object.read(f)
                    self.collision_objects.append(collision_object)
                BlockType.EventObject:
                    var event_object = EventObject.new()
                    event_object.read(f)
                    self.event_objects.append(event_object)
