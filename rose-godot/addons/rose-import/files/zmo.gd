tool
extends Reference

enum ChannelType {
    None = 1 << 0,
    Position = 1 << 1,
    Rotation = 1 << 2,
    Normal = 1 << 3,
    Alpha = 1 << 4,
    UV1 = 1 << 5,
    UV2 = 1 << 6,
    UV3 = 1 << 7,
    UV4 = 1 << 8,
    TextureAnimation = 1 << 9,
    Scale = 1 << 10,
}

class Channel:
    extends Reference
    
    var type = null
    var index = null
    var frames = null
    
    func _init():
        type = ChannelType.None
        index = -1
        frames = []

var format = null
var fps = null
var frame_count = null
var channel_count = null
var channels = null

func _init():
    format = ""
    fps = 0
    frame_count = 0
    channel_count = 0
    channels = []
    
func read(f):
    format = f.get_cstring()
    fps = f.get_32()
    
    frame_count = f.get_32()
    channel_count = f.get_32()
    
    for i in range(channel_count):
        var channel = Channel.new()
        channel.type = f.get_32()
        channel.index = f.get_32()
        channels.append(channel)
        
    for i in range(frame_count):
        for j in range(channel_count):
            var channel = channels[j]
            
            if channel.type == ChannelType.Position:
                channel.frames.append(f.get_vector3_f32() * 0.01)
            elif channel.type == ChannelType.Rotation:
                channel.frames.append(f.get_quat_wxyz())
            elif channel.type == ChannelType.Normal:
                channel.frames.append(f.get_vector3_f32())
            elif channel.type == ChannelType.Alpha:
                channel.frames.append(f.get_float())
            elif channel.type == ChannelType.UV1:
                channel.frames.append(f.get_vector2_f32())
            elif channel.type == ChannelType.UV1:
                channel.frames.append(f.get_vector2_f32())
            elif channel.type == ChannelType.UV2:
                channel.frames.append(f.get_vector2_f32())
            elif channel.type == ChannelType.UV3:
                channel.frames.append(f.get_vector2_f32())
            elif channel.type == ChannelType.UV4:
                channel.frames.append(f.get_vector2_f32())
            elif channel.type == ChannelType.TextureAnimation:
                channel.frames.append(f.get_float())
            elif channel.type == ChannelType.Scale:
                channel.frames.append(f.get_float())