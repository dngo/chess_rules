require 'spec_helper'

describe ChessRules::CastlingMove do
  describe '.new' do
    it "initializes correctly with a notation" do
      notation = "O-O"

      move = ChessRules::CastlingMove.new(notation)

      expect(move.notation).to eql("O-O")
    end
  end

  describe '.from_to_squares when castling' do
    it "returns squares when white is castling kingside" do
      board = ChessRules::Board.new("8/8/8/8/8/8/8/4K2R w KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O")

      king_moves, rook_moves = move.from_to_squares(board)
      king_from, king_to = king_moves
      rook_from, rook_to = rook_moves

      expect(king_from).to eql("e1")
      expect(king_to).to eql("g1")
      expect(rook_from).to eql("h1")
      expect(rook_to).to eql("f1")
    end

    it "returns squares when white is castling queenside" do
      board = ChessRules::Board.new("8/8/8/8/8/8/8/R3K3 w KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O-O")

      king_moves, rook_moves = move.from_to_squares(board)
      king_from, king_to = king_moves
      rook_from, rook_to = rook_moves

      expect(king_from).to eql("e1")
      expect(king_to).to eql("c1")
      expect(rook_from).to eql("a1")
      expect(rook_to).to eql("d1")
    end

    it "returns squares when black is castling kingside" do
      board = ChessRules::Board.new("4k2r/8/8/8/8/8/8/8 b KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O")

      king_moves, rook_moves = move.from_to_squares(board)
      king_from, king_to = king_moves
      rook_from, rook_to = rook_moves

      expect(king_from).to eql("e8")
      expect(king_to).to eql("g8")
      expect(rook_from).to eql("h8")
      expect(rook_to).to eql("f8")
    end

    it "returns squares when black is castling queenside" do
      board = ChessRules::Board.new("r3k3/8/8/8/8/8/8/8 b KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O-O")

      king_moves, rook_moves = move.from_to_squares(board)
      king_from, king_to = king_moves
      rook_from, rook_to = rook_moves

      expect(king_from).to eql("e8")
      expect(king_to).to eql("c8")
      expect(rook_from).to eql("a8")
      expect(rook_to).to eql("d8")
    end

    it "fails white kingside castling when king is out of place" do
      board = ChessRules::Board.new("8/8/8/8/8/8/8/7R w KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "white king not at e1")
    end

    it "fails white king castling when rook is out of place" do
      board = ChessRules::Board.new("8/8/8/8/8/8/8/4K3 w KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "white rook not at h1")
    end

    it "fails white queenside castling when king is out of place" do
      board = ChessRules::Board.new("8/8/8/8/8/8/8/R34 w KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "white king not at e1")
    end

    it "fails white queenside castling when rook is out of place" do
      board = ChessRules::Board.new("8/8/8/8/8/8/8/4K3 w KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "white rook not at a1")
    end

    it "fails black kingside castling when king is out of place" do
      board = ChessRules::Board.new("7r/8/8/8/8/8/8/8 b KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "black king not at e8")
    end

    it "fails black king castling when rook is out of place" do
      board = ChessRules::Board.new("4k3/8/8/8/8/8/8/8 b KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "black rook not at h8")
    end

    it "fails black queenside castling when king is out of place" do
      board = ChessRules::Board.new("r7/8/8/8/8/8/8/8 b KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "black king not at e8")
    end

    it "fails black queenside castling when rook is out of place" do
      board = ChessRules::Board.new("4k3/8/8/8/8/8/8/8 b KQkq - 0 1")
      move = ChessRules::CastlingMove.new("O-O-O")

      expect{ move.from_to_squares(board) }.to raise_error(CastlingMoveError, "black rook not at a8")
    end
  end
end
