module ChessRules
  class Rook < SlidingPiece

    ROOK_DELTAS = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0]
    ]

    def display_name
      color == :black ? "♜" : "♖"
    end

    def move_dirs
      ROOK_DELTAS
    end
  end
end
