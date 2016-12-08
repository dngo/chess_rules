module ChessRules
  class Chess
    include ActiveModel::Validations
    validates_with ChessRules::FenValidator

    attr_accessor :fen, :board, :turn, :castling, :ep_square, :half_moves, :move_number

    def initialize(fen = nil)
      @fen = fen || ChessRules::START
      @board = Board.new
      @turn = WHITE
      @castling = "KQkq"
      @ep_square = nil
      @half_moves = 0
      @move_number = 1
      load_fen(@fen)
    end

    def to_fen
      [board.to_fen, turn, castling, ep_square, half_moves, move_number].join(' ')
    end

    def load_fen(fen)
      tokens = fen.split(/\s+/)
      position = tokens[0]
      @turn = tokens[1]

      rank = 0
      file = 0
      position.each_char do |char|
        if char =~ /\A\d+\z/ ? true : false
          file += char.to_i
        elsif char == "/"
          #do nothing / is a row separator in the fen
        else
          board.place_piece(char, rank, file)
          file += 1
        end
        if file == Board::BOARD_SIZE #increment rank and reset file
          rank += 1
          file = 0
        end
      end

      self.castling = tokens[2]
      self.ep_square = tokens[3]
      self.half_moves = tokens[4]
      self.move_number = tokens[5]
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

      board.attacked?(swap_color(color), coordinate)
    end


    #get all pieces of current side to move,
    #for each possible move for the piece, see if the side is still in check after the move
    #if any move results in the side not being in check, then return false, its not checkmate
    def checkmate?
      return false unless in_check?(turn)

      current_side_pieces = turn == ChessRules::WHITE ? ChessRules::WHITE_PIECES : ChessRules::BLACK_PIECES

      board.board_2d.each_with_index do |chars, rank|
        chars.each.with_index do |char, file|
          if current_side_pieces.include?(char) #only want pieces of side to move
            piece = Piece.from_char(char, [rank, file], board.board_2d)
            piece.moves.each do |move|
              return false unless move_into_check?(piece, move)
            end
          end
        end

      end

      true #all moves resulted in check, so its checkmate
    end

    def stalemate?
      return false if in_check?(turn)

      current_side_pieces = turn == ChessRules::WHITE ? ChessRules::WHITE_PIECES : ChessRules::BLACK_PIECES

      board.board_2d.each_with_index do |chars, rank|
        chars.each.with_index do |char, file|
          if current_side_pieces.include?(char) #only want pieces of side to move
            piece = Piece.from_char(char, [rank, file], board.board_2d)
            piece.moves.each do |move|
              return false unless move_into_check?(piece, move)
            end
          end
        end

      end

      true #all moves resulted in check, so its checkmate
    end

    def move_into_check?(piece, end_pos)
      original_board = Marshal.load(Marshal.dump(board.board_2d)) #the only real way to copy any array, dup and clone still result in references, not true copy

      test_board = board.move(piece.position, end_pos)
      board.board_2d = test_board
      in_check = in_check?(piece.color)
      board.board_2d = original_board
      in_check
    end

    def move!(algebraic_start_pos, algebraic_end_pos)
      board.move!(Board.get_coordinates(algebraic_start_pos), Board.get_coordinates(algebraic_end_pos))
    end

    def swap_color(color)
      color == WHITE ? BLACK : WHITE
    end

  end
end
