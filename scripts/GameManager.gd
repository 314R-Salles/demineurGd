extends Node

@export var x_start = 32
@export var y_start = 32
@export var offset = 64

@onready var instruction_label = %instructionLabel
@onready var restart = %Restart

@onready var width_label = %WidthLabel
@onready var height_label = %HeightLabel

@onready var width_slider = %WidthSlider
@onready var height_slider = %heightSlider

@onready var threshold_label = %ThresholdLabel
@onready var threshold_slider = %ThresholdSlider

# on accède à un seul des 2 colorRect pour modifier le shader commun. 
@onready var color_rect : ColorRect = %ColorRect

var totalMines = 0
var totalTiles = 0

var all_tiles = [];

var defaultTile =  preload("res://scene/case.tscn");


func _ready():
	color_rect.get_material().set_shader_parameter("line_color", Vector4( 0.0, 1.0, 1.0, 1.0 ))
	width_slider.value = Settings.width_tiles
	height_slider.value = Settings.height_tiles

	width_label.text = setSliderLabel("Width", Settings.width_tiles)
	height_label.text = setSliderLabel("Height", Settings.height_tiles)
	
	threshold_slider.value = threshold_to_slider(Settings.mine_threshold)
	threshold_label.text = setSliderLabel("Mines", Settings.mine_threshold)

# on ne manipule les var définies via @export que dans le ready, sinon utilise valeur par défaut
	totalTiles = Settings.width_tiles * Settings.height_tiles

# Le +1 pour des offsets / le 300 pour l'UI à droite
	DisplayServer.window_set_size(Vector2i((Settings.width_tiles+1)*64+300, (Settings.height_tiles+1)*64))
	randomize();
	all_tiles= make_2d_array();
	init_bombs();
	instruction_label.text = str(totalTiles - totalMines) + " cases à découvrir"
	

# trick "habituel" du width et height +2 pour pouvoir sommer les cases autour meme sur les bords
func make_2d_array():
	var array  = [] 
	for i in Settings.width_tiles+2:
		array.append([]);
		for j in Settings.height_tiles+2:
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
			color_rect.get_material().set_shader_parameter("line_color", Vector4( 0.0, 1.0, 0.0, 1.0 ))
			for i in range(1, Settings.width_tiles+1):
				for j in range(1, Settings.height_tiles+1):
					all_tiles[i][j].disableButton()
		else:
			instruction_label.text = str(totalTiles - totalMines) +  " cases à découvrir"

		if neighboors == 0:
			revealAround(tile.pos.x, tile.pos.y)
	else:
		tile.setPicture()
		instruction_label.text = "C'est perdu"
		color_rect.get_material().set_shader_parameter("line_color", Vector4( 1.0, 0.0, 0.0, 1.0 ))
		for r in range(1,2*max(Settings.width_tiles, Settings.height_tiles)):
			await get_tree().create_timer(0.05).timeout
			for i in range(-r,r):
				for j in range(-r,r):
					if (abs(i) + abs(j) <= r 
					&& tile.pos.x+ i > 0 && tile.pos.x+ i < Settings.width_tiles+1 
					&& tile.pos.y+ j > 0 && tile.pos.y+ j < Settings.height_tiles+1 
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
	for i in range(1,Settings.width_tiles+1):
		for j in range(1,Settings.height_tiles+1):
			var boom = randf()> Settings.mine_threshold;
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


func _on_width_slider_value_changed(value):
	Settings.width_tiles = value 
	width_label.text = setSliderLabel("Width",value)

func _on_height_slider_value_changed(value):
	Settings.height_tiles = value 
	height_label.text = setSliderLabel("Height",value)


func setSliderLabel(type, value):
	var res = type + " : "
	if type == "Mines":
		match value:
			0.90:
				res+= "a few"
			0.85:
				res+= "a bit more"
			0.80:
				res+= "normal"
			0.75:
				res+= "a lot"
			0.70:
				res+= "even more"
	else : 
		res += str(value)
		if value<10:
			res +="  "
	return res


func _on_thresholdt_slider_value_changed(value):
	Settings.mine_threshold = 0.90 - value * 0.05
	threshold_label.text = setSliderLabel("Mines", Settings.mine_threshold)

func threshold_to_slider(value):
	return (0.90-value)/0.05
