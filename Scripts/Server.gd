extends Node

const DEFAULT_PORT = 7777
const MAX_PEERS = 4

var _frame_count := 0

func _init():
	print("🔥 Server.gd: _init called")

func _ready():
	print("--- Server.gd _ready() STARTED ---")

	var port_env = OS.get_environment("PORT")
	var port = port_env.to_int() if port_env != "" else DEFAULT_PORT

	if port_env != "":
		print("🔌 Found PORT environment variable: %d" % port)
	else:
		print("❓ No PORT variable, using default: %d" % port)

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PEERS)
	
	if error != OK:
		print("❌ Error creating server: %s" % error)
		get_tree().quit(1)
		return
	
	get_tree().multiplayer.multiplayer_peer = peer
	print("✅ Relay server started on port %d. Waiting for connections..." % port)

	get_tree().multiplayer.peer_connected.connect(_on_peer_connected)
	get_tree().multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id):
	print("🟢 Peer connected: %d" % id)

func _on_peer_disconnected(id):
	print("🔴 Peer disconnected: %d" % id)


func _process(_delta):
	_frame_count += 1
	#if _frame_count % 20 == 0:
		#print("🔥 Server.gd: _process() heartbeat")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("👋 Shutdown signal received. Exiting.")
		get_tree().quit()
