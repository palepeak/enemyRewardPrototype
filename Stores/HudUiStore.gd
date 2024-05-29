extends Node


signal on_current_clip_ammo_changed(current_clip_ammo)
signal player_health_changed(new_health: int)
signal world_progress_update(progress, map: Texture2D)
signal reload_started(duration: float)
signal on_player_heat_updated(heat: int, overheated: bool)
signal on_ember_count_changed(ember_count: int)
signal on_ember_progress_changed(ember_progress: float)
signal on_item_pickup(name: String, image: Texture2D)
signal show_dialog(msg: String)
signal create_treasure_indicator(treasure: TreasureChest)
signal show_ember_progress()
