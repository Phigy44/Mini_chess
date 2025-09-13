extends Node2D


const BOARD_SIZE = 4
const CELL_SIZE = 80

var board = []
var current_player = "white"
var selected_piece = null
var selected_pos = Vector2(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Mini Chess startet!")
	setup_board()
	setup_pieces()
	print_board()
	queue_redraw()


func _draw():
	draw_board()
	draw_pieces()

func draw_board():
	for row in range(BOARD_SIZE):
		for col in range(BOARD_SIZE):
			var pos = Vector2(col * CELL_SIZE + 100, row *CELL_SIZE + 100)
			var rect = Rect2(pos, Vector2(CELL_SIZE,CELL_SIZE))

			var is_light = (row + col) % 2 == 0
			var color = Color.LIGHT_GRAY if is_light else Color.LIGHT_STEEL_BLUE
			# Ausgewähltes Feld hervorheben
			if selected_pos == Vector2(col, row):
				color = Color.YELLOW

			draw_rect(rect, color)
			draw_rect(rect, Color.BLACK, false,2)

func draw_pieces():
		for row in range(BOARD_SIZE):
			for col in range(BOARD_SIZE):
				var piece = board[row][col]
				if piece != null:
					draw_piece(piece,Vector2(col,row)) 


func draw_piece(piece, grid_pos):
	var screen_pos = Vector2(
		grid_pos.x * CELL_SIZE + 100 + CELL_SIZE/2,
		grid_pos.y * CELL_SIZE + 100 + CELL_SIZE/2
	)

	var symbol = get_piece_symbol(piece)
	var color = Color.WHITE if piece["color"] == "white" else Color.BLACK

	var font_size =32
	
	draw_string(ThemeDB.fallback_font, screen_pos - Vector2(10, -10), symbol, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)


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

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		print("LeftClick")
		handle_click(event.position)

func handle_click(mouse_pos):

	print("On Handle click")
	var grid_pos = screen_to_grid(mouse_pos)
	#Check if position is valid
	if not is_valid_position(grid_pos):
		print("No Valid Position")
		return
	print("Geklickt auf: ", grid_pos)

	if selected_piece == null:
		select_piece(grid_pos)
	else:
		print("Moving Piece")
		move_piece(grid_pos)


func screen_to_grid(screen_pos):
	print("On Screen position")
	print("Current ScreenPosition" , screen_pos)

	print("Y_PositionScreen ", screen_pos.x)
	print("Y_PositionScreen ", screen_pos.y)

	var grid_x = int((screen_pos.x - 100) / CELL_SIZE)
	var grid_y = int((screen_pos.y - 100) / CELL_SIZE)
	
	
	return Vector2(grid_x,grid_y)

func is_valid_position(grid_pos):
	print("Position X", grid_pos.x)
	print("Position Y", grid_pos.y)
	return grid_pos.x >=0 and grid_pos.x < BOARD_SIZE and grid_pos.y >=0 and grid_pos.y < BOARD_SIZE	

func select_piece(grid_pos):
	var piece = board[grid_pos.y][grid_pos.x]

	if piece == null:
		print("Leeres Feld!")
		return
	
	if piece["color"] != current_player:
		print("Falsche Farbe ", current_player , "ist dran")

	selected_piece = piece
	selected_pos = grid_pos
	print("Figur ausgewählt: ", piece["type"], "auf ", grid_pos)
	queue_redraw()



func move_piece(target_pos):
	var target_piece = board[target_pos.y][target_pos.y]

	print("Versuche zu bewegen nach :", target_pos)

	if not is_valid_move(selected_pos,target_pos):
		print("Ungültiger Zug")
		deselect_piece()
		return

	board[target_pos.y][target_pos.x] = selected_piece
	board[selected_pos.y][selected_pos.x] = null
	if target_piece != null:
		print("Figur geschlagen: ", target_piece["type"])
    
	print("Zug ausgeführt: ", selected_piece["type"], " von ", selected_pos, " nach ", target_pos)
    
    # Spieler wechseln
	current_player = "black" if current_player == "white" else "white"
	print("Spieler am Zug: ", current_player)
    
	deselect_piece()
	queue_redraw()


func deselect_piece():
	selected_piece = null
	selected_pos = Vector2(-1, -1)

func is_valid_move(from_pos, to_pos):
	var piece = board[from_pos.y][from_pos.x]
	var target = board[to_pos.y][to_pos.x]
	
	if target != null and target["color"] == piece["color"]:
		return false
    
    # Bewegungsregeln je nach Figurenty
	match piece["type"]:
		"king":
			return is_valid_king_move(from_pos, to_pos)
		"rook":
			return is_valid_rook_move(from_pos, to_pos)
		"pawn":
			return is_valid_pawn_move(from_pos, to_pos, piece["color"])
	return false


func is_valid_king_move(from_pos, to_pos):
    # König kann 1 Feld in jede Richtung
	var dx = abs(to_pos.x - from_pos.x)
	var dy = abs(to_pos.y - from_pos.y)
	return dx <= 1 and dy <= 1 and (dx + dy > 0)  # Nicht auf derselben Stelle

func is_valid_rook_move(from_pos, to_pos):
    # Turm kann horizontal oder vertikal
	return from_pos.x == to_pos.x or from_pos.y == to_pos.y

func is_valid_pawn_move(from_pos, to_pos, color):
	var direction = 1 if color == "white" else -1  # Weiß geht "nach oben"
	var dy = to_pos.y - from_pos.y
	var dx = abs(to_pos.x - from_pos.x)
    
    # Bauer kann nur vorwärts, 1 Feld
	return dy == -direction and dx == 0