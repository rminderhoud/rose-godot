tool
extends EditorSceneImporter

const RoseFile = preload("../utils/file.gd")
const Utils = preload("../utils/utils.gd")

const HIM = preload("../files/him.gd")
const IFO = preload("../files/ifo.gd")
const STB = preload("../files/stb.gd")
const TIL = preload("../files/til.gd")
const ZON = preload("../files/zon.gd")
const ZSC = preload("../files/zsc.gd")

func _get_extensions():
    return ["zon"]

func _get_import_flags():
    return IMPORT_SCENE

func _import_animation(path, flags, bake_fps):
    return Animation.new()

func _import_scene(path, flags, bake_fps):
    var root = Spatial.new()
    var map_dir = path.get_base_dir() + "/"
    var data_dir = Utils.get_3ddata_dir(path) + "/"

    var load_objects = true

    var stb_path = data_dir + "3DDATA/STB/LIST_ZONE.STB"
    var stb_file = RoseFile.new()
    if stb_file.open(stb_path, File.READ) != OK:
        print("Couldn't open STB file, won't load map objects")
        load_objects = false

    var stb = STB.new()
    stb.read(stb_file)
    stb_file.close()

    var deco_zsc = ZSC.new()
    var cnst_zsc = ZSC.new()

    for stb_row in stb.rows:
        var zone_path = stb_row[1]
        var deco_path = stb_row[11]
        var cnst_path = stb_row[12]

        if zone_path.get_file().to_lower() == path.get_file().to_lower():
            var deco_file = RoseFile.new()
            if deco_file.open(data_dir + deco_path, File.READ) != OK:
                load_objects = false
            deco_zsc.read(deco_file)

            var cnst_file = RoseFile.new()
            if cnst_file.open(data_dir + cnst_path, File.READ) != OK:
                load_objects = false
            cnst_zsc.read(cnst_file)

            break

    var zon_file = RoseFile.new()
    if zon_file.open(path, File.READ) != OK:
        printerr("Error opening zon file: %s" % path)
        return null

    var zon = ZON.new()
    zon.read(zon_file)
    zon_file.close()

    var dir = Directory.new()
    if dir.open(map_dir) != OK:
        printerr("Error opening map directory: %s" % map_dir)
        return null

    # Files are stored as x,y coordinate pairs e.g. 33_33.HIM, 33_34.HIM but
    # are not 0-indexed. We extract the coordinates here
    var chunk_min = Vector2(NAN, NAN)
    var chunk_max = Vector2(NAN, NAN)

    dir.list_dir_begin()
    var dir_item = dir.get_next()
    while dir_item != "":
        if dir.current_is_dir():
            var coords = self._coords_from_path(dir_item)

            if(coords):
                if is_nan(chunk_min.x) or (coords.x < chunk_min.x):
                    chunk_min.x = coords.x
                if is_nan(chunk_max.x) or (coords.x > chunk_max.x):
                    chunk_max.x = coords.x
                if is_nan(chunk_min.y) or (coords.y < chunk_min.y):
                    chunk_min.y = coords.y
                if is_nan(chunk_max.y) or (coords.y > chunk_max.y):
                    chunk_max.y = coords.y

        dir_item = dir.get_next()
    dir.list_dir_end()

    # We normalize the coordinate range and collect the file paths for each chunk
    var chunk_files = []
    for y in range(chunk_min.y, chunk_max.y + 1):
        var row = []
        for x in range(chunk_min.x, chunk_max.x + 1):
            row.append({})
        chunk_files.append(row)

    dir.list_dir_begin()
    dir_item = dir.get_next()
    while dir_item != "":
        var coords = self._coords_from_path(dir_item)
        if(!coords):
            dir_item = dir.get_next()
            continue

        var norm_x = coords.x - chunk_min.x
        var norm_y = coords.y - chunk_min.y

        if !dir.current_is_dir():
            var exts = ["him", "til", "ifo"]
            var ext = dir_item.get_extension().to_lower()
            if ext in exts:
                chunk_files[norm_y][norm_x][ext] = map_dir + dir_item
        else:
            if dir_item == ("%s_%s" % [coords.x, coords.y]):
                # TODO: Unsound to assume png extension will be lower case
                var lightmap = "%s_%s_PLANELLIGHTINGMAP.png" % [coords.x, coords.y]
                chunk_files[norm_y][norm_x]["lightmap"] = map_dir + dir_item + "/" + lightmap

        dir_item = dir.get_next()
    dir.list_dir_end()

    var x_offset = 0
    var y_offset = 0

    var terrain = Spatial.new()
    terrain.set_name("Terrain")
    root.add_child(terrain)
    terrain.owner = root

    var tile_materials = []
    var terrain_shader = load("res://addons/rose-import/shaders/terrain.shader")

    for tile in zon.tiles:
        var tex1_idx = tile.layer1 + tile.offset1;
        var tex2_idx = tile.layer2 + tile.offset2;

        # TODO: It's unsound to assume png will be lower case
        var tex1 = zon.textures[tex1_idx].to_upper().replace(".DDS", ".png")
        var tex2 = zon.textures[tex2_idx].to_upper().replace(".DDS", ".png")

        var layer1 = load(data_dir + tex1)
        var layer2 = load(data_dir + tex2)

        var mat = ShaderMaterial.new()
        mat.shader = terrain_shader
        mat.set_shader_param("layer1", layer1)
        mat.set_shader_param("layer2", layer2)
        mat.set_shader_param("rotation", tile.rotation)

        tile_materials.push_back(mat)

    for y in range(len(chunk_files)):
        for x in range(len(chunk_files[y])):
            if not chunk_files[y][x].has_all(["him", "til", "ifo"]):
                continue

            var him_path = chunk_files[y][x]["him"]
            var til_path = chunk_files[y][x]["til"]
            var ifo_path = chunk_files[y][x]["ifo"]
            var lightmap_path = chunk_files[y][x]["lightmap"]

            var him_file = RoseFile.new()
            var til_file = RoseFile.new()
            var ifo_file = RoseFile.new()

            var him = HIM.new()
            var til = TIL.new()
            var ifo = IFO.new()

            if him_file.open(him_path, File.READ) != OK:
                printerr("Error opening HIM file: %s" % him_path)
                return null

            if til_file.open(til_path, File.READ) != OK:
                printerr("Error opening TIL file: %s" % til_file)
                return null

            if ifo_file.open(ifo_path, File.READ) != OK:
                printerr("Error opening IFO file: %s" % ifo_file)

            him.read(him_file)
            til.read(til_file)
            ifo.read(ifo_file)

            him_file.close()
            til_file.close()
            ifo_file.close()

            var chunk_mesh = Mesh.new()

            var tile_width = (him.width - 1) / til.width + 1
            var tile_height = (him.height - 1) / til.height + 1

            for h in range(0, him.height - 1, tile_height - 1):
                for w in range(0, him.width - 1, tile_width - 1):
                    var tile_vertices = PoolVector3Array()
                    var tile_indices = PoolIntArray()
                    var tile_uv = PoolVector2Array()
                    var tile_normals = PoolVector3Array()

                    for y in range(tile_height):
                        for x in range(tile_width):
                            var vert = Vector3()
                            vert.x = w + x
                            vert.y = him.heights[h + y][w + x] / him.scale
                            vert.z = h + y
                            tile_vertices.push_back(vert)

                            var uv = Vector2(float(x) / tile_width, float(y) / tile_height)
                            tile_uv.push_back(uv)

                            var normal = Vector3(0, 1, 0);
                            tile_normals.push_back(normal)

                    for y in range(tile_height - 1):
                        for x in range(tile_width - 1):
                            var i = (y * tile_width) + x
                            tile_indices.push_back(i)
                            tile_indices.push_back(i + 1)
                            tile_indices.push_back(i + tile_width)

                            tile_indices.push_back(i + 1)
                            tile_indices.push_back(i + tile_width + 1)
                            tile_indices.push_back(i + tile_width)

                    var tile_x = floor(w / (tile_width - 1))
                    var tile_y = floor(h / (tile_height - 1))
                    var tile_index = til.tiles[tile_y][tile_x].tile_id
                    var tile_material = tile_materials[tile_index]

                    var arrays = []
                    arrays.resize(Mesh.ARRAY_MAX)
                    arrays[Mesh.ARRAY_VERTEX] = tile_vertices
                    arrays[Mesh.ARRAY_INDEX] = tile_indices
                    arrays[Mesh.ARRAY_TEX_UV] = tile_uv
                    arrays[Mesh.ARRAY_TEX_UV2] = tile_uv
                    arrays[Mesh.ARRAY_NORMAL] = tile_normals

                    var surface_idx = chunk_mesh.get_surface_count()
                    chunk_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
                    chunk_mesh.surface_set_material(surface_idx, tile_material)
                    chunk_mesh.surface_set_name(surface_idx, "%s_%s" % [w, h])

            var chunk = MeshInstance.new()
            chunk.mesh = chunk_mesh
            terrain.add_child(chunk)
            chunk.owner = root

            # TODO: Don't hardcode chunk size here
            chunk.translate(Vector3(x * 64, 0, y * 64))

    # TODO: Load objects

    return root

func import_animation_from_other_importer(path, flags, bake_fps):
    return self._import_animation(path, flags, bake_fps)

func import_scene_from_other_importer(path, flags, bake_fps):
    return self._import_scene(path, flags, bake_fps)

static func _coords_from_path(path):
    var s = path.split("_")
    if(len(s) == 2):
        return Vector2(s[0].to_int(), s[1].to_int())
    return null