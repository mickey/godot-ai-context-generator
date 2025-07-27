# AI Context Generator for Godot

A lightweight Godot plugin that exports your entire project structure as JSON for AI/LLM analysis. Perfect for getting intelligent assistance with your game development!

## 🚀 Features

- **Complete Project Analysis**: Exports all scenes, scripts, properties, and project settings
- **Non-Default Properties**: Only captures properties that differ from defaults (clean, relevant data)
- **Smart Script Parsing**: Extracts functions, exports, signals, and metadata
- **Lightweight Integration**: Simple menu item - no UI clutter
- **Instant AI Ready**: Automatically copies JSON to clipboard for immediate use
- **Multi-Language Support**: Handles both GDScript and C# files

## 📋 What Gets Exported

### Scene Data
- Complete node hierarchies with types and names
- Non-default properties for every node
- Script attachments and resource references
- Node groups and custom metadata

### Script Analysis
- All GDScript (.gd) and C# (.cs) files
- Function signatures and exported variables
- Signal definitions
- File paths and language detection

### Project Configuration
- Autoload settings
- Input mappings
- Display and physics settings
- Plugin configurations

## 🛠 Installation

### Option 1: Clone Repository
```bash
cd your-godot-project/
git clone https://github.com/yourusername/godot-ai-context-generator.git addons/ai_context_generator
```

### Option 2: Download ZIP
1. Download the latest release
2. Extract to `your-project/addons/ai_context_generator/`
3. Enable the plugin in Project Settings → Plugins

### Option 3: Godot Asset Library
*Coming soon - submit to Godot Asset Library*

## 🎯 Usage

1. **Generate Context**: Go to `Project → Generate AI Context`
2. **Wait for Processing**: Watch console for progress updates
3. **Ready to Use**: JSON is saved to `ai_context_export.json` and copied to clipboard
4. **Paste to AI**: Ctrl+V into ChatGPT, Claude, or your favorite AI assistant

### Example AI Prompts
```
"Here's my Godot project structure. Can you help me optimize the player movement system?"

"Based on this project data, suggest improvements to my cloud animation system."

"Review my code architecture and recommend better organization patterns."
```

## 📁 Output Structure

```json
{
  "project_name": "Your Game",
  "generated_timestamp": "2025-07-27T10:30:00",
  "scenes": [
	{
	  "path": "res://Player.tscn",
	  "root_node": {
		"name": "Player",
		"type": "CharacterBody2D",
		"properties": { "speed": 300.0 },
		"children": [...]
	  }
	}
  ],
  "scripts": [...],
  "autoloads": {...},
  "project_settings": {...}
}
```

## 🔧 Requirements

- **Godot 4.0+** (uses new APIs like `ClassDB.can_instantiate`)
- Works with both 2D and 3D projects
- Supports mixed GDScript/C# projects

## 🤝 Contributing

Contributions welcome! Ideas for improvements:

- [ ] Signal connection mapping between nodes
- [ ] Resource dependency analysis  
- [ ] Custom resource (.tres/.res) content export
- [ ] Scene instantiation relationships
- [ ] Export filtering options
- [ ] Compression for large projects

### Development Setup
```bash
git clone https://github.com/yourusername/godot-ai-context-generator.git
cd godot-ai-context-generator
# Copy to your test project's addons folder
```

## 📄 License

MIT License - feel free to use in commercial and personal projects!

## 🌟 Why This Plugin?

Modern AI assistants are incredibly helpful for game development, but they need context about your project structure. Instead of manually copying code snippets, this plugin gives AI a complete understanding of your:

- Game architecture and design patterns
- Current implementation details  
- Configuration and settings
- Relationships between systems

This leads to much more accurate and helpful AI assistance!

## 🐛 Issues & Support

Found a bug or have a feature request? 
[Create an issue](https://github.com/yourusername/godot-ai-context-generator/issues)

---

**Made with ❤️ for the Godot community**
