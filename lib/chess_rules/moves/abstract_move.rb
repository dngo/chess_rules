module ChessRules
  class AbstractMove
    attr_accessor :notation, :promotion
    # before: 'rnbqkbnr/pppp1ppp/8/4p3/4PP2/8/PPPP2PP/RNBQKBNR b KQkq - 0 2',
    # after: 'rnbqkbnr/pppp1ppp/8/8/4Pp2/8/PPPP2PP/RNBQKBNR w KQkq - 0 3',
    # color: 'b',
    # piece: 'p',
    # from: 'e5',
    # to: 'f4',
    # san: 'exf4',
    # lan: 'e5f4',
    # flags: 'c',
    # captured: 'p'

    def initialize(notation)
      @notation = notation
    end

    def from_to_squares
      raise NotImplementedError
    end

    def get_algebraic(coordinate)
      "#{Board::FILES[coordinate.last]}#{Board::RANKS[coordinate.first]}"
    end

    # removes capture, check, and checkmate notation
    def sanitized_notation
      notation.gsub(CAPTURE_NOTATION, "").gsub(CHECK_NOTATION, "").gsub(CHECKMATE_NOTATION, "")
    end

    def to
      sanitized_notation[-2..-1]
    end
  end
end
