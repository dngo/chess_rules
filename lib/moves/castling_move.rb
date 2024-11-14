module ChessRules
  class CastlingMove < ChessRules::AbstractMove
    KING_SIDE = "O-O"
    QUEEN_SIDE = "O-O-O"
    TURN_COLOR_NAMES = { "w" => "white", "b" => "black" }

    CASTLING_POSITIONS = {
      'w' => {
        KING_SIDE => {
          "e1" => "K",
          "f1" => nil,
          "g1" => nil,
          "h1" => "R",
        },
        QUEEN_SIDE => {
          "a1" => "R",
          "b1" => nil,
          "c1" => nil,
          "d1" => nil,
          "e1" => "K",
        }
      },
      'b' => {
        KING_SIDE => {
          "e8" => "k",
          "f8" => nil,
          "g8" => nil,
          "h8" => "r",
        },
        QUEEN_SIDE => {
          "a8" => "r",
          "b8" => nil,
          "c8" => nil,
          "d8" => nil,
          "e8" => "k",
        }
      }
    }

    MOVES = {
      "w" => { KING_SIDE => [["e1", "h1"], ["g1", "f1"]], QUEEN_SIDE => [["e1", "a1"], ["c1", "d1"]] },
      "b" => { KING_SIDE => [["e8", "h8"], ["g8", "f8"]], QUEEN_SIDE => [["e8", "a8"], ["c8", "d8"]] },
    }

    def initialize(san, board)
      super(san, board)

      validate_castling(san, board)
      @symbol = get_symbol(board.turn_color)
      @from_squares, @to_squares = MOVES[board.turn_color][san]
    end

    private
    #TODO cannot castle when in check
    #TODO cannot castle over attacked squares
     def validate_castling(san, board)
      turn_color = board.turn_color

      CASTLING_POSITIONS[turn_color][san].each do |square, piece_symbol|
        validate_piece_position(board, square, piece_symbol)
      end
    end

    def validate_piece_position(board, square, piece_symbol)
      if piece_symbol.nil?
        raise CastlingMoveError, "#{square} square is not empty" if board.piece_at(square) != piece_symbol
      else
        raise CastlingMoveError, "#{PIECE_SYMBOL_MAP[piece_symbol]} not at #{square}" if board.piece_at(square) != piece_symbol
      end
    end

    def get_symbol(turn_color)
       turn_color == WHITE ? "K" : "k"
    end
  end
end

class CastlingMoveError < StandardError; end
