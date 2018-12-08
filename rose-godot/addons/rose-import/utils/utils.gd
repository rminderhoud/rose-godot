tool

static func r2g_position(pos):
    # Converts ROSE (Z-UP) position to Godot (Y-UP) position
    return Vector3(pos.x, pos.z, pos.y)

static func r2g_rotation(rot):
    # Converts ROSE (Z-UP) quaternion to Godot (Y-UP) quaternion
    return Quat(rot.x, rot.z, rot.y, -rot.w)

static func r2g_scale(scale):
    # Converts ROSE (Z-UP) scale to Godot (Y-UP) scale
    return Vector3(scale.x, scale.z, scale.y)

static func get_3ddata_dir(path):
    # Get the root path for the 3DData from an existing path
    var base = path.get_base_dir()
    while base != "res://":
        base = base.get_base_dir()
        if base.get_file().to_lower() == "3ddata":
            return base.get_base_dir()
    return null
