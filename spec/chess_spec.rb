require 'spec_helper'

describe ChessRules::Chess do
  subject(:chess) { ChessRules::Chess.new }

  describe '#new' do
    it "defaults to the starting position" do
      expect(chess.to_fen).to eql 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
    end
  end

  describe '#to_fen' do
    it "after first move e4 correctly handles en passant square" do
      chess = ChessRules::Chess.new("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1")
      expect(chess.to_fen).to eql "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
    end

    it "handles no castling" do
      chess = ChessRules::Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b - - 1 2")
      expect(chess.to_fen).to eql "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b - - 1 2"
    end

    it "handles partial castling" do
      chess = ChessRules::Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b Kk - 1 2")
      expect(chess.to_fen).to eql "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b Kk - 1 2"
    end
  end

  describe '#valid?' do
    it "is valid" do
      expect(chess).to be_valid
    end

    it "more than 1 white king and more than 1 black king" do
      chess = ChessRules::Chess.new('rnbq1bkk/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BKK b - - 0 1')
      expect(chess).to_not be_valid
      expect(chess.errors[:invalid_position]).to include("more than 1 white king")
      expect(chess.errors[:invalid_position]).to include("more than 1 black king")
    end

    it "has invalid row" do
      chess = ChessRules::Chess.new('3r3k/ppp4p/6p1/8/2B6/1P2p1q1/P1Qb4/1K6 w - - 0 30')
      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("row has 9 columns, 8 required for each row")
    end

    it "is missing fields" do
      chess = ChessRules::Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq -") #missing half move and move num
      expect(chess).to_not be_valid
      expect(chess.errors[:base]).to include("FEN string must contain six space delimited fields")
    end

    it "is has invalid half move" do
      chess = ChessRules::Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - -1 1") #half move is -1
      expect(chess).to_not be_valid
      expect(chess.errors[:half_move]).to include("must be a positive integer")

      chess = ChessRules::Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - a 1") #half move is a
      expect(chess).to_not be_valid
      expect(chess.errors[:half_move]).to include("must be a positive integer")
    end

    it "is has invalid move num" do
      chess = ChessRules::Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 1 -1") #move num is -1
      expect(chess).to_not be_valid
      expect(chess.errors[:move_num]).to include("must be a positive integer")

      chess = ChessRules::Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 1 a") #move_num is a
      expect(chess).to_not be_valid
      expect(chess.errors[:move_num]).to include("must be a positive integer")
    end

    it "enpassant square is invalid" do
      chess = ChessRules::Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq a1 0 1") #enpassant square cannot be a1
      expect(chess).to_not be_valid
      expect(chess.errors[:en_passant_invalid]).to include("square is invalid")

      chess = ChessRules::Chess.new("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1") #e3 is valid enpassant square
      expect(chess).to be_valid

      chess = ChessRules::Chess.new("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e3 0 1") #white pawn has just moved
      expect(chess).to_not be_valid
      expect(chess.errors[:en_passant_invalid]).to include("the white pawn has just moved, it cannot be whites turn")

      chess = ChessRules::Chess.new("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e6 0 1") #black pawn has just moved
      expect(chess).to_not be_valid
      expect(chess.errors[:en_passant_invalid]).to include("the black pawn has just moved, it cannot be blacks turn")
    end

    it "castling availability" do
      chess = ChessRules::Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b aa - 1 2") #castling cannot be aa
      expect(chess).to_not be_valid
      expect(chess.errors[:castling]).to include("string is invalid")

      chess = ChessRules::Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b - - 1 2") #castling cannot be aa
      expect(chess).to be_valid
    end

    it "castling availability" do
      chess = ChessRules::Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R c Kk - 1 2") #move color can only be b or w
      expect(chess).to_not be_valid
      expect(chess.errors[:move_color]).to include("must be w or b")
    end

    it "board string" do
      chess = ChessRules::Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP w Kk - 1 2") #only 7 rows
      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("must have 8 rows")
    end

    it "board string invalid column is short" do
      chess = ChessRules::Chess.new("rnbqkb/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R c Kk - 1 2") #1st row only has 6 columns
      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("row has 6 columns, 8 required for each row")
    end

    it "board string invalid column consecutive numbers" do
      chess = ChessRules::Chess.new("rnbqkb11/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R c Kk - 1 2") #1st has consecutive numbers
      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("is invalid: consecutive numbers 1")
    end

    it "when pawn is on the promotion row 1" do
      chess = ChessRules::Chess.new("P3k3/8/8/8/8/8/8/4K3 w - - 0 1") #pawn on a8
      expect(chess).to_not be_valid
      expect(chess.errors[:invalid_position]).to include("there cannot be a pawn on white's promotion row")
    end

    it "when pawn is on the promotion row 8" do
      chess = ChessRules::Chess.new("4k3/8/8/8/8/8/8/4K2p w - - 0 1") #pawn on a8
      expect(chess).to_not be_valid
      expect(chess.errors[:invalid_position]).to include("there cannot be a pawn on black's promotion row")
    end

  end

  describe '#in_check?' do
    it "it is not in check from the starting position" do
      chess = ChessRules::Chess.new
      expect(chess.in_check?(ChessRules::WHITE)).to eql(false)
      expect(chess.in_check?(ChessRules::BLACK)).to eql(false)
    end

    it "black should be in check from pawn" do
      chess = ChessRules::Chess.new("3k4/4P3/8/8/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(true)

      chess = ChessRules::Chess.new("3k4/2P5/8/8/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(true)
    end

    it "white should be in check from pawn" do
      chess = ChessRules::Chess.new("3k4/8/8/8/8/8/4p3/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(true)

      chess = ChessRules::Chess.new("3k4/8/8/8/8/8/2p5/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(true)
    end

    it "black should not be in check from pawn" do
      chess = ChessRules::Chess.new("3k4/3P4/8/8/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(false)
    end

    it "white should not be in check from pawn" do
      chess = ChessRules::Chess.new("3k4/8/8/8/8/8/3p4/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(false)
    end

    it "black should be in check from queen" do
      chess = ChessRules::Chess.new("3k4/8/8/8/7Q/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(false)
      expect(chess.in_check?(ChessRules::BLACK)).to eql(true)
    end

    it "white should be in check from queen" do
      chess = ChessRules::Chess.new("3k4/8/8/7q/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(true)
      expect(chess.in_check?(ChessRules::BLACK)).to eql(false)
    end

    it "black should not be in check from queen, blocked by pawn" do
      chess = ChessRules::Chess.new("3k4/4p3/8/8/7Q/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(false)
    end

    it "white should not be in check from queen, blocked by pawn" do
      chess = ChessRules::Chess.new("3k4/8/8/7q/8/8/4P3/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(false)
    end

    it "black should be in check from rook" do
      chess = ChessRules::Chess.new("3k4/8/8/8/8/8/3R4/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(true)
    end

    it "white should be in check from rook" do
      chess = ChessRules::Chess.new("3k4/3r4/8/8/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(true)
    end

    it "black should not be in check from rook, blocked by pawn" do
      chess = ChessRules::Chess.new("3k4/3P4/8/8/8/8/3R4/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(false)
    end

    it "white should not be in check from rook, blocked by pawn" do
      chess = ChessRules::Chess.new("3k4/3r4/8/8/8/8/3P4/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(false)
    end

    it "black should be in check from bishop" do
      chess = ChessRules::Chess.new("3k4/8/8/8/7B/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(true)
    end

    it "white should be in check from bishop" do
      chess = ChessRules::Chess.new("3k4/8/8/7b/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(true)
    end

    it "black should not be in check from bishop, blocked by pawn" do
      chess = ChessRules::Chess.new("3k4/4p3/8/8/7B/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(false)
    end

    it "white should not be in check from bishop, blocked by pawn" do
      chess = ChessRules::Chess.new("3k4/8/8/7b/8/8/4P3/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(false)
    end

    it "black should be in check from knight" do
      chess = ChessRules::Chess.new("3k4/8/4N3/8/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(true)
    end

    it "white should be in check from knight" do
      chess = ChessRules::Chess.new("3k4/8/8/8/8/4n3/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(true)
    end

    it "black should still be in check from knight, pawns don't block" do
      chess = ChessRules::Chess.new("3k4/3pp3/4N3/8/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::BLACK)).to eql(true)
    end

    it "white should still be in check from knight, pawns don't block" do
      chess = ChessRules::Chess.new("3k4/8/8/8/8/4n3/3PP3/3K4 b KQkq - 0 1")
      expect(chess.in_check?(ChessRules::WHITE)).to eql(true)
    end

  end

  describe '#checkmate?' do
    it "should be checkmate (scholar's mate)" do
      chess = ChessRules::Chess.new "r1bqkbnr/ppp2Qpp/2np4/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 1"
      expect(chess.checkmate?).to eql(true)
    end
  end

  describe '#stalemate?' do
    it "should be stalemate" do
      chess = ChessRules::Chess.new "8/p7/P7/8/5q2/5k1K/8/8 w - - 0 1"
      expect(chess.stalemate?).to eql(true)
      expect(chess.checkmate?).to eql(false)
    end
  end

end
