require 'spec_helper'
include ChessRules

describe StandardMove do
  describe '.new' do
    it "initializes correctly for a white piece" do
      board = Board.new("8/8/8/8/8/8/8/4K3 w KQkq - 0 1")

      move = StandardMove.new("Ke2", board)

      expect(move.san).to eql("Ke2")
      expect(move.color).to eql(board.turn_color)
      expect(move.symbol).to eql("K")
      expect(move.from_squares).to eql(["e1"])
      expect(move.to_squares).to eql(["e2"])
      expect(move.captured).to be_nil
      expect(move.lan).to eql("e1e2")
    end

    it "initializes correctly for a black piece" do
      board = Board.new("8/8/8/8/8/8/8/4k3 b KQkq - 0 1")

      move = StandardMove.new("Ke2", board)

      expect(move.san).to eql("Ke2")
      expect(move.color).to eql(board.turn_color)
      expect(move.symbol).to eql("k")
      expect(move.from_squares).to eql(["e1"])
      expect(move.to_squares).to eql(["e2"])
    end

    it "returns for a king move" do
      board = Board.new("k7/8/8/8/8/8/8/8 b KQkq - 0 1")

      move = StandardMove.new("Ka7", board)

      expect(move.from_squares).to eql(["a8"])
      expect(move.to_squares).to eql(["a7"])
    end

    it "returns for a knight move" do
      board = Board.new("N7/8/8/8/8/8/8/8 w KQkq - 0 1")

      move = StandardMove.new("Nb6", board)

      expect(move.from_squares).to eql(["a8"])
      expect(move.to_squares).to eql(["b6"])
    end

    describe 'when capturing' do
      it "returns for a piece capture move" do
        board = Board.new("8/8/8/8/8/8/1p6/K7 w KQkq - 0 1")
        puts board.to_fen

        move = StandardMove.new("Kxb2", board)

        expect(move.from_squares).to eql(["a1"])
        expect(move.to_squares).to eql(["b2"])
        expect(move.captured).to eql("p")
      end

      it "returns for a checking capture move" do
        board = Board.new("k7/1p6/8/8/8/8/1Q6/K7 w KQkq - 0 1")

        move = StandardMove.new("Qxb7+", board)

        expect(move.from_squares).to eql(["b2"])
        expect(move.to_squares).to eql(["b7"])
        expect(move.captured).to eql("p")
      end

      it "returns for a double checking capture move" do
        board = Board.new("k7/1p6/B7/8/Q7/8/8/K7 w KQkq - 0 1")

        move = StandardMove.new("Bxb7++", board)

        expect(move.from_squares).to eql(["a6"])
        expect(move.to_squares).to eql(["b7"])
        expect(move.captured).to eql("p")
      end
    end

    describe 'when checking' do
      it "returns for a checking move" do
        board = Board.new("k7/8/8/8/8/8/1Q6/K7 w KQkq - 0 1")

        move = StandardMove.new("Qb7+", board)

        expect(move.from_squares).to eql(["b2"])
        expect(move.to_squares).to eql(["b7"])
      end

      it "returns for a double checking move" do
        board = Board.new("k7/8/B7/8/Q7/8/8/K7 w KQkq - 0 1")

        move = StandardMove.new("Bb7++", board)

        expect(move.from_squares).to eql(["a6"])
        expect(move.to_squares).to eql(["b7"])
      end
    end

    describe 'when checkmate' do
      it "returns for checkmate" do
        board = Board.new("k7/8/8/8/8/8/1Q6/K7 w KQkq - 0 1")

        move = StandardMove.new("Qb7#", board)

        expect(move.from_squares).to eql(["b2"])
        expect(move.to_squares).to eql(["b7"])
      end
    end
    describe 'failing' do
      it "fails when it is the wrong side's turn" do
        board = Board.new("k7/8/8/8/8/8/8/8 w KQkq - 0 1") # black king, but it's white's turn

        expect { StandardMove.new("Ka7", board) }.to raise_error(StandardMoveError, "white king not found")
      end

      it "fails when the destination is unreachable by the current player's pieces" do
        board = Board.new("k7/8/8/8/8/8/8/K7 w KQkq - 0 1")

        expect { StandardMove.new("Ka7", board) }.to raise_error(StandardMoveError, "white king cannot move to a7")
      end
    end
  end
end
