module ChessRules
  class MoveFactory
    def self.create(san, board)
      raise NotationError.new("Unknown san: #{san}") unless algebraic?(san) || disambiguous?(san)

      if disambiguous?(san) # must come before standard? check
        return DisambiguousMove.new(san, board)
      elsif standard?(san)
        return StandardMove.new(san, board)
      elsif pawn?(san)
        return PawnMove.new(san, board)
      elsif castling?(san)
        return CastlingMove.new(san, board)
      else
        raise NotationError.new("Unknown san: #{san}")
      end
    end

    def self.algebraic?(san)
      ALGEBRAIC_REGEX.any? { |pattern| san.match?(pattern) }
    end

    def self.disambiguous?(san)
      san.match(DISAMBIGUATED_REGEX) &&
        san
          .gsub(CAPTURE_NOTATION, "")
          .gsub(CHECK_NOTATION, "")
          .gsub(CHECKMATE_NOTATION, "")
          .split(PROMOTION_NOTATION)[0].length > 3
    end

    private
    def self.standard?(san)
      STANDARD_NOTATION.include?(san[0])
    end

    def self.pawn?(san)
      PAWN_NOTATION.include?(san[0])
    end

    def self.castling?(san)
      [CastlingMove::KING_SIDE, CastlingMove::QUEEN_SIDE].include?(san)
    end
  end
end

class NotationError < StandardError; end
