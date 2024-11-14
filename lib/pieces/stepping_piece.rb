module ChessRules
  class SteppingPiece < Piece

    def moves
      moves = []

      self.move_dirs.each do |delta|
        rel_pos = self.position
        rel_pos = [rel_pos[0] + delta[0], rel_pos[1] + delta[1]]
        moves << rel_pos if valid_move?(rel_pos)
      end

      moves
    end

    private

    def valid_move?(pos)
      if within_bounds?(pos)
        if board[pos.first][pos.last].nil? || !own_piece?(pos)  #moving to this square is valid if it is empty or an enemy piece
          return true
        end
      end

      false
    end

  end
end
