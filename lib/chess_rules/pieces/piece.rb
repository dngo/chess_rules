module ChessRules
  class Piece
    attr_accessor :char, :color, :position, :board

    def initialize(char, position, board_2d)
      @char = char
      @color = get_color(char)
      @position = position
      @board = board_2d
    end

    def self.from_char(char, position, board_2d)
      case char
      when "P", "p"
        return ChessRules::Pawn.new(char, position, board_2d)
      when "R", "r"
        return ChessRules::Rook.new(char, position, board_2d)
      when "N", "n"
        return ChessRules::Knight.new(char, position, board_2d)
      when "B", "b"
        return ChessRules::Bishop.new(char, position, board_2d)
      when "Q", "q"
        return ChessRules::Queen.new(char, position, board_2d)
      when "K", "k"
        return ChessRules::King.new(char, position, board_2d)
      else
        raise NotImplementedError
      end
    end

    def moves
      raise NotImplementedError
    end

    def valid_moves
      raise NotImplementedError
    end

    def within_bounds?(pos)
      pos.all? { |coord| (0...8).include?(coord) }
    end

    def get_color(char)
      return ChessRules::WHITE if /[[:upper:]]/.match(char)
      return ChessRules::BLACK if /[[:lower:]]/.match(char)
    end

    def own_piece?(coordinate)
      get_color(board[coordinate.first][coordinate.last]) == get_color(self.char)
    end

    def moves_algebraic
      moves.map {|m| ChessRules::Board.get_algebraic(m) }
    end

  end
end
