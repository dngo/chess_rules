module ChessRules
  class DisambiguousMove < ChessRules::AbstractMove
    def initialize(san, board)
      super(san, board)
      @symbol = get_symbol(board.turn_color)
      @from_squares = [get_from(board)]
      @to_squares = [get_to]
    end

    def get_from(board)
      error_msg = "#{PIECE_SYMBOL_MAP[symbol]} not found"
      board.find_piece(symbol).each do |row, col|
        piece = PieceFactory.create(symbol, [row, col], board.board_2d)
        piece.moves.each do |row, col|
          error_msg = "#{PIECE_SYMBOL_MAP[symbol]} cannot move to #{get_to}"
          if get_algebraic([row, col]) == get_to # its possible for the piece to move to destination square
            return get_algebraic(piece.position) if disambiguated?(get_algebraic(piece.position))
          end
        end
      end

      raise error_class.new(error_msg)
    end

    def disambiguated?(square_name)
      if disambiguated_rank_and_file?
        return square_name == san[1, 2]
      elsif disambiguated_file?
        return square_name[0] == san[1]
      elsif disambiguated_rank?
        return square_name[-1] == san[1]
      end

      false
    end

    private
    def error_class
      DisambiguousMoveError
    end

    def get_to
      sanitized_san[-2..-1]
    end

    def get_symbol(turn_color)
      turn_color == WHITE ? san[0] : san[0].downcase
    end

    def disambiguated_rank?
      sanitized_san.length == 4 && is_integer?(san[1])
    end

    def disambiguated_file?
      sanitized_san.length == 4 && !is_integer?(san[1])
    end

    def disambiguated_rank_and_file?
      sanitized_san.length == 5
    end

    def is_integer?(val)
      val.to_i.to_s == val
    end

  end
end

class DisambiguousMoveError < StandardError; end
