extends Node


signal on_current_clip_ammo_changed(current_clip_ammo)
signal player_health_changed(new_health: int)
signal world_progress_update(progress, map: Texture2D)
signal reload_started(duration: float)
signal on_player_heat_updated(heat: int, overheated: bool)
