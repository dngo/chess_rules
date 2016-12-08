module ChessRules
  class Bishop < SlidingPiece

    BISHOP_DELTAS = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ]

    def display_name
      color == :black ? "♝" : "♗"
    end

    def move_dirs
      BISHOP_DELTAS
    end
  end
end
