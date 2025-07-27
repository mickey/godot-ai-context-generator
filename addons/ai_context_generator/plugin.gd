@tool
extends EditorPlugin

const AIContextGenerator = preload("res://addons/ai_context_generator/ai_context_generator.gd")

func _enter_tree():
	# Add a simple menu item to the Project menu
	add_tool_menu_item("Generate AI Context", _on_generate_context)

func _exit_tree():
	# Clean up
	remove_tool_menu_item("Generate AI Context")

func _on_generate_context():
	var generator = AIContextGenerator.new()
	generator.export_project_structure()
