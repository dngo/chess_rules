require 'spec_helper'
include ChessRules

describe MoveFactory do
  describe '.create' do
    shared_examples 'move creation' do |notation, board, move_class|
      it "creates a #{move_class} instance for notation '#{notation}'" do
        expect(::MoveFactory.create(notation, board)).to be_an_instance_of(move_class)
      end
    end

    context 'for standard moves' do
      board = Board.new("8/8/8/8/8/8/8/4Q3 w KQkq - 0 1")
      include_examples 'move creation', "Qe5", board, StandardMove
      include_examples 'move creation', "Qe5+", board, StandardMove  # check
      include_examples 'move creation', "Qe5++", board, StandardMove # double check

      board = Board.new("8/8/8/8/8/8/K7/q7 w KQkq - 0 1")
      include_examples 'move creation', "Kxa1", board, StandardMove   # capture

      board = Board.new("2B5/8/8/8/8/8/8/8 w KQkq - 0 1")
      include_examples 'move creation', "Bxb7+", board, StandardMove  # capture and check
      include_examples 'move creation', "Bxb7++", board, StandardMove # capture double check

      board = Board.new("8/8/8/8/8/8/8/1Q6 w KQkq - 0 1")
      include_examples 'move creation', "Qb7#", board, StandardMove  # checkmate
      include_examples 'move creation', "Qxb7#", board, StandardMove  # capture and checkmate
    end

    context 'for pawn moves' do
      board = Board.new
      include_examples 'move creation', "e4", board, PawnMove
      include_examples 'move creation', "e4+", board, PawnMove    # check
      include_examples 'move creation', "e4++", board, PawnMove   # double check
      include_examples 'move creation', "e3#", board, PawnMove    # checkmate

      board = Board.new("8/8/8/3p4/4P3/8/8/8 w KQkq - 0 1")
      include_examples 'move creation', "exd5", board, PawnMove   # capture
      include_examples 'move creation', "exd5+", board, PawnMove  # capture and check
      include_examples 'move creation', "exd5++", board, PawnMove  # capture and double check
      include_examples 'move creation', "exd5#", board, PawnMove  # capture and checkmate
    end

    context 'for pawn promotion' do
      board = Board.new("8/P7/8/8/8/8/8/8 w KQkq - 0 1")

      include_examples 'move creation', "a8=R", board, PawnMove   # promotion
      include_examples 'move creation', "a8=N", board, PawnMove   # promotion
      include_examples 'move creation', "a8=B", board, PawnMove   # promotion
      include_examples 'move creation', "a8=Q", board, PawnMove   # promotion
      include_examples 'move creation', "a8=Q+", board, PawnMove   # promotion and check
      include_examples 'move creation', "a8=Q++", board, PawnMove   # promotion and double check
      include_examples 'move creation', "a8=Q#", board, PawnMove   # promotion and mate
    end

    context 'for castling' do
      board = Board.new(EMPTY_FEN_WHITE)
      board.place_piece("K", "e1")
      board.place_piece("R", "h1")
      board.place_piece("R", "a1")

      include_examples 'move creation', "O-O", board, CastlingMove

      include_examples 'move creation', "O-O-O", board, CastlingMove
    end

    describe 'for disambiguated moves' do
      context 'when file is disambiguated' do
        board = Board.new("8/8/8/8/8/8/8/1N6 w KQkq - 0 1")
        include_examples 'move creation', "Nbd2", board, DisambiguousMove  # file
        include_examples 'move creation', "Nbd2#", board, DisambiguousMove  # file and checkmate
        include_examples 'move creation', "Nbxd2", board, DisambiguousMove  # file capture
        include_examples 'move creation', "Nbxd2#", board, DisambiguousMove  # file capture and checkmate
        include_examples 'move creation', "Nbxd2+", board, DisambiguousMove  # file capture and check
        include_examples 'move creation', "Nbxd2++", board, DisambiguousMove  # file capture and double check
      end

      context 'when rank is disambiguated' do
        board = Board.new("8/8/8/8/8/8/8/R6R w KQkq - 0 1")
        include_examples 'move creation', "R1d1", board, DisambiguousMove  # rank
        include_examples 'move creation', "R1d1#", board, DisambiguousMove  # rank and checkmate
        include_examples 'move creation', "R1xd1", board, DisambiguousMove  # rank capture
        include_examples 'move creation', "R1xd1#", board, DisambiguousMove  # rank capture and checkmate
        include_examples 'move creation', "R1xd1+", board, DisambiguousMove  # rank capture and check
        include_examples 'move creation', "R1xd1++", board, DisambiguousMove  # rank capture and double check
      end

      context 'when both rank and file are disambiguated' do
        board = Board.new("8/8/8/8/4Q2Q/8/8/7Q w KQkq - 0 1")
        include_examples 'move creation', "Qh4e1", board, DisambiguousMove # rank and file
        include_examples 'move creation', "Qh4e1#", board, DisambiguousMove # rank and file and checkmate
        include_examples 'move creation', "Qh4xe1", board, DisambiguousMove # rank and file capture
        include_examples 'move creation', "Qh4xe1#", board, DisambiguousMove # rank and file capture and checkmate
        include_examples 'move creation', "Qh4xe1+", board, DisambiguousMove # rank and file capture and check
        include_examples 'move creation', "Qh4xe1++", board, DisambiguousMove # rank and file capture and double check
      end
    end

    context 'when notation is invalid' do
      it 'raises a NotationError for unknown notation' do
        notation = "invalid_notation"
        expect { MoveFactory.create(notation, Board.new) }.to raise_error(NotationError, "Unknown san: #{notation}")
      end
    end
  end

  describe '.algebraic?' do
    context 'with valid algebraic notations' do
      ['Ka2', 'e4', 'exd5', 'Nxd5', 'O-O', 'O-O-O'].each do |notation|
        it "returns true for '#{notation}'" do
          expect(MoveFactory.algebraic?(notation)).to be true
        end
      end
    end

    context 'with invalid algebraic notations' do
      ['invalid', '123', 'e2e4'].each do |notation|
        it "returns false for '#{notation}'" do
          expect(MoveFactory.algebraic?(notation)).to be false
        end
      end
    end
  end
end
