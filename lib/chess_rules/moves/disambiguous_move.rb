module ChessRules
  class DisambiguousMove < ChessRules::AbstractMove
    def initialize(notation)
      super(notation)
      @error_class = DisambiguousMoveError
    end

    def from_to_squares(board)
      char = get_char(board.turn_color)

      error_msg = "#{PIECE_NAME_MAP[char]} not found"
      board.find_piece(char).each do |row, col|
        piece = Piece.from_char(char, [row, col], board.board_2d)
        piece.moves.each do |row, col|
          error_msg = "#{PIECE_NAME_MAP[char]} cannot move to #{to}"
          if get_algebraic([row, col]) == to # its possible for the piece to move to destination square
            return [[get_algebraic(piece.position), to]] if disambiguated?(get_algebraic(piece.position))
          end
        end
      end

      raise DisambiguousMoveError.new(error_msg)
    end

    def disambiguated?(square_name)
      if disambiguated_rank_and_file?
        return square_name == notation[1, 2]
      elsif disambiguated_file?
        return square_name[0] == notation[1]
      elsif disambiguated_rank?
        return square_name[-1] == notation[1]
      end

      false
    end

    private
    def disambiguated_rank?
      sanitized_notation.length == 4 && is_integer?(notation[1])
    end

    def disambiguated_file?
      sanitized_notation.length == 4 && !is_integer?(notation[1])
    end

    def disambiguated_rank_and_file?
      sanitized_notation.length == 5
    end

    def get_char(turn_color)
       turn_color == WHITE ? notation[0] : notation[0].downcase
    end

    def is_integer?(val)
      val.to_i.to_s == val
    end

  end
end

class DisambiguousMoveError < StandardError; end
