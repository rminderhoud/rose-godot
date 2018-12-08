tool
extends EditorImportPlugin

const RoseFile = preload("../utils/file.gd")
const Utils = preload("../utils/utils.gd")
const ZMD = preload("../files/zmd.gd")

func get_import_options(preset):
    return []

func get_import_order():
    return 0
    
func get_importer_name():
    return "rose.zmd.import"

func get_option_visibility(option, options):
    return true

func get_preset_count():
    return 0

func get_preset_name(preset):
    return "Default"

func get_priority():
    return 1
    
func get_recognized_extensions():
    return ["zmd"]

func get_resource_type():
    return "PackedScene"

func get_save_extension():
    return "tscn"
              
func get_visible_name():
    return "ROSE Online ZMD"
 
func import(src, dst, options, r_platform_variants, r_gen_files):
    var f = RoseFile.new()
    if f.open(src, File.READ) != OK:
        return FAILED
    
    var zmd = ZMD.new()
    zmd.read(f)
    
    var skel = Skeleton.new()

    for bone in zmd.bones:
        skel.add_bone(bone.name)
    
    for i in range(skel.get_bone_count()):
        var bone = zmd.bones[i]
        var pos = Utils.r2g_position(bone.position)
        var rot = Utils.r2g_rotation(bone.rotation)
        var t = Transform(Basis(rot), pos)
        
        if i > 0:
            skel.set_bone_parent(i, bone.parent)
        
        skel.set_bone_rest(i, t)
    
    # Skeleton is not a resource so we have to save as scene
    var spatial = Spatial.new()
    spatial.add_child(skel)
    spatial.set_name("Spatial")
    skel.set_owner(spatial)
    skel.set_name("Skeleton")
    
    var scene = PackedScene.new()
    scene.pack(spatial)
    
    var file = dst + "." + get_save_extension()
    var err = ResourceSaver.save(file, scene)
        
    return OK