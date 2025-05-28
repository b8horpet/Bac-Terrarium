class_name Visu
extends Sprite2D

var p : TileMapLayer = null
var m : Vector2i

func _enter_tree() -> void:
	p = get_parent() as TileMapLayer
	m = p.local_to_map(p.to_local(self.global_position))
	p.cells[m] = self

func _exit_tree() -> void:
	(p.cells as Dictionary).erase(m)

func display(data) -> void:
	if data is float:
		var f := data as float
		self.self_modulate=Color(exp(-max(f/100.0,0)),exp(-max(-f/100.0,0)),exp(-(f/10.0)**2))
		$Label.text = "%1.02f" % f
