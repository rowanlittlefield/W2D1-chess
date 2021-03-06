require_relative "../piece/pieces"

class Board
  attr_reader :grid

  def initialize(grid = nil)
    @grid = grid ? grid : setup_grid
  end

  def move_piece(start_pos, end_pos)
    raise "invalid move" if self[start_pos].is_a?(NullPiece) || !(in_bounds?(end_pos))
    piece = self[start_pos]
    is_castle_move = piece.is_a?(King) && piece.castling_moves.include?(end_pos)
    self[end_pos] = piece
    self[start_pos] = NullPiece.instance
    piece.has_moved = true
    piece.pos = end_pos
    rook_castle_move(end_pos) if is_castle_move
  end

  def in_bounds?(pos)
    row, col = pos
    (0..7).to_a.include?(row) && (0..7).to_a.include?(col)
  end

  def in_check?(color)
    king_pos = find_king(color)
    oppo_color = (color == :white ? :black : :white)

    (0...8).any? do |i|
      (0...8).any? { |j| check_condition(oppo_color, [i, j], king_pos) }
    end
  end

  def find_king(color)
    (0...8).each do |i|
      (0...8).each do |j|
        if grid[i][j].color == color && grid[i][j].is_a?(King)
          return grid[i][j].pos
        end
      end
    end
  end

  def dup
    dupped_grid = Array.new(8) { Array.new(8) }
    new_board = Board.new(dupped_grid)

    (0...8).each do |i|
      (0...8).each { |j| dup_position(new_board, [i, j]) }
    end

    new_board
  end

  def checkmate(color)
    return false unless in_check?(color)
    (0...8).each do |i|
      (0...8).each do |j|
        if grid[i][j].color == color
          return false unless grid[i][j].valid_moves.empty?
        end
      end
    end
    true

  end

  def [](pos)
    row,col = pos
    grid[row][col]
  end

  def []=(pos,val)
    row,col = pos
    grid[row][col] = val
  end

  private

  def setup_grid
    new_grid = Array.new(8) { Array.new(8) }

    (new_grid[2..5]).each do |row|
      (0...8).each { |c| row[c] = NullPiece.instance }
    end

    place_pieces(new_grid)
    new_grid
  end

  def place_pieces(new_grid)
    place_pawns(new_grid)
    place_rooks(new_grid)
    place_knights(new_grid)
    place_bishops(new_grid)
    place_royalty(new_grid)
  end

  def place_pawns(new_grid)
    (0...8).each do |i|
      new_grid[1][i] = Pawn.new(:black,self,[1,i])
    end
    (0...8).each do |i|
      new_grid[6][i] = Pawn.new(:white,self,[6,i])
    end
  end

  def place_rooks(new_grid)
    new_grid[0][0] = Rook.new(:black, self, [0,0])
    new_grid[0][7] = Rook.new(:black, self, [0,7])
    new_grid[7][0] = Rook.new(:white, self, [7,0])
    new_grid[7][7] = Rook.new(:white, self, [7,7])
  end

  def place_knights(new_grid)
    new_grid[0][1] = Knight.new(:black, self, [0,1])
    new_grid[0][6] = Knight.new(:black, self, [0,6])
    new_grid[7][1] = Knight.new(:white, self, [7,1])
    new_grid[7][6] = Knight.new(:white, self, [7,6])
  end

  def place_bishops(new_grid)
    new_grid[0][2] = Bishop.new(:black, self, [0,2])
    new_grid[0][5] = Bishop.new(:black, self, [0,5])
    new_grid[7][2] = Bishop.new(:white, self, [7,2])
    new_grid[7][5] = Bishop.new(:white, self, [7,5])
  end

  def place_royalty(new_grid)
    new_grid[0][4] = King.new(:black, self, [0,4])
    new_grid[7][4] = King.new(:white, self, [7,4])
    new_grid[0][3] = Queen.new(:black, self, [0,3])
    new_grid[7][3] = Queen.new(:white, self, [7,3])
  end

  def check_condition(oppo_color, pos, king_pos)
    self[pos].color == oppo_color && (self[pos].moves).include?(king_pos)
  end

  def dup_position(new_board, pos)
    if self[pos] == NullPiece.instance
      new_board[pos] = NullPiece.instance
    else
      dupped_piece = self[pos].deep_dup(new_board)
      new_board[pos] = dupped_piece
    end
  end

  def rook_castle_move(end_pos)
    if end_pos == [7, 6]
      move_piece([7, 7], [7, 5])
    elsif end_pos == [7, 2]
      move_piece([7, 0], [7, 3])
    elsif end_pos == [0, 6]
      move_piece([0, 7], [0, 5])
    elsif end_pos == [0, 2]
      move_piece([0, 0], [0, 3])
    end
  end

end
