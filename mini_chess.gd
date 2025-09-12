extends Node2D


const BOARD_SIZE = 4
const CELL_SIZE = 80

var board = []
var current_player = "white"
var selecte_piece = null
var selected_pos = Vector2(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Mini Chess startet!")
	setup_board()
	setup_pieces()
	print_board()




func setup_board():
	print("Setting UP Game")
	#clear board
	board = []

	for row in range(BOARD_SIZE):  # in Java for int i; i<Boardsize, i++
		var new_row = []
		for col in range(BOARD_SIZE):
			new_row.append(null)
		board.append(new_row)
	print("4x4 Brett erstellt")


func setup_pieces():
	 # Weiße Figuren (unten)
	board[3][0] = {"type": "rook", "color": "white"}    # Turm
	board[3][1] = {"type": "pawn", "color": "white"}    # Bauer
	board[3][2] = {"type": "pawn", "color": "white"}    # Bauer  
	board[3][3] = {"type": "king", "color": "white"}    # König
    
    # Schwarze Figuren (oben)
	board[0][0] = {"type": "king", "color": "black"}    # König
	board[0][1] = {"type": "pawn", "color": "black"}    # Bauer
	board[0][2] = {"type": "pawn", "color": "black"}    # Bauer
	board[0][3] = {"type": "rook", "color": "black"}    # Turm

	print("Figuren aufgestellt")

func print_board():
	print("\n=== MINI CHESS ===")
	for row in board:
		var line = ""
		for piece in row:
			if piece == null:
				line += " . "
			else:
				line += " " + get_piece_symbol(piece) + " "
		print(line)
	print("======================================")


func get_piece_symbol(piece):
	match piece["type"]:
		"king": return "K" if piece["color"] == "white" else "k"
		"rook": return "R" if piece["color"] == "white" else "r" 
		"pawn": return "P" if piece["color"] == "white" else "p"
		_: return "?"