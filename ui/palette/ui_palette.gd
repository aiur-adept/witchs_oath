extends Resource
class_name UIPalette

@export_group("Core Colors")
@export var background: Color = Color(0.050, 0.055, 0.090, 1.0)
@export var surface_low: Color = Color(0.090, 0.098, 0.145, 1.0)
@export var surface: Color = Color(0.120, 0.130, 0.185, 1.0)
@export var surface_high: Color = Color(0.165, 0.176, 0.240, 1.0)
@export var outline: Color = Color(0.310, 0.300, 0.250, 1.0)

@export_group("Accent Colors")
@export var accent_gold: Color = Color(0.878, 0.725, 0.408, 1.0)
@export var accent_gold_soft: Color = Color(0.725, 0.596, 0.341, 1.0)
@export var accent_info: Color = Color(0.520, 0.670, 0.870, 1.0)
@export var accent_success: Color = Color(0.420, 0.760, 0.590, 1.0)
@export var accent_danger: Color = Color(0.890, 0.410, 0.430, 1.0)

@export_group("Typography")
@export var text_primary: Color = Color(0.940, 0.930, 0.900, 1.0)
@export var text_secondary: Color = Color(0.720, 0.730, 0.780, 1.0)
@export var text_on_accent: Color = Color(0.130, 0.100, 0.060, 1.0)
@export var heading_scale: float = 1.618

@export_group("Golden Ratio Spacing")
@export var spacing_xs: int = 6
@export var spacing_sm: int = 10
@export var spacing_md: int = 16
@export var spacing_lg: int = 26
@export var spacing_xl: int = 42

@export_group("Golden Ratio Radius")
@export var radius_sm: int = 8
@export var radius_md: int = 13
@export var radius_lg: int = 21

@export_group("Buttons")
@export var button_min_height: float = 50.0
@export var button_pad_x: float = 21.0
@export var button_pad_y: float = 13.0
