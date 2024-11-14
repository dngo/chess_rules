module ChessRules
  class SlidingPiece < Piece

    def moves
      moves = []

      self.move_dirs.each do |delta|
        rel_pos = self.position
        rel_pos = [rel_pos[0] + delta[0], rel_pos[1] + delta[1]]

        while valid_move?(rel_pos, [delta[0] * -1, delta[1] * -1])
          moves << rel_pos
          rel_pos = [rel_pos[0] + delta[0], rel_pos[1] + delta[1]]
        end
      end

      moves
    end

    private
    def valid_move?(pos, last_delta)

      if within_bounds?(pos)
        last_pos = [pos[0] + last_delta[0], pos[1] + last_delta[1]]
        if board[pos.first][pos.last].nil? || !own_piece?(pos)  #we can move to this square if it is empty or an enemy piece
          if board[last_pos.first][last_pos.last] == nil || last_pos == self.position
            return true
          end
        end
      end

      false
    end

  end
end
