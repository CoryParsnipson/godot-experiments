extends Node

## Since dialogue-manager is registered in the game autoload, this default-dialogue-manager
## is provided here to serve as a fallback with a "null implementation".
## The functions and interface in this file should be identical to dialogue-manager so they
## can be seamlessly swapped out for each other.

func exist():
	print("[WARNING] default-dialogue-manager.exist: Default dialogue manager has been invoked.")
	print("Default Dialogue Manager does nothing!")
