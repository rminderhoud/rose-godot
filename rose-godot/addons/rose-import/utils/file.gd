tool
extends File

func get_bool():
    return !(get_8() == 0)

func get_fstring(length):
    # Get fixed size string
    var buffer = get_buffer(length)
    return buffer.get_string_from_ascii()
    
func get_cstring():
    # Get null-terminated string
    var buffer = PoolByteArray()
    var byte = null
    
    while byte != 0x00:
        byte = get_8()
        buffer.append(byte)
    
    return buffer.get_string_from_ascii()

func get_string_u8():
    # Get byte-prefixed string
    var length = get_8()
    var buffer = get_buffer(length)
    return buffer.get_string_from_ascii()

func get_string_u16():
    # Get short-prefixed string
    var length = get_16()
    var buffer = get_buffer(length)
    return buffer.get_string_from_ascii()

func get_quat_wxyz():
    var w = get_float()
    var x = get_float()
    var y = get_float()
    var z = get_float()
    
    return Quat(x, y, z, w)

func get_quat():
    var x = get_float()
    var y = get_float()
    var z = get_float()
    var w = get_float()
    
    return Quat(x, y, z, w)

func get_vector2_f32():
    var v = Vector2(0, 0)
    v.x = get_float()
    v.y = get_float()
    return v

func get_vector2_i32():
    var v = Vector2(0, 0)
    v.x = get_32()
    v.y = get_32()
    return v
    
func get_vector3_f32():
    var v = Vector3(0, 0, 0)
    v.x = get_float()
    v.y = get_float()
    v.z = get_float()
    return v

func get_vector3_i16():
    var v = Vector3(0, 0, 0)
    v.x = get_16()
    v.y = get_16()
    v.z = get_16()
    return v

func get_vector3_i32():
    var v = Vector3(0, 0, 0)
    v.x = get_32()
    v.y = get_32()
    v.z = get_32()
    return v

func get_color4():
    var c = Color(0, 0, 0, 0)
    c.r = get_float()
    c.g = get_float()
    c.b = get_float()
    c.a = get_float()
    return c

func get_array_f32(size):
    var a = []
    for i in range(size):
        a.append(get_float())
    return a

func get_array_i16(size):
    var a = []
    for i in range(size):
        a.append(get_16())
    return a

func get_matrix4():
    var m = []
    for i in range(4):
        var n = []
        for i in range(4):
            n.append(get_float())
        m.append(n)
    return m

func get_color3():
    var c = Color(0, 0, 0)
    c.r = self.get_float()
    c.g = self.get_float()
    c.b = self.get_float()
    return c