tool
extends Reference

enum BlendType {
    None = 0,
    Custom = 1,
    Normal = 2,
    Lighten = 3,
}

enum GlowType {
    None = 0,
    NotSet = 1,
    Simple = 2,
    GlowLight = 3,
    GlowTexture = 4,
    TextureLight = 5,
    Alpha = 6
}

enum Property {
    Position = 1,
    Rotation = 2,
    Scale = 3,
    AxisRotation = 4,
    BoneIndex = 5,
    DummyIndex = 6,
    Parent = 7,
    Animation = 8,
    Collision = 29,
    ConstantAnimation = 30,
    VisibleRangeSet = 31,
    UseLightmap = 32,
}

enum CollisionType {
    None = 0,
    Sphere = 1,
    AxisAlignedBoundingBox = 2,
    OrientedBoundingBox = 3,
    Polygon = 1 << 2,
    NotMoveable = 1 << 3,
    NotPickable = 1 << 4,
    HeightOnly = 1 << 5,
    NoCameraCollision = 1 << 6,
}

enum EffectType {
    Normal = 0,
    Night = 1,
    LightContainer = 2
}

class ZscMaterial:
    var texture = null
    var use_skin_shader = null
    var alpha_enabled = null
    var two_sided = null
    var alpha_tests_enabled = null
    var alpha_reference = null
    var depth_test_enabled = null
    var depth_write_enabled = null
    var blend_type = null
    var use_specular_shader = null
    var alpha = null
    var glow_type = null
    var glow_color = null
    
    func _init():
        self.texture = ""
        self.use_skin_shader = false
        self.alpha_enabled = true
        self.two_sided = false
        self.alpha_tests_enabled = false
        self.alpha_reference = 0
        self.depth_test_enabled = false
        self.depth_write_enabled = false
        self.blend_type = BlendType.None
        self.use_specular_shader = false
        self.alpha = 0
        self.glow_type = GlowType.None
        self.glow_color = Color(0, 0, 0)

class ZscObject:
    class ZscObjectPart:
        var mesh_id = null
        var material_id = null
        var position = null
        var rotation = null
        var scale = null
        var axis_rotation = null
        var parent = null
        var collision = null
        var animation = null
        var visible_range_set = null
        var use_lightmap = null
        var bone_index = null
        var dummy_index = null
        var monster_animations = null
        var avatar_animations = null

        func _init():
            self.mesh_id = -1
            self.material_id = -1
            self.position = Vector3()
            self.rotation = Quat()
            self.scale = Vector3()
            self.axis_rotation = Quat()
            self.parent = -1
            self.collision = CollisionType.None
            self.animation = ""
            self.visible_range_set = -1
            self.use_lightmap = false
            self.bone_index = -1
            self.dummy_index = -1
            self.monster_animations = []
            self.avatar_animations = []

    class ZscObjectEffect:
        var effect_type = null
        var effect = null
        var position = null
        var rotation = null
        var scale = null
        var parent = null

        func _init():
            self.effect_type = EffectType.Normal
            self.effect = -1
            self.position = Vector3()
            self.rotation = Quat()
            self.scale = Vector3()
            self.parent = -1

    # Bounding Cylinder
    var bc_radius = null
    var bc_center = null

    # Bounding Box
    var bb_min = null
    var bb_max = null

    var parts = null
    var effects = null

    func _init():
        self.bc_radius = 0
        self.bc_center = Vector2()
        self.bb_min = Vector2()
        self.bb_max = Vector2()

        self.parts = []
        self.effects = []

var meshes = null
var materials = null
var effects = null
var objects = null

func _init():
    self.meshes = []
    self.materials = []
    self.effects = []
    self.objects = []

func read(f):
    var mesh_count = f.get_16()
    for i in range(mesh_count):
        self.meshes.push_back(f.get_cstring())

    var material_count = f.get_16()
    for i in range(material_count):
        var material = ZscMaterial.new()
        material.texture = f.get_cstring()
        material.use_skin_shader = f.get_16() != 0
        material.alpha_enabled = f.get_16() != 0
        material.two_sided = f.get_16() != 0
        material.alpha_tests_enabled = f.get_16() != 0
        material.alpha_reference = f.get_16()
        material.depth_test_enabled = f.get_16() != 0
        material.depth_write_enabled = f.get_16() != 0
        material.blend_type = f.get_16()
        material.use_specular_shader = f.get_16() != 0
        material.alpha = f.get_float()
        material.glow_type = f.get_16()
        material.glow_color = f.get_color3()
        self.materials.push_back(material)

    var effect_count = f.get_16()
    for i in range(effect_count):
        self.effects.push_back(f.get_cstring())

    var object_count = f.get_16()
    for i in range(object_count):
        var obj = ZscObject.new()
        obj.bc_radius = f.get_32()
        obj.bc_center= f.get_vector2_i32()

        var part_count = f.get_16()
        if part_count > 0:
            for i in range(part_count):
                var part = ZscObject.ZscObjectPart.new()
                part.mesh_id = f.get_16()
                part.material_id = f.get_16()

                var property = f.get_8()
                while(property != 0):
                    var size = f.get_8()

                    match property:
                        Property.Position:
                            part.position = f.get_vector3_f32()
                        Property.Rotation:
                            part.rotation = f.get_quat_wxyz()
                        Property.Scale:
                            part.scale = f.get_vector3_f32()
                        Property.AxisRotation:
                            part.axis_rotation = f.get_quat_wxyz()
                        Property.Parent:
                            part.parent = f.get_16()
                        Property.Collision:
                            part.collision = f.get_16()
                        Property.ConstantAnimation:
                            part.animation = f.get_fstring(size)
                        Property.VisibleRangeSet:
                            part.visible_range_set = f.get_16()
                        Property.UseLightmap:
                            part.use_lightmap = f.get_16() != 0
                        Property.BoneIndex:
                            part.bone_index = f.get_16()
                        Property.DummyIndex:
                            part.dummy_index = f.get_16()
                        _:
                            f.get_buffer(size)

                    property = f.get_8()
                obj.parts.push_back(part)

            var obj_effect_count = f.get_16()
            for i in range(obj_effect_count):
                var obj_effect = ZscObject.ZscObjectEffect.new()
                obj_effect.effect_type = f.get_16()
                obj_effect.effect = f.get_16()

                var property = f.get_8()
                while property != 0:
                    var size = f.get_8()

                    match property:
                        Property.Position:
                            obj_effect.position = f.get_vector3_f32()
                        Property.Rotation:
                            obj_effect.rotation = f.get_quat_wxyz()
                        Property.Scale:
                            obj_effect.scale = f.get_vector3_f32()
                        Property.Parent:
                            obj_effect.parent = f.get_16()
                        _:
                            f.get_buffer(size) # Seek size from current
                    
                    property = f.get_8()
                obj.effects.push_back(obj_effect)

            obj.bb_min = f.get_vector3_f32()
            obj.bb_max = f.get_vector3_f32()

        self.objects.push_back(obj)   
    
    