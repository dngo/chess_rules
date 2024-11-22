module ChessRules
  class PawnMove < ChessRules::StandardMove
    attr_accessor :promotion, :en_passant_square

    def initialize(san, board)
      super(san, board)
      @promotion = get_promotion(san)
      @en_passant_square = get_en_passant_square(board)
    end

    private
    # Calculate the en passant square for a double-step move
    def get_en_passant_square(board)
      return unless double_step?(board)

      file = from_squares.first[0] # Keep the file the same
      from_rank = from_squares.first[-1].to_i
      to_rank = to_squares.first[-1].to_i
      mid_rank = (from_rank + to_rank) / 2

      "#{file}#{mid_rank}"
    end

     # Determine if the pawn moved 2 squares
    def double_step?(board)
      from_rank = from_squares.first[-1].to_i
      to_rank = to_squares.first[-1].to_i
      (from_rank - to_rank).abs == 2
    end

    def error_class
      PawnMoveError
    end

    def get_symbol(turn_color)
       turn_color == WHITE ? "P" : "p"
    end

    # rely on StandardMove to remove capture and check, additonally remove promotion notation
    def sanitized_san
      super.split(PROMOTION_NOTATION)[0]
    end

    # split on equal sign and return first char, ignoring all check, checkmate notation that comes after
    def get_promotion(notation)
      return unless san.include?(PROMOTION_NOTATION)

      san.split(PROMOTION_NOTATION).last[0]
    end
  end
end

class PawnMoveError < StandardError; end
