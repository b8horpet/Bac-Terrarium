class_name VisuLayer
extends TileMapLayer

@onready var cell_grid : CellGrid = $"../Cells"

var cells : Dictionary[Vector2i,Visu] = {}
var props : Array[String] = ["food","poison"]
var prop_idx := 0

func _process(delta: float) -> void:
	if props.is_empty():
		return
	if prop_idx < 0 or prop_idx >= props.size():
		return
	var prop = props[prop_idx]
	if prop in cell_grid.data:
		clear()
		var pd := cell_grid.data[prop]
		for c in pd:
			set_cell(c,0,Vector2i(),0)
		update_internals()
		for c in pd:
			cells[c].display(pd[c])

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var ke := event as InputEventKey
		if ke.keycode == Key.KEY_TAB and ke.pressed and !ke.echo:
			prop_idx = (prop_idx + 1) % props.size()
