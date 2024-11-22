require "active_model"

module ChessRules
  class FenValidator < ActiveModel::Validator
    attr_accessor :chess
    def validate(chess)
      @chess = chess

      tokens = chess.initial_fen.split(/\s+/)
      chess.errors.add(:base, "FEN string must contain six space delimited fields") unless tokens.count == 6

      position, turn_color, castling, en_passant, half_move, move_num = tokens

      chess.errors.add(:invalid_position, "no black king") unless position.include?("k")
      chess.errors.add(:invalid_position, "no white king") unless position.include?("K")
      chess.errors.add(:invalid_position, "more than 1 white king") if position.count("K") > 1
      chess.errors.add(:invalid_position, "more than 1 black king") if position.count("k") > 1

      chess.errors.add(:half_move, "must be a positive integer") unless is_number?(half_move) && half_move.to_i >= 0
      chess.errors.add(:move_num, "must be a positive integer") unless is_number?(move_num) && move_num.to_i >= 0

      chess.errors.add(:en_passant_invalid, "square is invalid") unless /^(-|[abcdefgh][36])$/.match(tokens[3])
      chess.errors.add(:en_passant_invalid, "the white pawn has just moved, it cannot be whites turn") if en_passant && en_passant.include?("3") && turn_color == "w"
      chess.errors.add(:en_passant_invalid, "the black pawn has just moved, it cannot be blacks turn") if en_passant && en_passant.include?("6") && turn_color == "b"

      castling ||= ''
      chess.errors.add(:castling, "string is invalid") unless castling.split('').all?{|char| %w[K Q k q -].include?(char) }
      chess.errors.add(:turn_color, "must be w or b") unless /^(w|b)$/.match(turn_color)

      rows = position.split('/')
      chess.errors.add(:position, "must have 8 rows") unless rows.count == BOARD_SIZE

      rows.each do |row|
        sum_columns = 0
        previous_was_number = false

        row.each_char do |char|
          if is_number?(char)
            if previous_was_number
              chess.errors.add(:position, "is invalid: consecutive numbers #{char}")
              break
            else
              previous_was_number = true
              sum_columns += char.to_i
            end
          else
            unless /^[prnbqkPRNBQK]$/.match(char)
              chess.errors.add(:position, "invalid piece #{char}")
              break
            else
              sum_columns += 1
              previous_was_number = false
            end
          end
        end

        chess.errors.add(:position, "row has #{sum_columns} columns, 8 required for each row") unless sum_columns == BOARD_SIZE
      end

      if chess.errors.empty? #if there are already validation errors not need to validate further
        validate_pawns(rows)
        validate_castling
        validate_check
      end

      chess.errors.empty?
    end

    def validate_pawns(rows)
      if rows.first.include?("p") || rows.first.include?("P")
        chess.errors.add(:invalid_position, "there cannot be a pawn on black's promotion row")
      elsif rows.last.include?("p") || rows.last.include?("P")
        chess.errors.add(:invalid_position, "there cannot be a pawn on white's promotion row")
      end
    end

    def validate_check
      if chess.turn_color == WHITE && chess.in_check?(BLACK)
        chess.errors.add(:invalid_position, "it cannot be white's turn when black is in check")
      elsif chess.turn_color == BLACK && chess.in_check?(WHITE)
        chess.errors.add(:invalid_position, "it cannot be black's turn when white is in check")
      end
    end

    def validate_castling
      if chess.castling.include?("K")
        chess.errors.add(:castling, 'Invalid white kingside, king out of position') unless chess.board.piece_at('e1') == "K"
        chess.errors.add(:castling, 'Invalid white kingside, rook out of position') unless chess.board.piece_at('h1') == "R"
      end
      if chess.castling.include?("Q")
        chess.errors.add(:castling, 'Invalid white queenside, king out of position') unless chess.board.piece_at('e1') == "K"
        chess.errors.add(:castling, 'Invalid white queenside, rook out of position') unless chess.board.piece_at('a1') == "R"
      end
      if chess.castling.include?("k")
        chess.errors.add(:castling, 'Invalid black kingside, king out of position') unless chess.board.piece_at('e8') == "k"
        chess.errors.add(:castling, 'Invalid black kingside, rook out of position') unless chess.board.piece_at('h8') == "r"
      end
      if chess.castling.include?("q")
        chess.errors.add(:castling, 'Invalid black queenside, king out of position') unless chess.board.piece_at('e8') == "k"
        chess.errors.add(:castling, 'Invalid black queenside, rook out of position') unless chess.board.piece_at('a8') == "r"
      end
    end

    def is_number?(string)
      true if Float(string) rescue false
    end
  end
end
