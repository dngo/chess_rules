require 'spec_helper'
include ChessRules

describe PieceFactory do
  describe '.create' do
    let(:board) { Board.new(EMPTY_FEN_WHITE) }

    context 'when given a valid piece type' do
      it 'creates a King instance when given "king"' do
        piece = PieceFactory.create('K', [0, 0], board.board_2d)
        expect(piece).to be_an_instance_of(King)
      end

      it 'creates a Queen instance when given "queen"' do
        piece = PieceFactory.create('Q', [0, 0], board.board_2d)
        expect(piece).to be_an_instance_of(Queen)
      end

      it 'creates a Knight instance when given "knight"' do
        piece = PieceFactory.create('N', [0, 0], board.board_2d)
        expect(piece).to be_an_instance_of(Knight)
      end

      it 'creates a Knight instance when given "knight"' do
        piece = PieceFactory.create('P', [0, 0], board.board_2d)
        expect(piece).to be_an_instance_of(Pawn)
      end
    end

    context 'when given an invalid piece type' do
      it 'raises an error for an unknown piece type' do
        expect{ PieceFactory.create('dragon', [0, 0], board.board_2d) }.to raise_error(NotImplementedError, "Unknown piece type: dragon")
      end
    end
  end
end
