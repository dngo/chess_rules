module ChessRules
  class AbstractMove
    attr_accessor :san, :color, :symbol, :from_squares, :to_squares, :promotion, :captured
    # before: 'rnbqkbnr/pppp1ppp/8/4p3/4PP2/8/PPPP2PP/RNBQKBNR b KQkq - 0 2',
    # after: 'rnbqkbnr/pppp1ppp/8/8/4Pp2/8/PPPP2PP/RNBQKBNR w KQkq - 0 3',
    # flags: 'c',

    def initialize(san, board)
      @san = san
      @color = board.turn_color
    end

    def lan
      "#{from_squares.first}#{to_squares.first}"
    end

    def get_from
      raise NotImplementedError
    end

    def get_algebraic(coordinate)
      "#{Board::FILES[coordinate.last]}#{Board::RANKS[coordinate.first]}"
    end

    # removes capture, check, and checkmate notation
    def sanitized_san
      san.gsub(CAPTURE_NOTATION, "").gsub(CHECK_NOTATION, "").gsub(CHECKMATE_NOTATION, "")
    end
  end
end
