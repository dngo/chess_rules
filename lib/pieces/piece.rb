module ChessRules
  class Piece
    attr_accessor :char, :color, :position, :board

    def initialize(char, position, board_2d)
      @char = char
      @position = position
      @color = get_color(char)
      @board = board_2d
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

    def get_color(piece_char)
      return ChessRules::WHITE if /[[:upper:]]/.match(piece_char)
      return ChessRules::BLACK if /[[:lower:]]/.match(piece_char)
    end

    def own_piece?(coordinate)
      get_color(board[coordinate.first][coordinate.last]) == get_color(self.char)
    end

    def moves_algebraic
      moves.map {|m| ChessRules::Board.get_algebraic(m) }
    end

  end
end
