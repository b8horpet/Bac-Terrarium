class_name Cell
extends Sprite2D

class Action:
	var name : String = "None"
	var cell : Cell = null

class Die extends Action:
	func _init(p: Cell) -> void:
		name = "Die"
		cell = p

class Propagate extends Action:
	var spawn: Vector2i
	func _init(p: Cell, s = null) -> void:
		name = "Propagate"
		cell = p
		spawn = cell.m
		if s != null and s is Vector2i:
			spawn = s as Vector2i

var p : CellGrid = null
var m : Vector2i

const FOOD_ABSORPTION := 3.0
const ENERGY_DEPLETION := 1.0
const PROPAGATE_COST := 1.0
var energy: float = 1.0
var strain : String = "unknown"

func _enter_tree() -> void:
	rotation=randf()*TAU
	p = get_parent() as CellGrid
	m = p.local_to_map(p.to_local(self.global_position))
	p.cells[m] = self
	recolor()

func _exit_tree() -> void:
	(p.cells as Dictionary).erase(m)

func recolor() -> void:
	var well := 1.0-1.0/maxf(energy/8.0,1.0)
	var dying = maxf(5.0 - energy,0.0)/5.0
	self_modulate = Color(maxf(dying,1.0-well),1.0-dying, 1.0-dying-well, 1.0)


func tick(env: Dictionary[String, Dictionary]) -> Action:
	var food := env["food"] as Dictionary[Vector2i,float]
	if m in food and food[m] > 0:
		var f := clampf(food[m],0,FOOD_ABSORPTION)
		food[m] -= f
		energy += f
		#print(m, " ate ", ff)
	var poison := env["poison"] as Dictionary[Vector2i,float]
	if m in poison:
		energy += poison[m]
	energy -= ENERGY_DEPLETION
	if energy < 0:
		#print(m, " sayonara")
		return Die.new(self)
	#print(m, " alive ", energy)
	recolor()
	if energy >= 10.0:
		var c := env["cells"] as Dictionary[Vector2i,Cell]
		var spawn : Array[Vector2i] = []
		for surr in p.get_surrounding_cells(m):
			if surr not in c:
				spawn.append(surr)
		if !spawn.is_empty():
			return Propagate.new(self,spawn.pick_random())
	return Action.new()
