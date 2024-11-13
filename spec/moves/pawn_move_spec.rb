require 'spec_helper'

describe ChessRules::PawnMove do
  describe '.new' do
    it "initializes correctly for notation" do
      notation = "e4"

      move = ChessRules::PawnMove.new(notation)

      expect(move.notation).to eql("e4")
    end

    it "initializes correctly for notation with promotion" do
      move = ChessRules::PawnMove.new("e8=Q")
      expect(move.notation).to eql("e8=Q")
      expect(move.promotion).to eql("Q")

      move = ChessRules::PawnMove.new("e8=Q+") # promotion and check
      expect(move.notation).to eql("e8=Q+")
      expect(move.promotion).to eql("Q")

      move = ChessRules::PawnMove.new("e8=Q++") # promotion and double check
      expect(move.notation).to eql("e8=Q++")
      expect(move.promotion).to eql("Q")

      move = ChessRules::PawnMove.new("e8=Q#") # checkmate
      expect(move.notation).to eql("e8=Q#")
      expect(move.promotion).to eql("Q")
    end
  end

  describe '.from_to_squares' do
    it "returns for a pawn move" do
      board = ChessRules::Board.new(ChessRules::STARTING_FEN)
      move = ChessRules::PawnMove.new("e4")

      from, to = move.from_to_squares(board)[0]

      expect(from).to eql("e2")
      expect(to).to eql("e4")
    end

    it "fails when it is the wrong side's turn" do
      board = ChessRules::Board.new("8/1p6/8/8/8/8/8/8 w KQkq - 0 1") # black pawn, but it's white's turn
      move = ChessRules::PawnMove.new("b6")

      expect{ move.from_to_squares(board) }.to raise_error(PawnMoveError, "white pawn not found")
    end

    it "fails when the destination is unreachable by the current player's pieces" do
      board = ChessRules::Board.new("8/8/8/8/8/8/P7/8 w KQkq - 0 1")
      move = ChessRules::PawnMove.new("h2")

      expect{ move.from_to_squares(board) }.to raise_error(PawnMoveError, "white pawn cannot move to h2")
    end

    describe '.from_to_squares when capturing' do
      it "returns for a pawn capture" do
        board = ChessRules::Board.new("8/8/8/8/8/1q6/P7/8 w - - 0 1")
        move = ChessRules::PawnMove.new("axb3")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a2")
        expect(to).to eql("b3")
      end

      it "returns for a checking capture move" do
        board = ChessRules::Board.new("k7/1q6/P7/8/8/8/8/K7 w KQkq - 0 1")
        move = ChessRules::PawnMove.new("axb7+")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a6")
        expect(to).to eql("b7")
      end

      it "returns for a double checking capture move" do
        board = ChessRules::Board.new("k7/1p6/P7/8/Q7/8/8/K7 w KQkq - 0 1")
        move = ChessRules::PawnMove.new("axb7++")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a6")
        expect(to).to eql("b7")
      end
    end

    describe '.from_to_squares when checking' do
      it "returns for a checking move" do
        board = ChessRules::Board.new("k7/8/1P6/8/8/8/8/K7 w KQkq - 0 1")
        move = ChessRules::PawnMove.new("b7+")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b6")
        expect(to).to eql("b7")
      end

      it "returns for a double checking move" do
        board = ChessRules::Board.new("8/8/8/8/QPk5/8/8/8 w KQkq - 0 1")
        move = ChessRules::PawnMove.new("b5++") # hacky, its not really a double check

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b4")
        expect(to).to eql("b5")
      end
    end

    describe '.from_to_squares' do
      it "returns for checkmate" do
        board = ChessRules::Board.new("k7/7R/1PN5/8/8/8/8/K7 w KQkq - 0 1")
        move = ChessRules::PawnMove.new("b7#")

        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b6")
        expect(to).to eql("b7")
      end
    end

    it "returns for a pawn promotion" do
      board = ChessRules::Board.new("8/P7/8/8/8/8/8/8 w KQkq - 0 1")
      move = ChessRules::PawnMove.new("a8=Q")

      from, to = move.from_to_squares(board)[0]

      expect(to).to eql("a8")
    end
  end
end
