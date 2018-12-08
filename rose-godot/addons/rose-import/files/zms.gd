tool
extends Reference

enum {
    POSITION = 1 << 1,
    NORMAL = 1 << 2,
    COLOR = 1 << 3,
    BONE_WEIGHT = 1 << 4,
    BONE_INDEX = 1 << 5,
    TANGENT = 1 << 6,
    UV1 = 1 << 7,
    UV2 = 1 << 8,
    UV3 = 1 << 9,
    UV4 = 1 << 10,
}

class Vertex :
    extends Reference
    
    var position = null
    var normal = null
    var color = null
    var bone_weights = null
    var bone_indices = null
    var tangent = null
    var uv1 = null
    var uv2 = null
    var uv3 = null
    var uv4 = null
    
    func _init():
        position = Vector3(0.0, 0.0, 0.0)
        normal = Vector3(0.0, 0.0, 0.0)
        color = Color(0, 0, 0, 0)
        bone_weights = []
        bone_indices = []
        tangent = Vector3(0.0, 0.0, 0.0)
        uv1 = Vector2(0.0, 0.0)
        uv2 = Vector2(0.0, 0.0)
        uv3 = Vector2(0.0, 0.0)
        uv4 = Vector2(0.0, 0.0)
        
var identifier = null
var flags = null
var bounding_box_min = null
var bounding_box_max = null
var bones = null
var vertices = null
var indices = null
var materials = null
var strips = null
var pool = null

func _init():
    identifier = ""
    flags = 0
    bounding_box_min = Vector3(0, 0, 0)
    bounding_box_max = Vector3(0, 0, 0)
    bones = []
    vertices = []
    indices = []
    materials = []
    strips = []
    pool = 0

func positions_enabled():
    return (flags & POSITION) != 0
    
func normals_enabled():
    return (flags & NORMAL) != 0

func colors_enabled():
    return (flags & COLOR) != 0

func bones_enabled():
    return ((flags & BONE_WEIGHT) != 0 && (flags & BONE_INDEX) != 0)

func tangents_enabled():
    return (flags & TANGENT) != 0

func uv1_enabled():
    return (flags & UV1) != 0

func uv2_enabled():
    return (flags & UV2) != 0

func uv3_enabled():
    return (flags & UV3) != 0
    
func uv4_enabled():
    return (flags & UV4) != 0
    
func read(f):
    identifier = f.get_cstring()
    flags = f.get_32()
    bounding_box_min = f.get_vector3_f32()
    bounding_box_max = f.get_vector3_f32()
    
    var bone_count = f.get_16()
    for i in range(bone_count):
        bones.append(f.get_16())
    
    var vert_count = f.get_16()
    for i in range(vert_count):
        vertices.append(Vertex.new())
        
    if positions_enabled():
        for i in range(vert_count):
            vertices[i].position = f.get_vector3_f32()
    
    if normals_enabled():
        for i in range(vert_count):
            vertices[i].normal = f.get_vector3_f32()
    
    if colors_enabled():
        for i in range(vert_count):
            vertices[i].color = f.get_color4()
    
    if bones_enabled():
        for i in range(vert_count):
            vertices[i].bone_weights = f.get_array_f32(4)
            vertices[i].bone_indices = f.get_array_i16(4)
    
    if tangents_enabled():
        for i in range(vert_count):
            vertices[i].tangent = f.get_vector3_f32()
    
    if uv1_enabled():
        for i in range(vert_count):
            vertices[i].uv1 = f.get_vector2_f32()
    
    if uv2_enabled():
        for i in range(vert_count):
            vertices[i].uv2 = f.get_vector2_f32()
    
    if uv3_enabled():
        for i in range(vert_count):
            vertices[i].uv3 = f.get_vector2_f32()
    
    if uv4_enabled():
        for i in range(vert_count):
            vertices[i].uv4 = f.get_vector2_f32()
    
    var index_count = f.get_16()
    for i in range(index_count):
        indices.append(f.get_vector3_i16())
    
    var material_count = f.get_16()
    for i in range(material_count):
        materials.append(f.get_16())
    
    var strip_count = f.get_16()
    for i in range(strip_count):
        strips.append(f.get_16())
    
    if identifier == "ZMS0008":
        pool = f.get_16()
