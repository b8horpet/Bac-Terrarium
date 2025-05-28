class_name GUI_Layer
extends Node2D

const gcs = preload("res://gui_cell.tscn")
#var selection : GuiCell = null
var mouse : GuiCell = null
@onready var c : CellGrid = $"../Cells"
@onready var b : TileMapLayer = $"../Base"

const types : Array[Item.KIND] = [Item.KIND.BARRIER, Item.KIND.POISON]
const colors : Array[Color] = [Color.SADDLE_BROWN, Color.PURPLE]
var selected := 0 

signal placed(item: Item.KIND, pos: Vector2i)

func _ready() -> void:
	self.connect("placed",c.on_placement)
	var mp := Vector2i()
	ensure_mouse(Vector2())
	mouse.set_goal(mp,b.map_to_local(mp),true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var lp := b.to_local(get_global_mouse_position())
		var mp := b.local_to_map(lp)
		if b.get_cell_source_id(mp) == -1:
			return
		var rp := b.map_to_local(mp)
		ensure_mouse(lp)
		mouse.set_goal(mp,rp)
	elif event is InputEventMouseButton:
		var lp := b.to_local(get_global_mouse_position())
		var mp := b.local_to_map(lp)
		var inside := b.get_cell_source_id(mp) != -1
		var rp := b.map_to_local(mp)
		var bm := (event as InputEventMouseButton).button_mask
		if bm & 1 != 0:
			if inside:
				ensure_mouse(lp)
				mouse.set_goal(mp,rp)
				emit_signal("placed", types[selected], mp)
#				ensure_selection(rp)
#				selection.set_goal(mp,rp)
#			else:
#				remove_selection()
		elif bm & 2 != 0:
			if inside:
				ensure_mouse(lp)
				mouse.set_goal(mp,rp)
#			remove_selection()
	elif event is InputEventKey:
		var ke := event as InputEventKey
		if ke.keycode == Key.KEY_SPACE and ke.pressed and !ke.echo:
			selected = (selected + 1) % types.size()
			mouse.self_modulate = colors[selected]
			

func ensure_mouse(lp : Vector2) -> void:
	if mouse == null:
		mouse = gcs.instantiate()
		mouse.self_modulate = colors[selected]
		mouse.position = lp
		mouse.instant=false
		add_child(mouse)

#func ensure_selection(lp : Vector2i) -> void:
#	if selection == null:
#		selection = gcs.instantiate()
#		selection.self_modulate = Color.SEA_GREEN
#		selection.position = lp
#		selection.instant = true
#		add_child(selection)

#func remove_selection() -> void:
#	if selection != null:
#		remove_child(selection)
#		selection.queue_free()
#		selection=null
