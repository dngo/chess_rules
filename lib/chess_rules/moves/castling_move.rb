module ChessRules
  class CastlingMove < ChessRules::AbstractMove
    KING_SIDE = "O-O"
    QUEEN_SIDE = "O-O-O"

    KING_POSITIONS = { 'w' => "e1", 'b' => "e8" }
    ROOK_POSITIONS = {
      "w" => { KING_SIDE => "h1", QUEEN_SIDE => "a1" },
      "b" => { KING_SIDE => "h8", QUEEN_SIDE => "a8" }
    }
    KING_PIECES = { "w" => "K", "b" => "k" }
    ROOK_PIECES = { "w" => "R", "b" => "r" }
    MOVES = {
      "w" => { KING_SIDE => [["e1", "g1"], ["h1", "f1"]], QUEEN_SIDE => [["e1", "c1"], ["a1", "d1"]] },
      "b" => { KING_SIDE => [["e8", "g8"], ["h8", "f8"]], QUEEN_SIDE => [["e8", "c8"], ["a8", "d8"]] }
    }

    def from_to_squares(board)
      CastlingMove.valid_castling?(board, notation)
      CastlingMove.castling_squares(board.turn_color, notation)
    end

    private
    def self.get_castling_squares(board, notation)
      Castling.valid_castling?(board, notation)
      Castling.castling_squares(board.turn_color, notation)
    end

    def self.castling_squares(turn_color, notation)
      MOVES[turn_color][notation]
    end

    #TODO cannot castle when in check
    #TODO cannot castle over attacked squares
    def self.valid_castling?(board, notation)
      turn_color = board.turn_color
      king_position = KING_POSITIONS[turn_color]
      rook_position = ROOK_POSITIONS[turn_color][notation]
      king_piece = KING_PIECES[turn_color]
      rook_piece = ROOK_PIECES[turn_color]

      turn_color_map = { "w" => "white", "b" => "black" }
      raise CastlingMoveError.new("#{turn_color_map[turn_color]} king not at #{king_position}") if board.piece_at(king_position) != king_piece
      raise CastlingMoveError.new("#{turn_color_map[turn_color]} rook not at #{rook_position}") if board.piece_at(rook_position) != rook_piece
    end
  end
end

class CastlingMoveError < StandardError; end
