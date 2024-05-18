extends Node

@export var width = 8
@export var height = 8

@export var x_start = 0
@export var y_start = 0

@export var offset = 64
@onready var game_manager = $GameManager
@onready var todo_label = $GameManager/todoLabel
@onready var restart = %Restart

var totalTiles = 64
var totalMines = 0

@export var mine_threshold = 0.8

var all_tiles = [];

var defaultTile =  preload("res://scene/case.tscn");

func _ready():
	randomize();
	all_tiles= make_2d_array();
	init_bombs();
	
	todo_label.text = str(totalTiles - totalMines) + " cases à découvrir"
	

func make_2d_array():
	var array  = [] 
	for i in width+2:
		array.append([]);
		for j in height+2:
			array[i].append(null);
	return array;

func on_click(a):
	if a.isBomb == false:
		var sum = sum(a.pos.x, a.pos.y)
		totalTiles-=1
		todo_label.text = str(totalTiles - totalMines ) +  " cases à découvrir"
		a.setLabel(sum)
		print(str(a));
		if sum == 0:
			revealAround(a.pos.x, a.pos.y)
	else:
		pass
		

func revealAround(x,y):
	await get_tree().create_timer(0.05).timeout
	reveal(x - 1,y - 1)
	reveal(x - 1,y)
	reveal(x - 1,y + 1)
	reveal(x, y - 1)
	reveal(x, y + 1)
	reveal(x + 1,y - 1)
	reveal(x + 1,y )
	reveal(x + 1,y + 1)

func reveal(x,y):
	if(all_tiles[x][y] != null && all_tiles[x][y].revealed == false) :
		all_tiles[x][y].texture_button.emit_signal("pressed")

func init_bombs():
	for i in range(1,width+1):
		for j in range(1,height+1):
			var boom = randf()>mine_threshold;
			var piece  = defaultTile.instantiate()
			piece.pos = Vector2(i,j)
			if (boom) :
				piece.isBomb = boom
				totalMines+=1
			piece.connect("onclick", on_click)

			piece.position = grid_to_pixel(i,j)
			all_tiles[i][j] = piece
			add_child(piece)

func grid_to_pixel(x,y): 
	var new_x = (x-1) * offset + x_start
	var new_y = (y-1) * offset + y_start
	return Vector2(new_x, new_y)

func bool_to_int(b):
	return 1 if b else 0

func mine_as_int(x,y):
	if(all_tiles[y][x] != null) :
		return bool_to_int(all_tiles[y][x].isBomb)
	else:
		return 0

func sum(x, y) :
	return (mine_as_int(y-1,x-1) + mine_as_int(y-1,x) + mine_as_int(y-1,x+1)
	+ mine_as_int(y,x-1) + mine_as_int(y,x+1) + mine_as_int(y+1,x-1) 
	+ mine_as_int(y+1,x)  + mine_as_int(y+1,x+1))

func _on_restart_pressed():
	get_tree().reload_current_scene();
