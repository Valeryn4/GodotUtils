extends CanvasLayer

export(bool) var to_show = true
export(float) var transaction_time = 0.3

func _ready():
	
	if to_show :
		$Tween.interpolate_property($Control, "color", Color.black, Color(0,0,0,0), transaction_time, Tween.TRANS_LINEAR,Tween.EASE_IN)
		$Tween.interpolate_callback(self, transaction_time + 0.05, "queue_free")
	else :
		$Tween.interpolate_property($Control, "color", Color(0,0,0,0), Color.black, transaction_time, Tween.TRANS_LINEAR,Tween.EASE_IN)
		$Tween.interpolate_callback(self, transaction_time + 0.05, "queue_free")
	pass # Replace with function body.
	$Tween.start()

func _enter_tree():
	if to_show :
		$Control.color = Color.black
	else :
		$Control.color = Color(0,0,0,0)