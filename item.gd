class_name Item
extends Sprite2D

var m : Vector2i

var sp_barrier := preload("res://barrier_wood.png")
var sp_poison := preload("res://poison_purple.png")

enum KIND {BARRIER, POISON}
var kind : KIND
var stats : Dictionary[String, Variant] = {} 

const POISON_DAMAGE := 10.0

func _init(_k: KIND, _m: Vector2i, _p: Vector2) -> void:
	m=_m
	position=_p
	kind=_k
	match kind:
		KIND.BARRIER:
			self.texture = sp_barrier
		KIND.POISON:
			self.texture = sp_poison
			stats["rate"] = 100.0
		_:
			assert(false, "item setup wrong")
