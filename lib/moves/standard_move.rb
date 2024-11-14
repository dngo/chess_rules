module ChessRules
  class StandardMove < ChessRules::AbstractMove
    def initialize(san, board)
      super(san, board)
      @symbol = get_symbol(board.turn_color)
      @from_squares = [get_from(board)]
      @to_squares = [get_to]
      @captured = get_captured(board, to_squares.first)
    end

    private
    def error_class
      StandardMoveError
    end

    def get_from(board)
      error_msg = "#{PIECE_SYMBOL_MAP[symbol]} not found"
      board.find_piece(symbol).each do |row, col|
        piece = PieceFactory.create(symbol, [row, col], board.board_2d)
        piece.moves.each do |row, col|
          error_msg = "#{PIECE_SYMBOL_MAP[symbol]} cannot move to #{get_to}"
          if get_algebraic([row, col]) == get_to # its possible for the piece to move to destination square
            return get_algebraic(piece.position)
          end
        end
      end
      raise error_class.new(error_msg)
    end

    def get_captured(board, square)
      board.piece_at(square)
    end

    def get_to
      sanitized_san[-2..-1]
    end

    def get_symbol(turn_color)
      turn_color == WHITE ? san[0] : san[0].downcase
    end
  end
end

class StandardMoveError < StandardError; end
