require 'spec_helper'
include ChessRules

describe ::Pawn do
  subject(:chess) { ::Chess.new }

  describe '#moves white pawn' do
    it "advances 1 rank when not in its starting position" do
      board = Board.new("8/4P3/8/8/8/8/8/8 w - - 0 1")

      pawn = Pawn.new(Pawn::WHITE, Board.get_coordinates('e7'), board.board_2d)

      expect(Board.get_algebraic(pawn.position)).to eql "e7"
      expect(Board.get_algebraic(pawn.moves.last)).to eql "e8"
    end

    it "advance 2 moves if in its starting position" do
      board = Board.new("8/8/8/8/8/8/4P3/8 w - - 0 1")

      pawn = Pawn.new(Pawn::WHITE, Board.get_coordinates('e2'), board.board_2d)
      algebraic_moves = pawn.moves.inject([]) do |moves, coordinate|
        moves << Board.get_algebraic(coordinate)
        moves
      end

      expect(::Board.get_algebraic(pawn.position)).to eql "e2"
      expect(algebraic_moves).to eql ["e3", "e4"]
    end

    it "captures diagonally" do
      chess = Chess.new('3r1n2/4P3/8/8/8/8/8/4K3 b KQkq - 0 1')
      pawn = Pawn.new(Pawn::WHITE, Board.get_coordinates('e7'), chess.board.board_2d)
      algebraic_moves = pawn.moves.inject([]) do |moves, coordinate|
        moves << Board.get_algebraic(coordinate)
        moves
      end
      expect(algebraic_moves).to eql ["d8", "f8", "e8"]
    end

    it "cannot advance when blocked" do
      chess = Chess.new '8/8/8/8/8/p4K1k/P7/8 b - - 0 1'
      pawn = Pawn.new(::Pawn::WHITE, Board.get_coordinates('a2'), chess.board.board_2d)
      algebraic_moves = pawn.moves.inject([]) do |moves, coordinate|
        moves << Board.get_algebraic(coordinate)
        moves
      end
      expect(Board.get_algebraic(pawn.position)).to eql "a2"
      expect(algebraic_moves).to eql []
    end

  end

  describe '#moves black pawn' do
    it "descends 1 rank when not in its starting position" do
      board = Board.new("8/8/8/8/8/8/4p3/8 b - - 0 1")

      pawn = Pawn.new(Pawn::BLACK, Board.get_coordinates('e2'), board.board_2d)

      expect(Board.get_algebraic(pawn.position)).to eql "e2"
      expect(Board.get_algebraic(pawn.moves.last)).to eql "e1"
    end

    it "descends 2 moves if in its starting position" do
      board = Board.new("8/4p3/8/8/8/8/8/8 b - - 0 1")

      pawn = Pawn.new(Pawn::BLACK, Board.get_coordinates('e7'), board.board_2d)
      algebraic_moves = pawn.moves.inject([]) do |moves, coordinate|
        moves << Board.get_algebraic(coordinate)
        moves
      end

      expect(Board.get_algebraic(pawn.position)).to eql "e7"
      expect(algebraic_moves).to eql ["e6", "e5"]
    end

    it "cannot descend when blocked" do
      chess = Chess.new('8/p7/P7/8/8/5K1k/8/8 w - - 0 1')
      pawn = Pawn.new(Pawn::BLACK, Board.get_coordinates('a7'), chess.board.board_2d)
      algebraic_moves = pawn.moves.inject([]) do |moves, coordinate|
        moves << Board.get_algebraic(coordinate)
        moves
      end
      expect(Board.get_algebraic(pawn.position)).to eql "a7"
      expect(algebraic_moves).to eql []
    end

  end

end
