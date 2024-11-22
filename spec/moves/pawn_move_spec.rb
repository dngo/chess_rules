require 'spec_helper'
include ChessRules

describe PawnMove do
  describe '.new' do
    it "initializes correctly for a white piece" do
      board = Board.new(STARTING_FEN)

      move = PawnMove.new("e4", board)

      expect(move.san).to eql("e4")
      expect(move.color).to eql(board.turn_color)
      expect(move.symbol).to eql("P")
      expect(move.from_squares).to eql(["e2"])
      expect(move.to_squares).to eql(["e4"])
      expect(move.lan).to eql("e2e4")
    end

    it "initializes correctly for a black piece" do
      board = Board.new("8/p7/8/8/8/8/8/8 b KQkq - 0 1")

      move = PawnMove.new("a5", board)

      expect(move.san).to eql("a5")
      expect(move.color).to eql(board.turn_color)
      expect(move.symbol).to eql("p")
      expect(move.from_squares).to eql(["a7"])
      expect(move.to_squares).to eql(["a5"])
    end

    it "initializes correctly for a promotion" do
      board = Board.new("8/4P3/8/8/8/8/8/8 w KQkq - 0 1")

      move = PawnMove.new("e8=Q", board)

      expect(move.san).to eql("e8=Q")
      expect(move.promotion).to eql("Q")

      move = PawnMove.new("e8=Q+", board) # promotion and check
      expect(move.san).to eql("e8=Q+")
      expect(move.promotion).to eql("Q")

      move = PawnMove.new("e8=Q++", board) # promotion and double check
      expect(move.san).to eql("e8=Q++")
      expect(move.promotion).to eql("Q")

      move = PawnMove.new("e8=Q#", board) # checkmate
      expect(move.san).to eql("e8=Q#")
      expect(move.promotion).to eql("Q")
    end
  end

  describe 'fails when' do
    it "is the wrong side's turn" do
      board = Board.new("8/1p6/8/8/8/8/8/8 w KQkq - 0 1") # black pawn, but it's white's turn

      expect{ PawnMove.new("b6", board) }.to raise_error(PawnMoveError, "white pawn not found")
    end

    it "the destination is unreachable by the current player's pieces" do
      board = Board.new("8/8/8/8/8/8/P7/8 w KQkq - 0 1")

      expect{ PawnMove.new("h2", board) }.to raise_error(PawnMoveError, "white pawn cannot move to h2")
    end
  end

  describe 'when capturing' do
    it "returns for a pawn capture" do
      board = Board.new("8/8/8/8/8/1q6/P7/8 w - - 0 1")

      move = PawnMove.new("axb3", board)

      expect(move.from_squares).to eql(["a2"])
      expect(move.to_squares).to eql(["b3"])
      expect(move.captured).to eql("q")
    end

    it "returns for a checking capture move" do
      board = Board.new("k7/1q6/P7/8/8/8/8/K7 w KQkq - 0 1")

      move = PawnMove.new("axb7+", board)

      expect(move.from_squares).to eql(["a6"])
      expect(move.to_squares).to eql(["b7"])
      expect(move.captured).to eql("q")
    end

    it "returns for a double checking capture move" do
      board = Board.new("k7/1p6/P7/8/Q7/8/8/K7 w KQkq - 0 1")
      puts board.to_fen

      move = PawnMove.new("axb7++", board)

      expect(move.from_squares).to eql(["a6"])
      expect(move.to_squares).to eql(["b7"])
      expect(move.captured).to eql("p")
    end
  end

  describe 'when checking' do
    it "returns for a checking move" do
      board = Board.new("k7/8/1P6/8/8/8/8/K7 w KQkq - 0 1")

      move = PawnMove.new("b7+", board)

      expect(move.from_squares).to eql(["b6"])
      expect(move.to_squares).to eql(["b7"])
    end

    it "returns for a double checking move" do
      board = Board.new("8/8/8/8/QPk5/8/8/8 w KQkq - 0 1")

      move = PawnMove.new("b5++", board) # hacky, its not really a double check

      expect(move.from_squares).to eql(["b4"])
      expect(move.to_squares).to eql(["b5"])
    end
  end

  describe 'when checkmate' do
    it "returns for checkmate" do
      board = Board.new("k7/7R/1PN5/8/8/8/8/K7 w KQkq - 0 1")

      move = PawnMove.new("b7#", board)

      expect(move.from_squares).to eql(["b6"])
      expect(move.to_squares).to eql(["b7"])
    end
  end

  describe 'en_passant_square' do
    it "is populated when the pawn has taken a double step" do
      board = Board.new

      move = PawnMove.new("e4", board)

      expect(move.en_passant_square).to eql("e3")
    end

    it "is not populated for 1 step moves" do
      board = Board.new

      move = PawnMove.new("e3", board)

      expect(move.en_passant_square).to be_nil
    end
  end
end
