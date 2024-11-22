require 'spec_helper'
include ChessRules

describe Board do
  describe '.new' do
    it "default to the starting fen when one is not provided" do
      board = Board.new

      expect(board.board_2d[0]).to eql(["r", "n", "b", "q", "k", "b", "n", "r"])
      expect(board.board_2d[1]).to eql(["p", "p", "p", "p", "p", "p", "p", "p"])
      expect(board.board_2d[2]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[3]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[4]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[5]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[6]).to eql ["P", "P", "P", "P", "P", "P", "P", "P"]
      expect(board.board_2d[7]).to eql ["R", "N", "B", "Q", "K", "B", "N", "R"]
    end

    it "initializes correctly with a fen" do
      board = Board.new("k7/8/8/8/8/8/8/K7 w - - 0 1")

      expect(board.board_2d[0]).to eql ["k", nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[1]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[2]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[3]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[4]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[5]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[6]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[7]).to eql ["K", nil, nil, nil, nil, nil, nil, nil]
    end

    it "initializes correctly for a fen with all empty squares" do
      board = Board.new(EMPTY_FEN_WHITE)

      expect(board.board_2d[0]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[1]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[2]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[3]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[4]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[5]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[6]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
      expect(board.board_2d[7]).to eql [nil, nil, nil, nil, nil, nil, nil, nil]
    end
  end

  describe '.clear!' do
    it "removes all pieces" do
      board = Board.new(STARTING_FEN)

      expect(board.to_fen).to eql "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"

      board.clear!

      expect(board.to_fen).to eql "8/8/8/8/8/8/8/8"
    end
  end

  describe '#move!' do
    let(:board) { Board.new(EMPTY_FEN_WHITE) }

    after(:each) do
      board.clear!
    end

    it "succeeds for a standard move" do
      board.place_piece("K", "a1")

      board.move!("Ka2")

      expect(board.piece_at("a1")).to eql(nil)
      expect(board.piece_at("a2")).to eql("K")
    end

    it "works for a capture" do
      board.place_piece("K", "a1")
      board.place_piece("q", "a2")

      board.move!("Kxa2")

      expect(board.piece_at("a1")).to eql(nil)
      expect(board.piece_at("a2")).to eql("K")
    end

    it "works for a pawn move" do
      board.place_piece("P", "a2")

      board.move!("a4")

      expect(board.piece_at("a2")).to eql(nil)
      expect(board.piece_at("a4")).to eql("P")
    end

    it "works for a pawn capture" do
      board.place_piece("P", "a2")
      board.place_piece("q", "b3")

      board.move!("axb3")

      expect(board.piece_at("a2")).to eql(nil)
      expect(board.piece_at("b3")).to eql("P")
    end

    it "works for kingside castling" do
      board.place_piece("K", "e1")
      board.place_piece("R", "h1")

      board.move!("O-O")

      expect(board.piece_at("g1")).to eql("K")
      expect(board.piece_at("f1")).to eql("R")
    end

    it "works for queenside castling" do
      board.place_piece("K", "e1")
      board.place_piece("R", "a1")

      board.move!("O-O-O")

      expect(board.piece_at("c1")).to eql("K")
      expect(board.piece_at("d1")).to eql("R")
    end

    it "works for check" do
      board =  Board.new('k7/8/8/8/8/8/1Q6/K7 w - - 0 1')

      board.move!("Qb7+")

      expect(board.piece_at("b1")).to be_nil
      expect(board.piece_at("b7")).to eql("Q")
    end

    it "works for checkmate" do
      board = Board.new("k7/8/8/8/8/8/1Q6/K7 w KQkq - 0 1")

      board.move!("Qb7#")

      expect(board.piece_at("b1")).to be_nil
      expect(board.piece_at("b7")).to eql("Q")
    end

    it "works for a disambiguous move" do
      board = Board.new("R6R/8/8/8/8/8/8/8 w KQkq - 0 1")

      board.move!('Rab8')

      expect(board.piece_at("a8")).to be_nil
      expect(board.piece_at("b8")).to eql("R")
    end

    it "works for promotion" do
      board = Board.new("8/P7/8/8/8/8/8/8 w KQkq - 0 1")
      board.move!("a8=Q")
      expect(board.piece_at("a7")).to be_nil
      expect(board.piece_at("a8")).to eql("Q")

      board = Board.new("8/P7/8/8/8/8/8/8 w KQkq - 0 1")
      board.move!("a8=Q+") # promotion with check
      expect(board.piece_at("a7")).to be_nil
      expect(board.piece_at("a8")).to eql("Q")

      board = Board.new("8/P7/8/8/8/8/8/8 w KQkq - 0 1")
      board.move!("a8=Q++") # promotion with double check
      expect(board.piece_at("a7")).to be_nil
      expect(board.piece_at("a8")).to eql("Q")

      board = Board.new("8/P7/8/8/8/8/8/8 w KQkq - 0 1")
      board.move!("a8=Q+") # promotion with checkmate
      expect(board.piece_at("a7")).to be_nil
      expect(board.piece_at("a8")).to eql("Q")
    end

    it "fails when the current turn color has no piece matching the notation" do
      board =  Board.new('8/8/8/8/8/8/8/8 b - - 0 1') # black turn

      board.place_piece("K", "a1") # but white king is at origin square

      expect{ board.move!("Ka2") }.to raise_error(StandardMoveError, "black king not found")
    end

    it "fails when the current turn color has no matching piece that can reach the destination square" do
      board = Board.new('8/8/8/8/8/8/8/8 b - - 0 1') # black turn

      board.place_piece("k", "h8") # but white king is at origin square

      expect{ board.move!("Ka2") }.to raise_error(StandardMoveError, "black king cannot move to a2")
    end

  end
end
