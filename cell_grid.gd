class_name CellGrid
extends TileMapLayer

@onready var cells : Dictionary[Vector2i, Cell] = {}
@onready var items : Dictionary[Vector2i, Item] = {}
@onready var data : Dictionary[String,Dictionary] = {"cells":cells, "items":items}
@onready var base : TileMapLayer = $"../Base"
@onready var place_que : Dictionary[Vector2i,Item.KIND] = {}
@onready var screen := $"../SCREEN"


var ticktime := 0.0
const TICK_LENGTH := 1.0
var game_speed := 1.0
var iter := 0
var t: Tween = null

enum TILE_TYPE {CELL=0}

func _ready() -> void:
	update_internals()
	var pp := Vector2i(0,6)
	var it := Item.new(Item.KIND.POISON, pp, map_to_local(pp))
	items[pp]=it
	add_child(it)
	var cs : Array[Vector2i] = [Vector2i()]
	var food : Dictionary[Vector2i,float] = {cs[0]: 50}
	for i in range(9):
		var ncs : Array[Vector2i] = []
		for c in cs:
			for s in get_surrounding_cells(c):
				if s not in cs and s not in food:
					food[s] = 45-i*5
				if s not in ncs:
					ncs.append(s)
		cs = ncs
	data["food"] = food
	var poison : Dictionary[Vector2i,float] = {}
	data["poison"] = poison
	#cells[Vector2i()].strain = "Player"
	var enemy := Vector2i(-8,3)
	food[enemy] += 200
	set_cell(enemy, 0, Vector2i(), 0)
	update_internals()
	cells[enemy].strain = "Player"
	anim_start()

func _process(delta: float) -> void:
	ticktime += delta * game_speed
	if ticktime < TICK_LENGTH:
		return
	ticktime -= TICK_LENGTH
	handle_cells()
	propagate_effects()
	place_items()
	iter += 1
	check_win_condition()

const POISON_THRESHOLD := -7.0

func propagate_effects() -> void:
	var poison := data["poison"] as Dictionary[Vector2i,float]
	for it in items:
		var item := items[it]
		if item.kind == Item.KIND.POISON:
			if item.m not in poison:
				poison[item.m]=0.0
			poison[item.m] -= item.stats["rate"] as float
	var update : Dictionary[Vector2i,float] = {}
	for p in poison:
		update[p] = 0.0
	for p in poison:
		var pval := poison[p]
		if pval >= POISON_THRESHOLD:
			continue
		var surr := get_surrounding_cells(p)
		for pp in surr:
			if pp in poison:
				var ppval := poison[pp]
				if ppval > pval:
					var u := maxf(pval/7.0,(pval-ppval)/6.0)
					update[pp]+=u
					update[p]-=u
			else:
				if pp in items and items[pp].kind == Item.KIND.BARRIER:
					continue
				if base.get_cell_source_id(pp) == -1:
					continue
				var u := minf(pval/7.0,0.0)
				if pp not in update:
					update[pp]=0.0
				update[pp]+=u
				update[p]-=u
	for u in update:
		if u not in poison:
			poison[u] = update[u]
		else:
			poison[u] += update[u]

func handle_cells() -> void:
	var spawn : Dictionary[Vector2i,Array] = {}
	for c in cells:
		var a : Cell.Action = cells[c].tick(data)
		if a is Cell.Die:
			erase_cell(a.cell.m)
		elif a is Cell.Propagate:
			var p := a as Cell.Propagate
			assert(p.spawn not in cells)
			if p.spawn not in spawn:
				spawn[p.spawn]=[]
			spawn[p.spawn].append(a.cell)
	for s in spawn:
		var poison := false
		if s in items:
			var k := items[s].kind
			if k == Item.KIND.BARRIER:
				continue
			elif k == Item.KIND.POISON:
				poison=true
		if poison:
			for orig in spawn[s]:
				orig.energy = -10 # instakill
		else:
			var orig := spawn[s].pick_random() as Cell
			orig.energy -= 1+Cell.PROPAGATE_COST
			set_cell(s,0,Vector2i(),TILE_TYPE.CELL)
			update_internals()
			cells[s].strain = orig.strain

func check_win_condition() -> void:
	var player_cells := 0
	for c in cells:
		if cells[c].strain == "Player":
			player_cells += 1
	var text := ""
	var go := screen.get_node("C/V/GAMEOVER")
	if player_cells > 100:
		text = "SUCCESS\nin %d seconds" % iter
		game_speed = 0.0
		go.text = text
		(go as Label).add_theme_color_override("font_color",Color.DARK_GREEN)
		screen.visible=true
	elif player_cells == 0:
		text = "FAILURE\nin %d seconds" % iter
		game_speed = 0.0
		go.text = text
		(go as Label).add_theme_color_override("font_color",Color.RED)
		screen.visible=true

func on_placement(kind: Item.KIND, pos: Vector2i) -> void:
	if pos not in place_que:
		place_que[pos]=kind

func place_items() -> void:
	for pos in place_que:
		var kind := place_que[pos]
		if pos not in items and pos not in cells:
			var item := Item.new(kind, pos, map_to_local(pos))
			items[pos]=item
			for f in ["food", "poison"]:
				var d : Dictionary[Vector2i,float] = data[f]
				if pos in d:
					d.erase(pos)
			add_child(item)
	place_que.clear()

func anim(p: Vector2) -> void:
	for c in cells:
		(cells[c] as Cell).scale = p

func anim_start() -> void:
	#return
	if t:
		t.kill()
	t = create_tween().set_trans(Tween.TRANS_CIRC)
	t.tween_method(anim,Vector2(1,1),Vector2(0.8,1.2),1)
	t.tween_method(anim,Vector2(0.8,1.2),Vector2(1,1),1)
	t.tween_method(anim,Vector2(1,1),Vector2(1.2,0.8),1)
	t.tween_method(anim,Vector2(1.2,0.8),Vector2(1,1),1)
	t.tween_callback(anim_start)
