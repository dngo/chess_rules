require 'spec_helper'
include ChessRules

describe ChessApi do
  subject(:chess) { Chess.new }

  describe 'api testing' do
    it "initial_fen" do
      chess = Chess.new

      expect(chess.initial_fen).to eql STARTING_FEN
    end

    it "castling" do
      chess = Chess.new

      chess.move!("e4") # white moves pawn
      expect(chess.castling).to eql "KQkq"

      chess.move!("e5") # black moves pawn
      expect(chess.castling).to eql "KQkq"

      chess.move!("Nf3") # white moves kingside knight
      expect(chess.castling).to eql "KQkq"

      chess.move!("Nf6") # black moves kingside knight
      expect(chess.castling).to eql "KQkq"

      # white attempts to castle
      expect{ chess.move!("O-O") }.to raise_error(CastlingMoveError, "f1 square is not empty")
      expect(chess.castling).to eql "KQkq"

      chess.move!("Be2") # white moves kingside bishop out of the way
      expect(chess.castling).to eql "KQkq"

      chess.move!("Be7") # black moves kingside bishop
      expect(chess.castling).to eql "KQkq"

      chess.move!("O-O") # now that bishop out of the way, white can castle
      expect(chess.castling).to eql "kq"

      chess.move!("O-O") # black castles
      expect(chess.castling).to eql "-"

      expect(chess.fen).to eql "rnbq1rk1/ppppbppp/5n2/4p3/4P3/5N2/PPPPBPPP/RNBQ1RK1 w - - 6 5"
    end

    it "turn_color" do
      chess = Chess.new
      expect(chess.turn_color).to eql "w"

      move = chess.move!("e4") # white moves pawn
      expect(chess.turn_color).to eql "b"

      chess.move!("e5") # black moves pawn
      expect(chess.turn_color).to eql "w"

      chess.move!("Nf3") # white moves kingside knight
      expect(chess.turn_color).to eql "b"

      chess.move!("Nf6") # black moves kingside knight
      expect(chess.turn_color).to eql "w"

      chess.move!("Be2") # white moves kingside bishop out of the way
      expect(chess.turn_color).to eql "b"

      chess.move!("Be7") # black moves kingside bishop
      expect(chess.turn_color).to eql "w"

      chess.move!("O-O") # now that bishop out of the way, white can castle
      expect(chess.turn_color).to eql "b"

      chess.move!("O-O") # black castles
      expect(chess.turn_color).to eql "w"
    end

    it "en_passant" do
      chess = Chess.new
      expect(chess.en_passant_square).to eql "-"

      chess.move!("e4") # white moves pawn
      expect(chess.en_passant_square).to eql "e3"

      chess.move!("e5") # black moves pawn
      expect(chess.castling).to eql "KQkq"
      expect(chess.en_passant_square).to eql "e6"

      chess.move!("Nf3") # white moves kingside knight
      expect(chess.en_passant_square).to eql "-"

      chess.move!("Nf6") # black moves kingside knight
      expect(chess.en_passant_square).to eql "-"

      chess.move!("Be2") # white moves kingside bishop out of the way
      expect(chess.en_passant_square).to eql "-"

      chess.move!("Be7") # black moves kingside bishop
      expect(chess.en_passant_square).to eql "-"

      chess.move!("O-O") # now that bishop out of the way, white can castle
      expect(chess.en_passant_square).to eql "-"

      chess.move!("O-O") # black castles
      expect(chess.en_passant_square).to eql "-"
    end

    it "plays an en passant capture" do
      chess = Chess.new("4k3/8/8/8/3p4/8/4P3/4K3 w - - 0 1")

      chess.move!("e4")
      expect(chess.en_passant_square).to eql("e3")

      chess.move!("dxe3")
      expect(chess.board.piece_at("e4")).to be_nil
      expect(chess.board.piece_at("d4")).to be_nil
      expect(chess.board.piece_at("e3")).to eql("p")
      expect(chess.en_passant_square).to eql("-")
    end

    it "plays the en passant capture from a loaded position" do
      chess = Chess.new("4k3/p1pr1pp1/1p2p3/4P3/4p3/PP2P2P/1BP1KP2/R7 b - - 1 21")

      chess.move!("f5")
      expect(chess.en_passant_square).to eql("f6")

      chess.move!("exf6")
      expect(chess.board.piece_at("f5")).to be_nil
      expect(chess.board.piece_at("e5")).to be_nil
      expect(chess.board.piece_at("f6")).to eql("P")
      expect(chess.en_passant_square).to eql("-")
    end

    it "full_moves" do
      chess = Chess.new

      chess.move!("e4") # white moves pawn
      expect(chess.full_moves).to eql 1

      chess.move!("e5") # black moves pawn
      expect(chess.full_moves).to eql 2 # black moved so increment

      chess.move!("Nf3") # white moves kingside knight
      expect(chess.full_moves).to eql 2

      chess.move!("Nf6") # black moves kingside knight
      expect(chess.full_moves).to eql 3 # black moved so increment

      chess.move!("Be2") # white moves kingside bishop out of the way
      expect(chess.full_moves).to eql 3

      chess.move!("Be7") # black moves kingside bishop
      expect(chess.full_moves).to eql 4 # black moved so increment

      chess.move!("O-O") # now that bishop out of the way, white can castle
      expect(chess.full_moves).to eql 4

      chess.move!("O-O") # black castles
      expect(chess.full_moves).to eql 5 # black moved so increment
    end

    it "half moves" do
      chess = Chess.new

      chess.move!("e4") # white moves pawn
      expect(chess.half_moves).to eql 0 # pawn move so its reset

      chess.move!("e5") # black moves pawn
      expect(chess.half_moves).to eql 0 # pawn move so its reset

      chess.move!("Nf3") # white moves kingside knight
      expect(chess.half_moves).to eql 1

      chess.move!("Nf6") # black moves kingside knight
      expect(chess.half_moves).to eql 2

      chess.move!("Be2") # white moves kingside bishop out of the way
      expect(chess.half_moves).to eql 3

      chess.move!("Be7") # black moves kingside bishop
      expect(chess.half_moves).to eql 4

      chess.move!("O-O") # now that bishop out of the way, white can castle
      expect(chess.half_moves).to eql 5

      chess.move!("O-O") # black castles
      expect(chess.half_moves).to eql 6

      expect(chess.fen).to eql "rnbq1rk1/ppppbppp/5n2/4p3/4P3/5N2/PPPPBPPP/RNBQ1RK1 w - - 6 5"
      expect(chess.half_moves).to eql 6
    end
  end
end
