# Plugin that adds an importer plugin for .terrain files
#
# A `.terrain` file is an empty file but the importer exposes the heightmap
# and tilemap file in order to associate a heightmap image and tilemap data
tool
extends EditorPlugin

var terrain_importer = null

func _enter_tree():
	terrain_importer = preload("importer_terrain.gd").new()
	add_import_plugin(terrain_importer)

func _exit_tree():
	remove_import_plugin(terrain_importer)
	terrain_importer = null