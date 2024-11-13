module ChessRules
  class MoveFactory
    def self.create(notation)
      raise NotationError.new("Unknown notation: #{notation}") unless algebraic?(notation) || disambiguous?(notation)

      if disambiguous?(notation) # must come before standard? check
        return DisambiguousMove.new(notation)
      elsif standard?(notation)
        return StandardMove.new(notation)
      elsif pawn?(notation)
        return PawnMove.new(notation)
      elsif castling?(notation)
        return CastlingMove.new(notation)
      else
        raise NotationError.new("Unknown notation: #{notation}")
      end
    end

    def self.algebraic?(notation)
      ALGEBRAIC_REGEX.any? { |pattern| notation.match?(pattern) }
    end

    def self.disambiguous?(notation)
      notation.match(DISAMBIGUATED_REGEX) &&
        notation
          .gsub(CAPTURE_NOTATION, "")
          .gsub(CHECK_NOTATION, "")
          .gsub(CHECKMATE_NOTATION, "")
          .split(PROMOTION_NOTATION)[0].length > 3
    end

    private
    def self.standard?(notation)
      STANDARD_NOTATION.include?(notation[0])
    end

    def self.pawn?(notation)
      PAWN_NOTATION.include?(notation[0])
    end

    def self.castling?(notation)
      [CastlingMove::KING_SIDE, CastlingMove::QUEEN_SIDE].include?(notation)
    end
  end
end

class NotationError < StandardError; end
