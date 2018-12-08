tool
extends Reference

class Bone:
    extends Reference
    
    var parent = null
    var name = null
    var position = null
    var rotation = null
    
    func _init():
        parent = -1
        name = ""
        position = Vector3(0.0, 0.0, 0.0)
        rotation = Quat(0.0, 0.0, 0.0, 0.0)

var bones = null

func _init():
    bones = []
    
func read(f):
    var identifier = f.get_fstring(7)
    
    var bone_count = f.get_32()
    if bone_count >= 1000:
        # Prevent long loops in bad files
        return
        
    for i in range(bone_count):
        var bone = Bone.new()
        bone.parent = f.get_32()
        bone.name = f.get_cstring()
        bone.position = f.get_vector3_f32() * 0.01
        bone.rotation = f.get_quat_wxyz()
        bones.append(bone)