require 'spec_helper'

describe ChessRules::StandardMove do
  describe '.new' do
    it "initializes correctly with a notation" do
      notation = "Ka2"

      move = ChessRules::StandardMove.new(notation)

      expect(move.notation).to eql("Ka2")
    end
  end

  describe '.from_to_squares' do
    it "returns for a king move" do
      board = ChessRules::Board.new("k7/8/8/8/8/8/8/8 b KQkq - 0 1")
      move = ChessRules::StandardMove.new("Ka7")

      from, to = move.from_to_squares(board)[0]

      expect(from).to eql("a8")
      expect(to).to eql("a7")
    end

    it "returns for a knight move" do
      board = ChessRules::Board.new("N7/8/8/8/8/8/8/8 w KQkq - 0 1")
      move = ChessRules::StandardMove.new("Nb6")

      from, to = move.from_to_squares(board)[0]

      expect(from).to eql("a8")
      expect(to).to eql("b6")
    end

    describe '.from_to_squares when capturing' do
      it "returns for a piece capture move" do
        board = ChessRules::Board.new("8/8/8/8/8/8/1p6/K7 w KQkq - 0 1")
        move = ChessRules::StandardMove.new("Kxb2")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a1")
        expect(to).to eql("b2")
      end

      it "returns for a checking capture move" do
        board = ChessRules::Board.new("k7/1p6/8/8/8/8/1Q6/K7 w KQkq - 0 1")
        move = ChessRules::StandardMove.new("Qxb7+")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b2")
        expect(to).to eql("b7")
      end

      it "returns for a double checking capture move" do
        board = ChessRules::Board.new("k7/1p6/B7/8/Q7/8/8/K7 w KQkq - 0 1")
        move = ChessRules::StandardMove.new("Bxb7++")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a6")
        expect(to).to eql("b7")
      end
    end

    describe '.from_to_squares when checking' do
      it "returns for a checking move" do
        board = ChessRules::Board.new("k7/8/8/8/8/8/1Q6/K7 w KQkq - 0 1")
        move = ChessRules::StandardMove.new("Qb7+")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b2")
        expect(to).to eql("b7")
      end

      it "returns for a double checking move" do
        board = ChessRules::Board.new("k7/8/B7/8/Q7/8/8/K7 w KQkq - 0 1")
        move = ChessRules::StandardMove.new("Bb7++")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a6")
        expect(to).to eql("b7")
      end
    end

    describe '.from_to_squares' do
      it "returns for checkmate" do
        board = ChessRules::Board.new("k7/8/8/8/8/8/1Q6/K7 w KQkq - 0 1")
        move = ChessRules::StandardMove.new("Qb7#")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b2")
        expect(to).to eql("b7")
      end
    end

    it "fails when it is the wrong side's turn" do
      board = ChessRules::Board.new("k7/8/8/8/8/8/8/8 w KQkq - 0 1") # black king, but it's white's turn
      move = ChessRules::StandardMove.new("Ka7")

      expect{ move.from_to_squares(board) }.to raise_error(StandardMoveError, "white king not found")
    end

    it "fails when the destination is unreachable by the current player's pieces" do
      board = ChessRules::Board.new("k7/8/8/8/8/8/8/K7 w KQkq - 0 1")
      move = ChessRules::StandardMove.new("Ka7")

      expect{ move.from_to_squares(board) }.to raise_error(StandardMoveError, "white king cannot move to a7")
    end
  end
end
