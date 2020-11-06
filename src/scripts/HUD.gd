extends CanvasLayer


func hide():
	$ScoreBox.hide()

func show():
	$ScoreBox.show()

func update_place(value):
	$ScoreBox/HBoxContainer/HBoxContainer/Place.text = str(value)
	
func update_time(value):
	$ScoreBox/HBoxContainer/HBoxContainer2/Time.text = str(value)
