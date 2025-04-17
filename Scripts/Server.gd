extends Node

const DEFAULT_PORT = 7777
const MAX_PEERS = 4

func _ready():
	print("--- Server.gd _ready() STARTED ---")
	#
	## Get the port from the environment variable if available (for Railway)
	#var port = OS.get_environment("PORT")
	#if port == "":
		#port = DEFAULT_PORT
		#print("No PORT environment variable found, using default: %d" % port)
	#else:
		#port = port.to_int()
		#print("Found PORT environment variable: %d" % port)
#
	## Create the ENet multiplayer peer
	#var peer = ENetMultiplayerPeer.new()
	#var error = peer.create_server(port, MAX_PEERS)
#
	#if error != OK:
		#print("Error creating server: %s" % error)
		#get_tree().quit(1) # Exit with error code
		#return
#
	## Set this peer as the active multiplayer peer for the scene tree
	#get_tree().multiplayer.multiplayer_peer = peer
	#print("Relay server started on port %d. Waiting for connections..." % port)
#
	## Connect signals for peer connections and disconnections
	#get_tree().multiplayer.peer_connected.connect(_on_peer_connected)
	#get_tree().multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_peer_connected(id):
	print("Peer connected: %d" % id)

func _on_peer_disconnected(id):
	print("Peer disconnected: %d" % id)

func _process(delta):
	# Keep the server running.
	pass

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Shutdown signal received. Exiting.")
		get_tree().quit() # Graceful exit
