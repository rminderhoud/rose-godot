tool
extends EditorImportPlugin

const RoseFile = preload("../utils/file.gd")
const Utils = preload("../utils/utils.gd")
const ZMO = preload("../files/zmo.gd")
const ZMD = preload("../files/zmd.gd")

func get_importer_name():
    return "rose.zmo.import"

func get_import_order():
    return 0
    
func get_import_options(preset):
    return [{"name": "skeleton", "default_value": "", "property_hint": PROPERTY_HINT_FILE}]

func get_option_visibility(option, options):
    return true

func get_preset_name(preset):
    return "Default"

func get_preset_count():
    return 1

func get_priority():
    return 1
    
func get_recognized_extensions():
    return ["zmo"]

func get_resource_type():
    return "Animation"

func get_save_extension():
    return "anim"
                    
func get_visible_name():
    return "ROSE Online ZMO"

func import(src, dst, options, r_platform_variants, r_gen_files):
    var skel_path = options["skeleton"]
    if not skel_path:
        return ERR_FILE_NOT_FOUND
    
    var sf = RoseFile.new()
    if sf.open(skel_path, File.READ) != OK:
        return ERR_FILE_CANT_OPEN
        
    var skeleton = ZMD.new()	
    skeleton.read(sf)
    
    var f = RoseFile.new()
    if f.open(src, File.READ) != OK:
        return FAILED
    
    var zmo = ZMO.new()
    zmo.read(f)
    
    var anim = Animation.new()
    anim.set_step(1.0 / zmo.fps)
    anim.set_length(zmo.frame_count / float(zmo.fps)) 
    anim.set_loop(true)
    
    var tracks = {}
    for i in range(zmo.channel_count):
        var channel = zmo.channels[i]
        var bone = skeleton.bones[channel.index]
        
        var track_name = "Skeleton:" + bone.name
        if not track_name in tracks:
            tracks[track_name] = {}
        
        for j in range(zmo.frame_count):
            var frame = channel.frames[j]
            var time = j * anim.get_step()
            
            if not time in tracks[track_name]:
                tracks[track_name][time] =  {
                    "time": j * anim.get_step(),
                    "loc": Utils.r2g_position(bone.position) / 100,
                    "rot": Utils.r2g_rotation(bone.rotation),
                    "scale": Vector3(1, 1, 1),
                }
            
            if channel.type == ZMO.ChannelType.Position:
                tracks[track_name][time]["loc"] = Utils.r2g_position(frame) / 100
            elif channel.type == ZMO.ChannelType.Rotation:
                var ri = Utils.r2g_rotation(bone.rotation.inverse())
                var rj = Utils.r2g_rotation(frame)
                tracks[track_name][time]["rot"] = (ri * rj)
    
    for track_name in tracks.keys():
        var i = anim.add_track(Animation.TYPE_TRANSFORM)
        anim.track_set_imported(i, true)
        anim.track_set_path(i, track_name)
        
        for track_time in tracks[track_name].keys():
            var time = tracks[track_name][track_time]["time"]
            var loc = tracks[track_name][track_time]["loc"]
            var rot = tracks[track_name][track_time]["rot"]
            var scale = tracks[track_name][track_time]["scale"]
            
            anim.transform_track_insert_key(i, time, loc, rot, scale)
            
    var file = dst + "." + get_save_extension()
    var err = ResourceSaver.save(file, anim)
        
    return OK
