extends Node

@export var from_center: bool = true
@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var press_scale: Vector2 = Vector2(0.9, 0.9)
@export var time: float = 0.1
@export var transition_type: Tween.TransitionType

var target: Control
var default_scale: Vector2

func _ready():
	# This will check that the node has been added to the tree.
	if not is_inside_tree():
		return

	target = get_parent()
	if target == null or not target is Control:
		push_warning("Target is null or not a Control node. Scaling effects will not work.")
		return
	
	connect_signals()
	call_deferred("setup")

func connect_signals() -> void:
	if target == null:
		return
	target.mouse_entered.connect(on_mouse_hover)
	target.mouse_exited.connect(off_mouse_hover)
	target.button_down.connect(on_button_down)
	target.button_up.connect(on_button_up)
	target.focus_entered.connect(on_focus_enter)
	target.focus_exited.connect(on_focus_exit)

func setup() -> void:
	if target == null:
		return
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func on_mouse_hover() -> void:
	add_tween("scale", hover_scale, time)

func off_mouse_hover() -> void:
	add_tween("scale", default_scale, time)

func on_focus_enter() -> void:
	add_tween("scale", hover_scale, time)

func on_focus_exit() -> void:
	add_tween("scale", default_scale, time)

func on_button_down() -> void:
	add_tween("scale", press_scale, time)

func on_button_up() -> void:
	add_tween("scale", default_scale, time)

func add_tween(property: String, value, seconds: float) -> void:
	if target == null or get_tree() == null or not is_inside_tree():
		return
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(target, property, value, seconds).set_trans(transition_type)
