require 'spec_helper'
include ChessRules

describe CastlingMove do
  describe '.new' do
    context "castling kingside" do
      it "initializes correctly for white" do
        board = Board.new(EMPTY_FEN_WHITE)
        board.place_piece("K", "e1" )
        board.place_piece("R", "h1" )

        move = CastlingMove.new("O-O", board)

        expect(move.san).to eql("O-O")
        expect(move.color).to eql(board.turn_color)
        expect(move.symbol).to eql("K")
        expect(move.from_squares).to eql(["e1", "h1"])
        expect(move.to_squares).to eql(["g1", "f1"])
        expect(move.lan).to eql("e1g1")
      end

      it "initializes correctly for black" do
        board = Board.new(EMPTY_FEN_BLACK)

        board.place_piece("k", "e8" )
        board.place_piece("r", "h8" )

        move = CastlingMove.new("O-O", board)

        expect(move.san).to eql("O-O")
        expect(move.color).to eql(board.turn_color)
        expect(move.symbol).to eql("k")
        expect(move.from_squares).to eql(["e8", "h8"])
        expect(move.to_squares).to eql(["g8", "f8"])
      end

      it "fails kingside castling when king is out of place" do
        board = Board.new(EMPTY_FEN_WHITE)
        expect{ CastlingMove.new("O-O", board) }.to raise_error(CastlingMoveError, "white king not at e1")

        board = Board.new(EMPTY_FEN_BLACK)
        expect{ CastlingMove.new("O-O", board) }.to raise_error(CastlingMoveError, "black king not at e8")
      end

      it "fails king castling when rook is out of place" do
        board = Board.new(EMPTY_FEN_WHITE)
        board.place_piece("K", "e1" )
        expect{ CastlingMove.new("O-O", board) }.to raise_error(CastlingMoveError, "white rook not at h1")

        board = Board.new(EMPTY_FEN_BLACK)
        board.place_piece("k", "e8" )
        expect{ CastlingMove.new("O-O", board) }.to raise_error(CastlingMoveError, "black rook not at h8")
      end

      it "fails when castling squares are not empty for white" do
        board = Board.new(EMPTY_FEN_WHITE)
        board.place_piece("K", "e1" )
        board.place_piece("R", "h1" )

        board.place_piece("B", "f1" )

        expect{ CastlingMove.new("O-O", board) }.to raise_error(CastlingMoveError, "f1 square is not empty")
      end

      it "fails when castling squares are not empty for black" do
        board = Board.new(EMPTY_FEN_BLACK)
        board.place_piece("k", "e8" )
        board.place_piece("r", "h8" )

        board.place_piece("b", "f8" )

        expect{ CastlingMove.new("O-O", board) }.to raise_error(CastlingMoveError, "f8 square is not empty")
      end
    end

    context "castling queenside" do
      it "initializes correctly for white" do
        board = Board.new(EMPTY_FEN_WHITE)
        board.place_piece("K", "e1" )
        board.place_piece("R", "a1" )

        move = CastlingMove.new("O-O-O", board)

        expect(move.san).to eql("O-O-O")
        expect(move.color).to eql(board.turn_color)
        expect(move.symbol).to eql("K")
        expect(move.from_squares).to eql(["e1", "a1"])
        expect(move.to_squares).to eql(["c1", "d1"])
      end

      it "initializes correctly for black" do
        board = Board.new(EMPTY_FEN_BLACK)

        board.place_piece("k", "e8" )
        board.place_piece("r", "a8" )

        move = CastlingMove.new("O-O-O", board)

        expect(move.san).to eql("O-O-O")
        expect(move.color).to eql(board.turn_color)
        expect(move.symbol).to eql("k")
        expect(move.from_squares).to eql(["e8", "a8"])
        expect(move.to_squares).to eql(["c8", "d8"])
      end

      it "fails when king is out of place" do
        board = Board.new(EMPTY_FEN_WHITE)
        board.place_piece("R", "a1" )
        expect{ CastlingMove.new("O-O-O", board) }.to raise_error(CastlingMoveError, "white king not at e1")

        board = Board.new(EMPTY_FEN_BLACK)
        board.place_piece("r", "a8" )
        expect{ CastlingMove.new("O-O-O", board) }.to raise_error(CastlingMoveError, "black king not at e8")
      end

      it "fails when rook is out of place" do
        board = Board.new(EMPTY_FEN_WHITE)
        board.place_piece("K", "e1" )
        expect{ CastlingMove.new("O-O-O", board) }.to raise_error(CastlingMoveError, "white rook not at a1")

        board = Board.new(EMPTY_FEN_BLACK)
        board.place_piece("k", "e8" )
        expect{ CastlingMove.new("O-O-O", board) }.to raise_error(CastlingMoveError, "black rook not at a8")
      end

      it "fails when castling squares are not empty for white" do
        board = Board.new(EMPTY_FEN_WHITE)
        board.place_piece("K", "e1" )
        board.place_piece("R", "a1" )

        board.place_piece("B", "b1" )

        expect{ CastlingMove.new("O-O-O", board) }.to raise_error(CastlingMoveError, "b1 square is not empty")
      end

      it "fails when castling squares are not empty for black" do
        board = Board.new(EMPTY_FEN_BLACK)
        board.place_piece("k", "e8" )
        board.place_piece("r", "a8" )

        board.place_piece("b", "b8" )

        expect{ CastlingMove.new("O-O-O", board) }.to raise_error(CastlingMoveError, "b8 square is not empty")
      end
    end
  end
end
