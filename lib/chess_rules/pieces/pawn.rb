module ChessRules
  class Pawn < Piece
    WHITE = 'P'
    BLACK = 'p'

    ATTACK_DELTA = {
    'b' => [[1, 1], [1, -1]],
    'w' => [[-1, -1], [-1, 1]]
    }
    MOVE_DELTA = {
    'b' => [1, 0],
    'w' => [-1, 0]
    }

    def moves(in_check = false)
      moves = []

      ATTACK_DELTA[color].each do |delta|
        rel_pos = self.position
        rel_pos = [rel_pos[0] + delta[0], rel_pos[1] + delta[1]]
        moves << rel_pos if valid_attack_move?(rel_pos)
      end

      #can move forward 2 if on starting row
      multiplier = 1
      multiplier = 2 if color == ChessRules::BLACK && position[0] == 1
      multiplier = 2 if color == ChessRules::WHITE && position[0] == 6

      rel_pos = self.position
      multiplier.times do
        rel_pos = [rel_pos[0] + MOVE_DELTA[color][0], rel_pos[1] + MOVE_DELTA[color][1]]
        if valid_move?(rel_pos)
          moves << rel_pos
        else
          break #pawn is blocked from moving forward by another piece
        end
      end

      moves
    end

    def valid_attack_move?(pos)
      within_bounds?(pos) && board[pos.first][pos.last] && !own_piece?(pos) #pawn attack
    end

    def valid_move?(pos)
      #can move forward if space in nil
      within_bounds?(pos) && board[pos.first][pos.last].nil?
    end

  end
end
