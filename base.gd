extends TileMapLayer

func _ready() -> void:
	var h : Dictionary[Vector2i, bool] = {Vector2i(): true}
	for i in range(10):
		var u : Dictionary[Vector2i,bool] = {}
		for k in h:
			var surr := get_surrounding_cells(k)
			for s in surr:
				if s not in h:
					u[s]=true
		h.merge(u)
	for t in h:
		set_cell(t,0,Vector2i(),0)
