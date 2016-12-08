require "chess_rules/version"
require "chess_rules/board"
require "chess_rules/fen_validator"
require "chess_rules/chess"
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
  START = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
  WHITE = 'w'
  BLACK = 'b'
  WHITE_PIECES = %w(P R N B Q K)
  BLACK_PIECES = %w(p r n b q k)
  PIECES = WHITE_PIECES + BLACK_PIECES
end
