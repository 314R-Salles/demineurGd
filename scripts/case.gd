extends Node2D

@export var pos = Vector2(0,0);
@onready var texture_button = $TextureButton

@export var isBomb = false : 
	set(v): 
		isBomb= v;
		
@export var revealed = false : 
	set(v): 
		revealed= v;

func _to_string():
	return  "pos :" + str(pos) +  " bomb :" + str(isBomb)

func setLabel(neighboors):
	var label = Label.new();
	label.text = str(neighboors)
	add_child(label)
	label.scale = Vector2(2,2)
	#label.add_theme_font_size_override("overrideName", 32)
	label.position = Vector2(18,12)

signal onclick

func _on_texture_button_pressed():
	revealed = true;
	onclick.emit(self)
	texture_button.queue_free()
	
