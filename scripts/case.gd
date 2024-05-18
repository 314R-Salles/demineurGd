extends Node2D

@export var pos = Vector2(0,0);
@onready var texture_button = $TextureButton

@export var isBomb = false : 
	set(v): 
		isBomb= v;
		
@export var revealed = false : 
	set(v): 
		revealed= v;

signal onclick

func _to_string():
	return  "pos :" + str(pos) +  " bomb :" + str(isBomb)

func setLabel(neighboors):
	var label = Label.new();
	label.text = str(neighboors)
	add_child(label)
	label.scale = Vector2(2,2)
	#label.add_theme_font_size_override("overrideName", 32)
	label.position = Vector2(18,12)
	
func setPicture():
	var sprite = Sprite2D.new();
	sprite.texture = preload("res://assets/icon.svg")
	add_child(sprite)
	sprite.scale = Vector2(0.5,0.5)
	sprite.position = Vector2(32,32)

	
func removeButton() :
	if (texture_button!= null ):
		texture_button.queue_free()

func disableButton():
	if (texture_button!= null ):
		texture_button.disabled = true

func _on_texture_button_pressed():
	revealed = true;
	onclick.emit(self)
	
