require 'spec_helper'

describe ChessRules::MoveFactory do
  describe '.create' do
    shared_examples 'move creation' do |notation, move_class|
      it "creates a #{move_class} instance for notation '#{notation}'" do
        expect(ChessRules::MoveFactory.create(notation)).to be_an_instance_of(move_class)
      end
    end

    it "creates " do
      expect(ChessRules::MoveFactory.create("Nbd2#")).to be_an_instance_of(ChessRules::DisambiguousMove)
    end

    context 'for standard moves' do
      include_examples 'move creation', "Qe5", ChessRules::StandardMove
      include_examples 'move creation', "Qe5+", ChessRules::StandardMove   # check
      include_examples 'move creation', "Qe5++", ChessRules::StandardMove  # double check
      include_examples 'move creation', "Kxa1", ChessRules::StandardMove   # capture
      include_examples 'move creation', "Bxb7+", ChessRules::StandardMove  # capture and check
      include_examples 'move creation', "Bxb7++", ChessRules::StandardMove # capture double check
      include_examples 'move creation', "Qb7#",  ChessRules::StandardMove  # checkmate
      include_examples 'move creation', "Qxb7#", ChessRules::StandardMove  # capture and checkmate
    end

    context 'for pawn moves' do
      include_examples 'move creation', "e4", ChessRules::PawnMove
      include_examples 'move creation', "exd5", ChessRules::PawnMove   # capture
      include_examples 'move creation', "e4+", ChessRules::PawnMove    # check
      include_examples 'move creation', "e4++", ChessRules::PawnMove   # double check
      include_examples 'move creation', "axb7+", ChessRules::PawnMove  # capture and check
      include_examples 'move creation', "axb7++", ChessRules::PawnMove # capture and double check
      include_examples 'move creation', "a8=R", ChessRules::PawnMove   # promotion
      include_examples 'move creation', "a8=N", ChessRules::PawnMove   # promotion
      include_examples 'move creation', "a8=B", ChessRules::PawnMove   # promotion
      include_examples 'move creation', "a8=Q", ChessRules::PawnMove   # promotion
      include_examples 'move creation', "b7#",  ChessRules::PawnMove    # checkmate
      include_examples 'move creation', "axb7#", ChessRules::PawnMove  # capture and checkmate
    end

    context 'for promotion moves' do
      include_examples 'move creation', "e8=Q", ChessRules::PawnMove
      include_examples 'move creation', "e8=Q+", ChessRules::PawnMove
      include_examples 'move creation', "e8=Q++", ChessRules::PawnMove
      include_examples 'move creation', "e8=Q#",  ChessRules::PawnMove
    end

    context 'for castling' do
      include_examples 'move creation', "O-O", ChessRules::CastlingMove
      include_examples 'move creation', "O-O-O", ChessRules::CastlingMove
    end

    context 'for disambiguated moves' do
      include_examples 'move creation', "Nbd2", ChessRules::DisambiguousMove  # file
      include_examples 'move creation', "R1d1", ChessRules::DisambiguousMove  # rank
      include_examples 'move creation', "Qh4e1", ChessRules::DisambiguousMove # rank and file

      include_examples 'move creation', "Nbd2#", ChessRules::DisambiguousMove  # file and checkmate
      include_examples 'move creation', "R1d1#", ChessRules::DisambiguousMove  # rank and checkmate
      include_examples 'move creation', "Qh4e1#", ChessRules::DisambiguousMove # rank and file and checkmate

      include_examples 'move creation', "Nbxd2", ChessRules::DisambiguousMove  # file capture
      include_examples 'move creation', "R1xd1", ChessRules::DisambiguousMove  # rank capture
      include_examples 'move creation', "Qh4xe1", ChessRules::DisambiguousMove # rank and file capture

      include_examples 'move creation', "Nbxd2#", ChessRules::DisambiguousMove  # file capture and checkmate
      include_examples 'move creation', "R1xd1#", ChessRules::DisambiguousMove  # rank capture and checkmate
      include_examples 'move creation', "Qh4xe1#", ChessRules::DisambiguousMove # rank and file capture and checkmate

      include_examples 'move creation', "Nbxd2+", ChessRules::DisambiguousMove  # file capture and check
      include_examples 'move creation', "R1xd1+", ChessRules::DisambiguousMove  # rank capture and check
      include_examples 'move creation', "Qh4xe1+", ChessRules::DisambiguousMove # rank and file capture and check

      include_examples 'move creation', "Nbxd2++", ChessRules::DisambiguousMove  # file capture and double check
      include_examples 'move creation', "R1xd1++", ChessRules::DisambiguousMove  # rank capture and double check
      include_examples 'move creation', "Qh4xe1++", ChessRules::DisambiguousMove # rank and file capture and double check
    end

    context 'when notation is invalid' do
      it 'raises a NotationError for unknown notation' do
        notation = "invalid_notation"
        expect { ChessRules::MoveFactory.create(notation) }.to raise_error(NotationError, "Unknown notation: #{notation}")
      end
    end
  end

  describe '.algebraic?' do
    context 'with valid algebraic notations' do
      ['Ka2', 'e4', 'exd5', 'Nxd5', 'O-O', 'O-O-O'].each do |notation|
        it "returns true for '#{notation}'" do
          expect(ChessRules::MoveFactory.algebraic?(notation)).to be true
        end
      end
    end

    context 'with invalid algebraic notations' do
      ['invalid', '123', 'e2e4'].each do |notation|
        it "returns false for '#{notation}'" do
          expect(ChessRules::MoveFactory.algebraic?(notation)).to be false
        end
      end
    end
  end
end
