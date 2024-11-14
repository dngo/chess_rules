include ChessRules

module ChessApi
  def initialize(initial_fen = STARTING_FEN)
    self.initial_fen = initial_fen
    self.board = Board.new(initial_fen)

    tokens = initial_fen.split(/\s+/)
    self.castling = tokens[2]
    self.en_passant_square = tokens[3]
    self.half_moves = tokens[4].to_i
    self.full_moves = tokens[5].to_i
  end

  def move!(san)
    move = board.move!(san)

    self.en_passant_square = "-"
    self.half_moves += 1
    self.full_moves += 1 if move.color == BLACK # full_move incremented everytime black moves

    if move.is_a?(PawnMove)
      self.en_passant_square = move.en_passant_square || "-"
      self.half_moves = 0
    elsif move.is_a?(CastlingMove)
      self.castling = self.castling.gsub("K", "").gsub("Q", "") if move.color == WHITE
      self.castling = self.castling.gsub("k", "").gsub("q", "") if move.color == BLACK
    elsif move.is_a?(StandardMove)
      self.castling = self.castling.gsub("K", "").gsub("Q", "") if move.symbol == "K"
      self.castling = self.castling.gsub("k", "").gsub("q", "") if move.symbol == "k"
      self.castling = self.castling.gsub("K", "") if move.symbol == "R" && move.from_squares.include?("h1")
      self.castling = self.castling.gsub("Q", "") if move.symbol == "R" && move.from_squares.include?("a1")
      self.castling = self.castling.gsub("k", "") if move.symbol == "r" && move.from_squares.include?("h8")
      self.castling = self.castling.gsub("q", "") if move.symbol == "r" && move.from_squares.include?("a8")
      self.half_moves = 0 if move.captured
    end
    self.castling = "-" if self.castling.empty?

    move
  end

  def ascii
    string = ""
    board.board_2d.each do |row|
      row.each do |col|
        if col.nil?
          string << " - "
        else
          string << " #{col} "
        end
      end
      string << "\n"
    end

    string
  end

  def fen
    [board.to_fen, board.turn_color, castling, en_passant_square, half_moves, full_moves].join(' ')
  end

  def in_check?(color)
    case color
    when WHITE
      coordinate = board.find_piece(King::WHITE).flatten #flatten because there will only be 1 king
    when BLACK
      coordinate = board.find_piece(King::BLACK).flatten #flatten because there will only be 1 king
    else
      raise NotImplementedError
    end

    board.attacked?(board.swap_color(color), coordinate)
  end

  # get all pieces of current side to move,
  # for each possible move for the piece, see if the side is still in check after the move
  # if any move results in the side not being in check, then return false, its not checkmate
  def checkmate?
    return false unless in_check?(turn_color)

    current_side_pieces = turn_color == WHITE ? WHITE_PIECES : BLACK_PIECES

    board.board_2d.each_with_index do |chars, rank|
      chars.each.with_index do |char, file|
        if current_side_pieces.include?(char) #only want pieces of side to move
          piece = PieceFactory.create(char, [rank, file], board.board_2d)
          piece.moves.each do |move|
            return false unless move_into_check?(piece, move)
          end
        end
      end

    end

    true #all moves resulted in check, so its checkmate
  end

  def stalemate?
    return false if in_check?(turn_color)

    current_side_pieces = turn_color == WHITE ? WHITE_PIECES : BLACK_PIECES

    board.board_2d.each_with_index do |chars, rank|
      chars.each.with_index do |char, file|
        if current_side_pieces.include?(char) #only want pieces of side to move
          piece = PieceFactory.create(char, [rank, file], board.board_2d)
          piece.moves.each do |move|
            return false unless move_into_check?(piece, move)
          end
        end
      end

    end

    true #all moves resulted in check, so its checkmate
  end
end
