extends Node

# Define the port the server will listen on.
# Railway provides the PORT environment variable, which we'll use later.
# For local testing, we can use a default like 7777.
#const SERVER_HOST = "127.0.0.1" # Connect to your local machine
const DEFAULT_PORT = 7777

# Maximum number of players/peers allowed
const MAX_PEERS = 32

# Dictionary to store peer data if needed (optional for simple relay)
# var peers = {}

func _ready():
	print("--- Server.gd _ready() STARTED ---") # Keep this

	# --- Try creating the peer ---
	var peer = ENetMultiplayerPeer.new()
	print("--- ENetMultiplayerPeer INSTANTIATED ---") # <-- ADD THIS LINE

	# --- COMMENT OUT THE REST AGAIN ---
	# var port = OS.get_environment("PORT")
	# if port == "":
	#	 port = DEFAULT_PORT
	#	 print("No PORT environment variable found, using default: %d" % port)
	# else:
	#	 port = port.to_int()
	#	 print("Found PORT environment variable: %d" % port)
	#
	# var error = peer.create_server(port, MAX_PEERS)
	#
	# if error != OK:
	#	 print("Error creating server: %s" % error)
	#	 get_tree().quit(1) # Exit with error code
	#	 return
	#
	# # Set this peer as the active multiplayer peer for the scene tree
	# get_tree().multiplayer.multiplayer_peer = peer
	# print("Relay server started on port %d. Waiting for connections..." % port)
	#
	# # Connect signals for peer connections and disconnections
	# get_tree().multiplayer.peer_connected.connect(_on_peer_connected)
	# get_tree().multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# --- END OF COMMENTED OUT SECTION ---

func _on_peer_connected(id):
	print("Peer connected: %d" % id)
	# You could add peer tracking here if needed:
	# peers[id] = {"join_time": Time.get_unix_time_from_system()}

func _on_peer_disconnected(id):
	print("Peer disconnected: %d" % id)
	# Clean up peer tracking if you added it:
	# if peers.has(id):
	#	peers.erase(id)

# --- Optional: If you needed to inspect or modify packets ---
# func _on_peer_packet(id, packet):
# 	print("Received packet from %d" % id)
# 	# Basic relay usually doesn't need to intercept packets here,
#	# as ENetMultiplayerPeer handles routing by default based on target peer ID.

func _process(delta):
	# Keep the server running.
	# You could add periodic tasks here if needed.
	pass

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Shutdown signal received. Exiting.")
		get_tree().quit() # Graceful exit
