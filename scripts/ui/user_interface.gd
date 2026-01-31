class_name UserInterface
extends CanvasLayer

@onready var reticle := $Reticle
@onready var settings_menu := $SettingsMenu
@onready var pause_menu := $PauseMenu

func _ready():
	%ButtonContinue.text = "Start Game"
	%ButtonContinue.pressed.connect(continue_game)
	%ButtonSettings.pressed.connect(open_settings)
	%ButtonQuit.pressed.connect(on_quit)
	settings_menu.close.connect(close_settings)
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_game()
	

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			continue_game()
		else:
			pause_game()

func pause_game():
	%ButtonContinue.text = "Continue"
	get_tree().paused = true
	reticle.hide()
	pause_menu.show()
	settings_menu.hide()
	

func continue_game():
	pause_menu.hide()
	settings_menu.hide()
	reticle.show()
	get_tree().paused = false


func open_settings():
	settings_menu.show()
	pause_menu.hide()
	

func close_settings():
	settings_menu.hide()
	pause_menu.show()
	

func on_quit():
	get_tree().quit()
