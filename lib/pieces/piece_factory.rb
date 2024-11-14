module ChessRules
  class PieceFactory
    def self.create(char, position, board_2d)
      case char
      when "P", "p"
        return Pawn.new(char, position, board_2d)
      when "R", "r"
        return Rook.new(char, position, board_2d)
      when "N", "n"
        return Knight.new(char, position, board_2d)
      when "B", "b"
        return Bishop.new(char, position, board_2d)
      when "Q", "q"
        return Queen.new(char, position, board_2d)
      when "K", "k"
        return King.new(char, position, board_2d)
      else
        raise NotImplementedError.new("Unknown piece type: #{char}")
      end
    end
  end
end
