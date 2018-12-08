tool
extends EditorImportPlugin

var HEIGHT_SCALE = 100

# Tile size as # of verts
var TILE_SIZE = 5

func get_importer_name():
	return "tilemap.terrain.import"

func get_visible_name():
	return "Tilemap terrain"

func get_recognized_extensions():
	return ["terrain"]

func get_save_extension():
	return "tscn"

func get_preset_count():
	return 1

func get_preset_name(preset):
	return "Default"

func get_import_options(preset):
	return [
		{ "name": "heightmap", "default_value": "", "property_hint": PROPERTY_HINT_FILE },
		{ "name": "tilemap", "default_value": "", "property_hint": PROPERTY_HINT_FILE },
		{ "name": "shader", "default_value": "", "property_hint": PROPERTY_HINT_FILE }, 
	]

func get_option_visibility(option, options):
	return true

func get_resource_type():
	return "PackedScene"

func import(src, dst, options, r_platform_variants, r_gen_files):
	var heightmap_path = options["heightmap"]
	var tilemap_path = options["tilemap"]
	var shader_path = options["shader"]

	if not (heightmap_path and tilemap_path and shader_path):
		return FAILED

	# Load heightmap image
	var heightmap = load(heightmap_path)

	# Load tilemap json file 
	var f = File.new()
	if f.open(tilemap_path, File.READ) != OK:
		return FAILED
	var tilemap = JSON.parse(f.get_as_text()).result
	f.close()

	var shader = load(shader_path)

	var textures = tilemap["textures"]
	var tiles = []

	for tile in tilemap["tiles"]:
		if tile["rotation"] == "Unknown": 
			continue

		var layer1 = load(textures[tile["layer1"]])
		var layer2 = load(textures[tile["layer2"]])
		
		var mat = ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_param("layer1", layer1)
		mat.set_shader_param("layer2", layer2)

		tiles.push_back(mat)

	var root = Spatial.new()
	var mesh = Mesh.new()

	if not ((heightmap.get_height() - 1) % 4 == 0 and (heightmap.get_width() -1)% 4 == 0):
		printerr("Invalid heightmap dimensions")
		return FAILED

	for h in range(0, heightmap.get_height() - 1, TILE_SIZE - 1):
		for w in range(0, heightmap.get_width() - 1, TILE_SIZE - 1):

			var tile_vertices = PoolVector3Array()
			var tile_indices = PoolIntArray()
			var tile_uv1 = PoolVector2Array()
			var tile_uv2 = PoolVector2Array()
			
			var tile_x = floor(w / (TILE_SIZE - 1))
			var tile_y = floor(h / (TILE_SIZE - 1))

			var tile_idx = tilemap["tilemap"][tile_y][tile_x]
			var tile_material = tiles[tile_idx]
			var tile_rotation = tilemap["tiles"][tile_idx]["rotation"]

			# Get surface vertices
			for y in range(0, TILE_SIZE):
				for x in range(0, TILE_SIZE):
					var img = heightmap.get_data()

					img.lock()
					var height = img.get_pixel(w + x, h + y).gray() * HEIGHT_SCALE;
					img.unlock()

					tile_vertices.push_back(Vector3(w + x, height, h + y))

					var uv = Vector2(float(x) / TILE_SIZE, float(y) / TILE_SIZE)
					tile_uv1.push_back(uv)

					if tile_rotation == "FlipHorizontal":
						uv = Vector2(1 - uv.x, uv.y)
					elif tile_rotation == "FlipVertical":
						uv = Vector2(uv.x, 1 - uv.y)
					elif tile_rotation == "Flip":
						uv = Vector2(1 - uv.x, 1 - uv.y)
					elif tile_rotation == "Clockwise90":
						uv = uv.rotated(90)
					elif tile_rotation == "CounterClockwise90":
						uv = uv.rotated(-90)

					tile_uv2.push_back(uv)

			for y in range(0, TILE_SIZE - 1):
				for x in range(0, TILE_SIZE - 1):
					var i = (y * TILE_SIZE) + x
					tile_indices.push_back(i)
					tile_indices.push_back(i + 1)
					tile_indices.push_back(i + TILE_SIZE)

					tile_indices.push_back(i + 1)
					tile_indices.push_back(i + TILE_SIZE + 1)
					tile_indices.push_back(i + TILE_SIZE)

			var arrays = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = tile_vertices
			arrays[Mesh.ARRAY_INDEX] = tile_indices
			arrays[Mesh.ARRAY_TEX_UV] = tile_uv1
			arrays[Mesh.ARRAY_TEX_UV2] = tile_uv2

			var surface_idx = mesh.get_surface_count()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			mesh.surface_set_material(surface_idx, tile_material)
			mesh.surface_set_name(surface_idx, "%sx%s" % [w, h])

	var mi = MeshInstance.new()
	mi.mesh = mesh
	
	root.add_child(mi)
	mi.set_owner(root)

	var scene = PackedScene.new()
	scene.pack(root)

	var file = dst + "." + get_save_extension()
	var err = ResourceSaver.save(file, scene)

	return OK