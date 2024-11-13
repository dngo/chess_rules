require "chess_rules/version"
require "chess_rules/board"
require "chess_rules/fen_validator"
require "chess_rules/chess"

require "chess_rules/moves/move_factory"
require "chess_rules/moves/abstract_move"
require "chess_rules/moves/castling_move"
require "chess_rules/moves/disambiguous_move"
require "chess_rules/moves/standard_move"
require "chess_rules/moves/pawn_move"

require "chess_rules/pieces/piece"
require "chess_rules/pieces/stepping_piece"
require "chess_rules/pieces/sliding_piece"
require "chess_rules/pieces/rook"
require "chess_rules/pieces/queen"
require "chess_rules/pieces/bishop"
require "chess_rules/pieces/king"
require "chess_rules/pieces/knight"
require "chess_rules/pieces/pawn"

module ChessRules
  STARTING_FEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
  EMPTY_FEN = '8/8/8/8/8/8/8/8 w - - 0 1'
  WHITE = 'w'
  BLACK = 'b'
  BOARD_SIZE = 8
  COLORS = [WHITE, BLACK]
  WHITE_PIECES = %w(P R N B Q K)
  BLACK_PIECES = %w(p r n b q k)
  PIECES = WHITE_PIECES + BLACK_PIECES
  PIECE_NAME_MAP = {
    "P" => "white pawn",
    "R" => "white rook",
    "N" => "white knight",
    "B" => "white bishop",
    "Q" => "white queen",
    "K" => "white king",
    "p" => "black pawn",
    "r" => "black rook",
    "n" => "black knight",
    "b" => "black bishop",
    "q" => "black queen",
    "k" => "black king",
  }

  ALGEBRAIC_REGEX = [
    /^[a-h][1-8](\+|\+\+|#)?$/,                   # Pawn move, e.g., "e4", "e4+", "e4++", or "e4#"
    /^[KQRBN][a-h][1-8](\+|\+\+|#)?$/,            # Piece move, e.g., "Nf3", "Nf3+", "Nf3++", or "Nf3#"
    /^[a-h]x[a-h][1-8](\+|\+\+|#)?$/,             # Pawn capture, e.g., "exd5", "exd5+", "exd5++", or "exd5#"
    /^[KQRBN]x[a-h][1-8](\+|\+\+|#)?$/,           # Piece capture, e.g., "Nxf3", "Nxf3+", "Nxf3++", or "Nxf3#"
    /^[a-h][18]=[QRBN](\+|\+\+|#)?$/,             # Pawn promotion, e.g., "e8=Q", "e8=Q+", "e8=Q++", or "e8=Q#"
    /^[a-h]x[a-h][18]=[QRBN](\+|\+\+|#)?$/,       # Pawn capture with promotion, e.g., "exd8=Q", "exd8=Q+", "exd8=Q++", or "exd8=Q#"
    /^O-O(\+|\+\+|#)?$/,                          # King-side castling, e.g., "O-O", "O-O+", "O-O++", or "O-O#"
    /^O-O-O(\+|\+\+|#)?$/                         # Queen-side castling, e.g., "O-O-O", "O-O-O+", "O-O-O++", or "O-O-O#"
  ]

  # matches when same pieces are on the same rank R1a5, or on the same file Qhxd8+, pawns dont have disambiguous moves
  # "Nbd2", "R1d1", "Qh4e1", "Nbd2#", "R1d1#", "Qh4e1#", "Nbxd2", "R1xd1", "Qh4xe1", "Nbxd2#", "R1xd1#", "Qh4xe1#",
  # "Nbxd2+", "R1xd1+", "Qh4xe1+", "Nbxd2++", "R1xd1++", "Qh4xe1++",
  DISAMBIGUATED_REGEX = /^[KQRBN][a-h]?[1-8]?x?[a-h][1-8](\+|\+\+|#)?$/

  PAWN_NOTATION = %w(a b c d e f g h)
  STANDARD_NOTATION = %w(R N B Q K)
  CHECK_NOTATION = "+"
  CHECKMATE_NOTATION = "#"
  CAPTURE_NOTATION = "x"
  PROMOTION_NOTATION = "="
end

