module ChessRules
  class Knight < SteppingPiece

    KNIGHT_DELTAS = [
      [2, 1],
      [1, 2],
      [2, -1],
      [1, -2],
      [-1, -2],
      [-2, -1],
      [-2, 1],
      [-1, 2]
    ]

    def display_name
      color == :black ? "♞" : "♘"
    end

    def move_dirs
      KNIGHT_DELTAS
    end

  end
end
