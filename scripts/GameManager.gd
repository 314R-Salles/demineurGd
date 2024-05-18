extends Node

@export var width = 8
@export var height = 8
@export var x_start = 0
@export var y_start = 0
@export var offset = 64

@onready var instruction_label = $instructionLabel
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
	instruction_label.text = str(totalTiles - totalMines) + " cases à découvrir"
	

func make_2d_array():
	var array  = [] 
	for i in width+2:
		array.append([]);
		for j in height+2:
			array[i].append(null);
	return array;

func on_click(tile):
	tile.removeButton()
	if tile.isBomb == false:
		var neighboors = sum(tile.pos.x, tile.pos.y)
		tile.setLabel(neighboors)
		totalTiles-=1
		if totalTiles - totalMines == 0:
			instruction_label.text = "C'est gagné"
			for i in range(1,width+1):
				for j in range(1,width+1):
					all_tiles[i][j].disableButton()
		else:
			instruction_label.text = str(totalTiles - totalMines) +  " cases à découvrir"

		
		if neighboors == 0:
			revealAround(tile.pos.x, tile.pos.y)
	else:
		tile.setPicture()
		instruction_label.text = "C'est perdu"
		for r in range(1,2*width):
			await get_tree().create_timer(0.05).timeout
			for i in range(-r,r):
				for j in range(-r,r):
					if (abs(i) + abs(j) <= r 
					&& tile.pos.x+ i > 0 && tile.pos.x+ i <9  
					&& tile.pos.y+ j > 0 && tile.pos.y+ j <9 
					&& !all_tiles[tile.pos.x+ i][tile.pos.y +j].revealed) :
						all_tiles[tile.pos.x+ i][tile.pos.y +j].disableButton()
						#pour pas loop plusieurs fois sur la meme case (meme si ça dérange pas)
						all_tiles[tile.pos.x+ i][tile.pos.y +j].revealed = true;
						if all_tiles[tile.pos.x+ i][tile.pos.y +j].isBomb:
							all_tiles[tile.pos.x+ i][tile.pos.y +j].setPicture()


func revealAround(x,y):
	await get_tree().create_timer(0.05).timeout
	reveal(x-1,y-1); reveal(x-1, y); reveal(x-1, y+1)
	reveal(x, y-1); reveal(x, y+1)
	reveal(x+1, y-1); reveal(x+1, y);reveal(x+1, y+1)

#simuler un clic sur un bouton
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
	+ mine_as_int(y+1,x) + mine_as_int(y+1,x+1))

func _on_restart_pressed():
	get_tree().reload_current_scene();
