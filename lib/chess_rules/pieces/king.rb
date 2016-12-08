module ChessRules
  class King < SteppingPiece
    WHITE = 'K'
    BLACK = 'k'

    KING_DELTAS = [
      [0, 1],
      [0, -1],
      [1, 0],
      [-1, 0],
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1]
    ]

    def move_dirs
      KING_DELTAS
    end
  end
end
