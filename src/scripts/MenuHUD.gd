extends Panel

func _ready():
	var coinLabel := $GridContainer/Coin/CoinLabel
	coinLabel.text = String(Firebase.user.coins)
	$UserNameLabel.text = Firebase.user.name
	
func _on_Achievements_pressed():
	get_parent().get_node("Achievements").visible = true

func _on_Settings_pressed():
	get_parent().get_node("Settings").visible = true
