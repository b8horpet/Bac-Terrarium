class_name VisuLayer
extends TileMapLayer

@onready var cell_grid : CellGrid = $"../Cells"

var cells : Dictionary[Vector2i,Visu] = {}
var prop : String = "food"

func _process(delta: float) -> void:
	if prop.is_empty():
		return
	if prop in cell_grid.data:
		clear()
		var pd := cell_grid.data[prop]
		for c in pd:
			set_cell(c,0,Vector2i(),0)
		update_internals()
		for c in pd:
			cells[c].display(pd[c])
