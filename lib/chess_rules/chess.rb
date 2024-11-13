module ChessRules
  class Chess
    include ActiveModel::Validations
    validates_with ChessRules::FenValidator

    attr_accessor :fen, :board, :turn_color, :castling, :ep_square, :half_moves, :move_number

    delegate :piece_at, to: :@board

    def move!(move)
      board.move!(move, turn_color)
    end

    def initialize(fen = ChessRules::STARTING_FEN)
      @fen = fen
      @board = Board.new(fen)

      tokens = fen.split(/\s+/)
      @turn_color = tokens[1]
      @castling = tokens[2]
      @ep_square = tokens[3]
      @half_moves = tokens[4]
      @move_number = tokens[5]
    end

    def to_fen
      [board.to_fen, turn_color, castling, ep_square, half_moves, move_number].join(' ')
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
      return false unless in_check?(turn_color)

      current_side_pieces = turn_color == ChessRules::WHITE ? ChessRules::WHITE_PIECES : ChessRules::BLACK_PIECES

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
      return false if in_check?(turn_color)

      current_side_pieces = turn_color == ChessRules::WHITE ? ChessRules::WHITE_PIECES : ChessRules::BLACK_PIECES

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

      test_board = board.move_from_to(piece.position, end_pos)
      board.board_2d = test_board
      in_check = in_check?(piece.color)
      board.board_2d = original_board
      in_check
    end

    def swap_color(color)
      color == WHITE ? BLACK : WHITE
    end

    def possible_moves(square)
    end

  end
end

class IllegalMoveError < StandardError
end

