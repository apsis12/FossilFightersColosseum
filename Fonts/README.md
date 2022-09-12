# Fonts

```BitmapFontGen.gd``` , as the name suggests, is a script which constructs a ```Theme``` holding a ```BitmapFont``` in accordance with an input ```BitmapFontGenConfig```. The theme can then be applied to Godot's various text nodes.

The ```Resource``` directory contains the compiled ```Theme``` resource files.

## Usage

Here is a sample configuration, demonstrating a font which will only have numeric digits.

```gdscript
var config := BitmapFontGenConfig.new()

config.resource_save_path = "res://Fonts/Resource/<resource name>.tres"

# input images must only contain one character in the y-direction
config.charmap = preload("res://Assets/Font/<character map>.png")

config.unicode_order = Util.ordrange('0', '9')

config.width = 8
config.height = 10

config.width_exceptions[ord('1')] = 6

BitmapFontGen.generate(config)
```
