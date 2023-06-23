@tool
extends EditorPlugin

const MAIN_INSTANCE_SCENE: PackedScene = preload("res://addons/transform_variance/tool_bar.tscn")
const SETTINGS_INSTANCE_SCENE: PackedScene = preload("res://addons/transform_variance/settings.tscn")

var settings: Dictionary = {
	"pos_active": true,
	"pos": Vector3(0.25, 0, 0.25),
	"pos_linked": false,
	"rot_active": true,
	"rot": Vector3(5, 180, 5),
	"rot_linked": false,
	"scale_active": true,
	"scale": Vector3(0.25, 0.25, 0.25),
	"scale_linked": true
}

var icon: Texture2D
var selected_nodes: Array[Node] = []
var main_instance: HBoxContainer
var settings_instance: VBoxContainer


func _enter_tree():
	randomize()
	icon = get_editor_interface().get_base_control().get_theme_icon("Tools", "EditorIcons")
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)


func _exit_tree():
	cleanup()


func add_main():
	main_instance = MAIN_INSTANCE_SCENE.instantiate()
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, main_instance)
	main_instance.get_node("SettingsButton").icon = icon
	main_instance.get_node("ApplyButton").pressed.connect(apply_transforms)
	main_instance.get_node("SettingsButton").pressed.connect(toggle_settings)


func remove_main():
	main_instance.get_node("ApplyButton").pressed.disconnect(apply_transforms)
	main_instance.get_node("SettingsButton").pressed.disconnect(toggle_settings)
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, main_instance)
	main_instance.queue_free()
	main_instance = null


func add_settings():
	settings_instance = SETTINGS_INSTANCE_SCENE.instantiate()
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, settings_instance)
	settings_instance.setup(settings)
	settings_instance.settings_changed.connect(_on_settings_changed)


func remove_settings():
	settings_instance.settings_changed.disconnect(_on_settings_changed)
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, settings_instance)
	settings_instance.queue_free()
	settings_instance = null


func toggle_settings():
	if !settings_instance:
		add_settings()
	else:
		remove_settings()


func cleanup():
	if main_instance:
		remove_main()
	if settings_instance:
		remove_settings()


func apply_transforms():
	for node in selected_nodes:
		if node is Node3D:
			if settings.pos_active:
				var rand_pos_x: float = randf_range(-settings.pos.x, settings.pos.x)
				var rand_pos_y: float = rand_pos_x if settings.pos_linked else randf_range(-settings.pos.y, settings.pos.y) 
				var rand_pos_z: float = rand_pos_x if settings.pos_linked else randf_range(-settings.pos.z, settings.pos.z)
				node.position += Vector3(rand_pos_x, rand_pos_y, rand_pos_z)
			
			if settings.rot_active:
				var rand_rot_x: float = randf_range(-settings.rot.x, settings.rot.x)
				var rand_rot_y: float = rand_rot_x if settings.rot_linked else randf_range(-settings.rot.y, settings.rot.y) 
				var rand_rot_z: float = rand_rot_x if settings.rot_linked else randf_range(-settings.rot.z, settings.rot.z) 
				node.rotation_degrees += Vector3(rand_rot_x, rand_rot_y, rand_rot_z)
			
			if settings.scale_active:
				var rand_scale_x: float = randf_range(-settings.scale.x, settings.scale.x)
				var rand_scale_y: float = rand_scale_x if settings.scale_linked else randf_range(-settings.scale.y, settings.scale.y)
				var rand_scale_z: float = rand_scale_x if settings.scale_linked else randf_range(-settings.scale.z, settings.scale.z)
				node.scale += Vector3(rand_scale_x, rand_scale_y, rand_scale_z)
				node.scale = node.scale.abs() # Keeps scale from going into the negatives, avoiding reversed faces etc.


func _on_selection_changed():
	await get_tree().process_frame
	selected_nodes = get_editor_interface().get_selection().get_transformable_selected_nodes()
	for node in selected_nodes:
		if !node is Node3D:
			cleanup()
			return
	if !main_instance:
		add_main()


func _on_settings_changed(pos_active: bool, pos: Vector3, pos_linked: bool, rot_active: bool, rot: Vector3, rot_linked: bool, scale_active: bool, scale: Vector3, scale_linked: bool):
	settings.pos_active = pos_active
	settings.pos = pos
	settings.pos_linked = pos_linked
	settings.rot_active = rot_active
	settings.rot = rot
	settings.rot_linked = rot_linked
	settings.scale_active = scale_active
	settings.scale = scale
	settings.scale_linked = scale_linked
