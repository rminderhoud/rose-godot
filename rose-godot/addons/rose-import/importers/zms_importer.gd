tool
extends EditorImportPlugin 

const RoseFile = preload("../utils/file.gd")
const Utils = preload("../utils/utils.gd")
const ZMS = preload("../files/zms.gd")

func get_import_options(preset):
    return [{"name": "texture", "default_value": "", "property_hint": PROPERTY_HINT_FILE}]

func get_import_order():
    return 0
    
func get_importer_name():
    return "rose.zms.import"

func get_option_visibility(option, options):
    return true
    
func get_preset_count():
    return 1

func get_preset_name(preset):
    return "Default"

func get_priority():
    return 1
      
func get_recognized_extensions():
    return ["zms"]

func get_resource_type():
    return "Mesh"
    
func get_save_extension():
    return "mesh"
       
func get_visible_name():
    return "ROSE Online ZMS"

func import(src, dst, options, r_platform_variants, r_gen_files):
    var f = RoseFile.new()
    if f.open(src, File.READ) != OK:
        return FAILED
    
    var zms = ZMS.new()
    zms.read(f)
    
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for vi in range(zms.vertices.size()):
        if zms.normals_enabled():
            st.add_normal(zms.vertices[vi].normal)
        if zms.colors_enabled():
            st.add_color(zms.vertices[vi].color)
        if zms.bones_enabled():
            var bones = []
            for bi in range(4):
                bones.append(zms.bones[zms.vertices[vi].bone_indices[bi]])
            st.add_bones(bones)
            st.add_weights(zms.vertices[vi].bone_weights)
        if zms.tangents_enabled():
            # TODO: Use `Plane` to correctly load tangent
            st.add_tangent(zms.vertices[vi].tangent)
        if zms.uv1_enabled():
            st.add_uv(zms.vertices[vi].uv1)
        if zms.uv2_enabled():
            st.add_uv2(zms.vertices[vi].uv2)
        
        # Must come last
        if zms.positions_enabled():
            st.add_vertex(Utils.r2g_position(zms.vertices[vi].position))
    
    for i in range(zms.indices.size()):
        st.add_index(zms.indices[i].x)
        st.add_index(zms.indices[i].y)
        st.add_index(zms.indices[i].z)

    st.index()
    st.generate_normals()
    st.generate_tangents()
    var mesh = st.commit()

    var tex_path = ""
    var tex = null
    var dir = Directory.new()
    
    # Prefer loading specified texture, otherwise search for one
    if options["texture"]:
        tex_path = options["texture"]
    else:
        var tex_name = src.get_file().get_basename()
        var tex_ext = ".png"
        
        if src.get_extension() == "ZMS":
            tex_ext = ".PNG"
        
        # Replace prefix
        if tex_name.begins_with("m_"):
            tex_name.erase(0, 2) 
            tex_name = "t_" + tex_name;
        
        # Remove suffix
        if tex_name.rfind("_") == tex_name.length() - 2:
            tex_name.erase(tex_name.length() - 2, 2)
        
        tex_path = src.get_base_dir() + "/" + tex_name + tex_ext
    
    if dir.file_exists(tex_path):
        tex = load(tex_path)
        
    if tex and mesh.get_surface_count() == 1:
        var mat = SpatialMaterial.new()
        mat.flags_unshaded = true
        mat.albedo_texture = tex

        mesh.surface_set_material(0, mat)

    var file = dst + "." + get_save_extension()
    var err = ResourceSaver.save(file, mesh)
    
    return OK