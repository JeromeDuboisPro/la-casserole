@tool
extends EditorPlugin

## Registers the TapTone AAR with the Android exporter. Without this the plugin
## is never packaged and Engine.has_singleton("TapTone") stays false on device.

var _export_plugin: AndroidExportPlugin

func _enter_tree() -> void:
	_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(_export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	_export_plugin = null

class AndroidExportPlugin extends EditorExportPlugin:
	const PLUGIN_NAME := "TapTone"

	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_android_libraries(_platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		# Paths are relative to res://addons/.
		if debug:
			return PackedStringArray(["taptone/bin/debug/taptone-debug.aar"])
		return PackedStringArray(["taptone/bin/release/taptone-release.aar"])

	func _get_name() -> String:
		return PLUGIN_NAME
