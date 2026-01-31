class_name SettingsMenu
extends PanelContainer

@onready var music_vol_label := %LabelMusicVolumeValue
@onready var music_vol_slider := %HSliderMusicVol
@onready var mouse_sensi_label := %LabelMouseSensitivityValue
@onready var mouse_sensi_slider := %HSliderMouseSensitivity

signal close

# Called when the node enters the scene tree for the first time.
func _ready():
	music_vol_slider.value = AudioServer.get_bus_volume_linear(0) * 100
	music_vol_label.text = str(music_vol_slider.value) + " %"
	mouse_sensi_label.text = str(mouse_sensi_slider.value) + " %"
	

func _on_h_slider_music_vol_value_changed(value):
	music_vol_label.text = str(value) + " %"
	AudioServer.set_bus_volume_db(0, linear_to_db(value/100))


func _on_h_slider_mouse_sensitivity_value_changed(value):
	mouse_sensi_label.text = str(value) + " %"
	#TODO: Apply Setting


func _on_button_back_pressed():
	close.emit()
