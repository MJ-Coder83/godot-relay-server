extends Node

var _frame_count := 0

const DEFAULT_PORT = 7777
const MAX_PEERS = 4

func _init():
	print("🔥 Server.gd: _init called")

func _ready():
	print("--- Server.gd _ready() STARTED ---")
	
	# 1️⃣ Get the port from the environment variable (Railway sets PORT)
	var port_env = OS.get_environment("PORT")
	var port = DEFAULT_PORT
	if port_env != "":
		port = port_env.to_int()
		print("🔌 Found PORT environment variable: %d" % port)
	else:
		print("🔌 No PORT environment variable found, using default: %d" % port)
	
	# 2️⃣ Create the ENet server peer
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PEERS)
	if error != OK:
		push_error("❌ Failed to create ENet server: %s" % error)
		get_tree().quit(1)
		return
	
	# 3️⃣ Assign it to the SceneTree
	get_tree().multiplayer.multiplayer_peer = peer
	print("✅ Relay server started on port %d" % port)
	
	# 4️⃣ Connect signals for peer connections/disconnections
	get_tree().multiplayer.peer_connected.connect(_on_peer_connected)
	get_tree().multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _process(delta):
	_frame_count += 1
	if _frame_count % 60 == 0:  # every 60 frames
		print("🔥 Server.gd: _process() heartbeat")

func _on_peer_connected(id):
	print("Peer connected: %d" % id)

func _on_peer_disconnected(id):
	print("Peer disconnected: %d" % id)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Shutdown signal received. Exiting.")
		get_tree().quit()  # Graceful exit
