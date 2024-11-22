module ChessRules
  class Chess
    include ChessApi
    include ActiveModel::Validations
    validates_with FenValidator

    attr_accessor :initial_fen, :board, :castling, :en_passant_square, :half_moves, :full_moves

    delegate :piece_at, :place_piece, :turn_color, to: :board

    private
    def move_into_check?(piece, end_pos)
      original_board = Marshal.load(Marshal.dump(board.board_2d)) #the only real way to copy any array, dup and clone still result in references, not true copy

      test_board = board.move_from_to(piece.position, end_pos)
      board.board_2d = test_board
      in_check = in_check?(piece.color)
      board.board_2d = original_board
      in_check
    end
  end
end


class IllegalMoveError < StandardError
end

