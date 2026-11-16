extends Node

var run_length: float = 1800.0
var play_alive_intro: bool = false

# the world's opening narration is a one-time thing. Survives scene changes, so
# Retry does not replay it, but not an app restart.
var alive_seen := false
