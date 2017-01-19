require "active_model"

module ChessRules
  class FenValidator < ActiveModel::Validator
    attr_accessor :chess
    def validate(chess)
      @chess = chess

      tokens = chess.fen.split(/\s+/)
      position, move_color, castling, en_passant, half_move, move_num = tokens

      chess.errors[:base] = "FEN string must contain six space delimited fields" unless tokens.count == 6
      chess.errors[:invalid_position] = 'no black king' unless position.include?("k")
      chess.errors[:invalid_position] = 'no white king' unless position.include?("K")
      chess.errors[:half_move] = "must be a positive integer" unless is_number?(half_move) && half_move.to_i >= 0
      chess.errors[:move_num] = "must be a positive integer" unless is_number?(move_num) && move_num.to_i >= 0

      chess.errors[:en_passant_invalid] = "square is invalid" unless /^(-|[abcdefgh][36])$/.match(tokens[3])
      chess.errors[:en_passant_invalid] = "the white pawn has just moved, it cannot be whites turn" if en_passant && en_passant.include?("3") && move_color == "w"
      chess.errors[:en_passant_invalid] = "the black pawn has just moved, it cannot be blacks turn" if en_passant && en_passant.include?("6") && move_color == "b"

      chess.errors[:castling] = "string is invalid" unless /^(KQ?k?q?|Qk?q?|kq?|q|-)$/.match(castling)
      chess.errors[:move_color] = "must be w or b" unless /^(w|b)$/.match(move_color)

      rows = position.split('/')
      chess.errors[:position] = "must have 8 rows" unless rows.count == Board::BOARD_SIZE

      rows.each do |row|
        sum_columns = 0;
        previous_was_number = false

        row.each_char do |char|
          if is_number?(char)
            if previous_was_number
              chess.errors[:position] = "is invalid: consecutive numbers #{char}"
              break
            else
              previous_was_number = true
              sum_columns += char.to_i
            end
          else
            unless /^[prnbqkPRNBQK]$/.match(char)
              chess.errors[:position] = "invalid piece #{char}"
              break
            else
              sum_columns += 1
              previous_was_number = false
            end
          end
        end

        chess.errors[:position] = "row has #{sum_columns} columns, 8 required for each row" unless sum_columns == Board::BOARD_SIZE
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
        chess.errors.add(:invalid_position, "there cannot be a pawn on white's promotion row")
      elsif rows.last.include?("p") || rows.last.include?("P")
        chess.errors.add(:invalid_position, "there cannot be a pawn on black's promotion row")
      end
    end

    def validate_check
      if chess.turn == ChessRules::WHITE && chess.in_check?(ChessRules::BLACK)
        chess.errors.add(:invalid_position, "it cannot be white's turn when black is in check")
      elsif chess.turn == ChessRules::BLACK && chess.in_check?(ChessRules::WHITE)
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
