@tool
extends VBoxContainer

signal settings_changed(pos_active: bool, pos: Vector3, pos_linked: bool, rot_active: bool, rot: Vector3, rot_linked: bool, scale_active: bool, scale: Vector3, scale_linked: bool)

@onready var pos_active: CheckBox = get_node("Pos/Active")
@onready var pos_x: SpinBox = get_node("Pos/X")
@onready var pos_y: SpinBox = get_node("Pos/Y")
@onready var pos_z: SpinBox = get_node("Pos/Z")
@onready var pos_linked: CheckBox = get_node("Pos/Linked")
@onready var rot_active: CheckBox = get_node("Rot/Active")
@onready var rot_x: SpinBox = get_node("Rot/X")
@onready var rot_y: SpinBox = get_node("Rot/Y")
@onready var rot_z: SpinBox = get_node("Rot/Z")
@onready var rot_linked: CheckBox = get_node("Rot/Linked")
@onready var scale_active: CheckBox = get_node("Scale/Active")
@onready var scale_x: SpinBox = get_node("Scale/X")
@onready var scale_y: SpinBox = get_node("Scale/Y")
@onready var scale_z: SpinBox = get_node("Scale/Z")
@onready var scale_linked: CheckBox = get_node("Scale/Linked")


func setup(settings: Dictionary):
	pos_active.button_pressed = settings.pos_active
	pos_x.value = settings.pos.x
	pos_y.value = settings.pos.y
	pos_z.value = settings.pos.z
	if !settings.pos_active:
		for spin_box in [pos_x, pos_y, pos_z]:
			spin_box.editable = false
	pos_linked.button_pressed = settings.pos_linked
	rot_active.button_pressed = settings.rot_active
	rot_x.value = settings.rot.x
	rot_y.value = settings.rot.y
	rot_z.value = settings.rot.z
	if !settings.rot_active:
		for spin_box in [rot_x, rot_y, rot_z]:
			spin_box.editable = false
	rot_linked.button_pressed = settings.rot_linked
	scale_active.button_pressed = settings.scale_active
	scale_x.value = settings.scale.x
	scale_y.value = settings.scale.y
	scale_z.value = settings.scale.z
	if !settings.scale_active:
		for spin_box in [scale_x, scale_y, scale_z]:
			spin_box.editable = false
	scale_linked.button_pressed = settings.scale_linked
	
	for node in [pos_active, rot_active, scale_active]:
		node.toggled.connect(func(value): _on_active_toggled(value, node))
	for node in [pos_linked, rot_linked, scale_linked]:
		node.toggled.connect(func(value): _on_linked_toggled(value, node))
	for node in [pos_x, pos_y, pos_z]:
		node.value_changed.connect(func(value): _on_value_changed(value, pos_linked.button_pressed, pos_x, pos_y, pos_z))
	for node in [rot_x, rot_y, rot_z]:
		node.value_changed.connect(func(value): _on_value_changed(value, rot_linked.button_pressed, rot_x, rot_y, rot_z))
	for node in [scale_x, scale_y, scale_z]:
		node.value_changed.connect(func(value):_on_value_changed(value, scale_linked.button_pressed, scale_x, scale_y, scale_z))


func update_settings():
	settings_changed.emit(
		pos_active.button_pressed,
		Vector3(pos_x.value, pos_y.value, pos_z.value),
		pos_linked.button_pressed,
		rot_active.button_pressed,
		Vector3(rot_x.value, rot_y.value, rot_z.value),
		rot_linked.button_pressed,
		scale_active.button_pressed,
		Vector3(scale_x.value, scale_y.value, scale_z.value),
		scale_linked.button_pressed
	)


func _on_active_toggled(value: bool, node: CheckBox):
	var x: SpinBox
	var y: SpinBox
	var z: SpinBox
	match node:
		pos_active:
			x = pos_x
			y = pos_y
			z = pos_z
		rot_active:
			x = rot_x
			y = rot_y
			z = rot_z
		scale_active:
			x = scale_x
			y = scale_y
			z = scale_z
	for spin_box in [x, y, z]:
		spin_box.editable = value
	update_settings()


func _on_value_changed(value: float, linked: bool, x: SpinBox, y: SpinBox, z: SpinBox):
	if linked:
		x.value = value
		y.value = value
		z.value = value
	update_settings()


func _on_linked_toggled(value: bool, node: CheckBox):
	if value:
		var new_value
		match node:
			pos_linked:
				new_value = pos_x.value
				pos_y.value = new_value
				pos_z.value = new_value
			rot_linked:
				new_value = rot_x.value
				rot_y.value = new_value
				rot_z.value = new_value
			scale_linked:
				new_value = scale_x.value
				scale_y.value = new_value
				scale_z.value = new_value
	update_settings()
