module ChessRules
  class StandardMove < ChessRules::AbstractMove
    attr_accessor :error_class

    def initialize(notation)
      super(notation)
      @error_class = StandardMoveError
    end

    # takes an algebraic move like Ka2, returns [from, to] squares of the piece
    def from_to_squares(board)
      char = get_char(board.turn_color)

      error_msg = "#{PIECE_NAME_MAP[char]} not found"
      board.find_piece(char).each do |row, col|
        piece = Piece.from_char(char, [row, col], board.board_2d)
        piece.moves.each do |row, col|
          error_msg = "#{PIECE_NAME_MAP[char]} cannot move to #{to}"
          if get_algebraic([row, col]) == to # its possible for the piece to move to destination square
            return [[get_algebraic(piece.position), to]] # return pair of from, to squares
          end
        end
      end

      raise error_class.new(error_msg)
    end

    private
    def get_char(turn_color)
       turn_color == WHITE ? notation[0] : notation[0].downcase
    end
  end

end

class StandardMoveError < StandardError; end
