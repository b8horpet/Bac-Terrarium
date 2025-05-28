class_name GuiCell
extends Sprite2D

var p : Vector2
var m : Vector2i
var instant : bool
var arrived : bool = false

func set_goal(_m : Vector2i, _p: Vector2, force : bool = false) -> void:
	if _m == m and not force:
		return
	m=_m
	p=_p
	arrived=false

func _process(delta: float) -> void:
	if instant:
		position=p
		arrived=true
	else:
		position=lerp(position,p,1-pow(2.0,-20*delta))
	if position.distance_squared_to(p) < 4:
		position=p
		arrived=true
	if arrived:
		$Label.text = str(m)
