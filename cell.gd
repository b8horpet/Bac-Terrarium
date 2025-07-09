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
			var next := spawn.pick_random() as Vector2i
			var nextfood := 0.0
			var nextloc := p.map_to_local(next)
			var oloc := p.map_to_local(Vector2i(0,0))
			var ploc := p.map_to_local(Vector2i(-8,3))
			var sfood := 0.0
			if m in env["food"]:
				sfood = env["food"][m] as float
			if next in env["food"]:
				nextfood = env["food"][next] as float
			var nextitem := 0
			if next in env["items"]:
				nextitem=1
			var nextodist := nextloc.distance_to(oloc)
			var nextpdist := nextloc.distance_to(ploc)
			for n in spawn:
				var nloc := p.map_to_local(n)
				var nfood := 0.0
				if n in env["food"]:
					nfood = env["food"][n] as float
				var nitem := 0
				if n in env["items"]:
					nitem = 1
				#if n.distance_squared_to(Vector2i(-8,3)) > next.distance_squared_to(Vector2i(-8,3)):
				#if n.distance_squared_to(Vector2i()) > next.distance_squared_to(Vector2i()):
				#if n in env["food"] and env["food"][n] > nfood:
				#if nfood < 10:
					#continue
				var nodist := nloc.distance_to(oloc)
				var npdist := nloc.distance_to(ploc)
				if nitem > nextitem:
					next=n
					nextitem = nitem
					nextfood = nfood
					nextodist = nodist
					nextpdist = npdist
				elif nextitem == 1:
					continue
				#elif sfood + energy < 15:
				else:
					#if npdist+nodist < nextpdist+nextodist:
					if nodist > nextodist:
						next=n
						nextitem = nitem
						nextfood = nfood
						nextodist = nodist
						nextpdist = npdist
				#else:
					#if nfood > nextfood:
						#next=n
						#nextitem = nitem
						#nextfood = nfood
						#nextodist = nodist
						#nextpdist = npdist
			return Propagate.new(self,next)
	return Action.new()
