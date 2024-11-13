module ChessRules
  class PawnMove < ChessRules::StandardMove

    def initialize(notation)
      super(notation)
      @error_class = PawnMoveError
      @promotion = get_promotion(notation)
    end

    def get_char(turn_color)
       turn_color == WHITE ? "P" : "p"
    end

    # rely on StandardMove to remove capture and check, additonally remove promotion notation
    def sanitized_notation
      super.split(PROMOTION_NOTATION)[0]
    end

    private
    # split on equal sign and return first char, ignoring all check, checkmate notation that comes after
    def get_promotion(notation)
      return unless notation.include?(PROMOTION_NOTATION)

      notation.split(PROMOTION_NOTATION).last[0]
    end
  end
end

class PawnMoveError < StandardError; end
