extends Node

const DEFAULT_PORT = 7777

# Create the peer up front
var ws_peer := WebSocketMultiplayerPeer.new()

func _ready():
	print("--- Server.gd _ready() STARTED ---")

	# 1️⃣ Resolve port (no C‐style ternary; use an if‑block)
	var port_env = OS.get_environment("PORT")
	var port = DEFAULT_PORT
	if port_env != "":
		port = port_env.to_int()
		print("🔌 Found PORT environment variable: %d" % port)
	else:
		print("🔌 No PORT env, using default: %d" % port)

	# 2️⃣ Start WebSocket server
	var err = ws_peer.create_server(port)
	if err != OK:
		push_error("❌ Failed to start WebSocket server: %s" % err)
		get_tree().quit(1)
		return
	print("✅ WebSocket server listening on port %d" % port)

	# 3️⃣ Hook it up
	get_tree().multiplayer.multiplayer_peer = ws_peer
	ws_peer.client_connected.connect(_on_client_connected)
	ws_peer.client_disconnected.connect(_on_client_disconnected)
	ws_peer.data_received.connect(_on_data_received)

func _process(delta):
	# Poll so signals fire
	ws_peer.poll()

func _on_client_connected(id):
	print("Client connected, peer ID =", id)

func _on_client_disconnected(id):
	print("Client disconnected, peer ID =", id)

func _on_data_received(from_id: int, packet: PackedByteArray):
	var msg = packet.get_string_from_utf8()
	print("Received from %d: %s" % [from_id, msg])
