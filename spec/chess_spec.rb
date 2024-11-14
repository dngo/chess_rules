require 'spec_helper'
include ChessRules

describe Chess do
  subject(:chess) { Chess.new }

  describe '#new' do
    it "initializes correctly" do
      chess = Chess.new

      expect(chess.initial_fen).to eql STARTING_FEN
      expect(chess.turn_color).to eql 'w'
      expect(chess.castling).to eql 'KQkq'
      expect(chess.en_passant_square).to eql '-'
      expect(chess.half_moves).to eql 0
      expect(chess.full_moves).to eql 1
    end
  end

  describe '#fen' do
    it "is returned correctly" do
      chess = Chess.new

      expect(chess.fen).to eql STARTING_FEN
    end

    it "after the first move" do
      chess = Chess.new

      chess.move!("e4") # white moves pawn

       expect(chess.initial_fen).to eql STARTING_FEN
       expect(chess.turn_color).to eql 'b'
       expect(chess.castling).to eql 'KQkq'
       expect(chess.en_passant_square).to eql 'e3'
       expect(chess.half_moves).to eql 0
       expect(chess.full_moves).to eql 1
       expect(chess.fen).to eql "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
    end
  end

  describe '#valid?' do
    it "is valid" do
      expect(chess).to be_valid
    end

    it "more than 1 white king and more than 1 black king" do
      chess = Chess.new('rnbq1bkk/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BKK b - - 0 1')
      expect(chess).to_not be_valid
      expect(chess.errors[:invalid_position]).to include("more than 1 white king")
      expect(chess.errors[:invalid_position]).to include("more than 1 black king")
    end

    it "has invalid row" do
      chess = Chess.new('3r3k/ppp4p/6p1/8/2B6/1P2p1q1/P1Qb4/1K6 w - - 0 30')
      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("row has 9 columns, 8 required for each row")
    end

    it "is missing fields" do
      chess = Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq -") #missing half move and move num

      expect(chess).to_not be_valid
      expect(chess.errors[:base]).to include("FEN string must contain six space delimited fields")
    end

    it "is has invalid half move" do
      chess = Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - -1 1") #half move is -1

      expect(chess).to_not be_valid
      expect(chess.errors[:half_move]).to include("must be a positive integer")

      chess = Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - a 1") #half move is a
      expect(chess).to_not be_valid
      expect(chess.errors[:half_move]).to include("must be a positive integer")
    end

    it "is has invalid move num" do
      chess = Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 1 -1") #move num is -1

      expect(chess).to_not be_valid
      expect(chess.errors[:move_num]).to include("must be a positive integer")

      chess = Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 1 a") #move_num is a
      expect(chess).to_not be_valid
      expect(chess.errors[:move_num]).to include("must be a positive integer")
    end

    it "enpassant square is invalid" do
      chess = Chess.new("r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq a1 0 1") #enpassant square cannot be a1
      expect(chess).to_not be_valid
      expect(chess.errors[:en_passant_invalid]).to include("square is invalid")

      chess = Chess.new("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1") #e3 is valid enpassant square
      expect(chess).to be_valid

      chess = Chess.new("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e3 0 1") #white pawn has just moved
      expect(chess).to_not be_valid
      expect(chess.errors[:en_passant_invalid]).to include("the white pawn has just moved, it cannot be whites turn")

      chess = Chess.new("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e6 0 1") #black pawn has just moved
      expect(chess).to_not be_valid
      expect(chess.errors[:en_passant_invalid]).to include("the black pawn has just moved, it cannot be blacks turn")
    end

    it "castling availability" do
      chess = Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b aa - 1 2") #castling cannot be aa
      expect(chess).to_not be_valid
      expect(chess.errors[:castling]).to include("string is invalid")

      chess = Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b - - 1 2") #castling cannot be aa
      expect(chess).to be_valid
    end

    it "turn color" do
      chess = Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R c Kk - 1 2") #move color can only be b or w
      expect(chess).to_not be_valid
      expect(chess.errors[:turn_color]).to include("must be w or b")
    end

    it "board string" do
      chess = Chess.new("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP w Kk - 1 2") #only 7 rows
      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("must have 8 rows")
    end

    it "board string invalid column is short" do
      chess = Chess.new("rnbqkb/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w - - 1 2") #1st row only has 6 columns

      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("row has 6 columns, 8 required for each row")
    end

    it "board string invalid column consecutive numbers" do
      chess = Chess.new("rnbqkb11/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R c Kk - 1 2") #1st has consecutive numbers
      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("is invalid: consecutive numbers 1")
    end

    it "when pawn is on the promotion row 1" do
      chess = Chess.new("P3k3/8/8/8/8/8/8/4K3 w - - 0 1") #pawn on a8
      expect(chess).to_not be_valid
      expect(chess.errors[:invalid_position]).to include("there cannot be a pawn on black's promotion row")
    end

    it "when pawn is on the promotion row 8" do
      chess = Chess.new("4k3/8/8/8/8/8/8/4K2p w - - 0 1") #pawn on a8
      expect(chess).to_not be_valid
      expect(chess.errors[:invalid_position]).to include("there cannot be a pawn on white's promotion row")
    end

    it "when row has too many chars" do
      chess = Chess.new("r4rk1/1p2b1pp/1qn1pp1n/pN1p4/B2P4/PP2PPP1/2P2Q1P/R3K1Nbb Q KQkq 0 1") #last row has 9

      expect(chess).to_not be_valid
      expect(chess.errors[:position]).to include("row has 9 columns, 8 required for each row")
    end

    it "when fen does not specify fields correctly" do
      chess = Chess.new("junk")

      expect(chess).to_not be_valid
      expect(chess.errors[:base]).to include("FEN string must contain six space delimited fields")
    end

  end

  describe '#in_check?' do
    it "it is not in check from the starting position" do
      chess = Chess.new
      expect(chess.in_check?(WHITE)).to eql(false)
      expect(chess.in_check?(BLACK)).to eql(false)
    end

    it "black should be in check from pawn" do
      chess = Chess.new("3k4/4P3/8/8/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(true)

      chess = Chess.new("3k4/2P5/8/8/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(true)
    end

    it "white should be in check from pawn" do
      chess = Chess.new("3k4/8/8/8/8/8/4p3/3K4 w KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(true)

      chess = Chess.new("3k4/8/8/8/8/8/2p5/3K4 b KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(true)
    end

    it "black should not be in check from pawn" do
      chess = Chess.new("3k4/3P4/8/8/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(false)
    end

    it "white should not be in check from pawn" do
      chess = Chess.new("3k4/8/8/8/8/8/3p4/3K4 b KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(false)
    end

    it "black should be in check from queen" do
      chess = Chess.new("3k4/8/8/8/7Q/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(false)
      expect(chess.in_check?(BLACK)).to eql(true)
    end

    it "white should be in check from queen" do
      chess = Chess.new("3k4/8/8/7q/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(true)
      expect(chess.in_check?(BLACK)).to eql(false)
    end

    it "black should not be in check from queen, blocked by pawn" do
      chess = Chess.new("3k4/4p3/8/8/7Q/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(false)
    end

    it "white should not be in check from queen, blocked by pawn" do
      chess = Chess.new("3k4/8/8/7q/8/8/4P3/3K4 b KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(false)
    end

    it "black should be in check from rook" do
      chess = Chess.new("3k4/8/8/8/8/8/3R4/3K4 w KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(true)
    end

    it "white should be in check from rook" do
      chess = Chess.new("3k4/3r4/8/8/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(true)
    end

    it "black should not be in check from rook, blocked by pawn" do
      chess = Chess.new("3k4/3P4/8/8/8/8/3R4/3K4 w KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(false)
    end

    it "white should not be in check from rook, blocked by pawn" do
      chess = Chess.new("3k4/3r4/8/8/8/8/3P4/3K4 w KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(false)
    end

    it "black should be in check from bishop" do
      chess = Chess.new("3k4/8/8/8/7B/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(true)
    end

    it "white should be in check from bishop" do
      chess = Chess.new("3k4/8/8/7b/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(true)
    end

    it "black should not be in check from bishop, blocked by pawn" do
      chess = Chess.new("3k4/4p3/8/8/7B/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(false)
    end

    it "white should not be in check from bishop, blocked by pawn" do
      chess = Chess.new("3k4/8/8/7b/8/8/4P3/3K4 w KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(false)
    end

    it "black should be in check from knight" do
      chess = Chess.new("3k4/8/4N3/8/8/8/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(true)
    end

    it "white should be in check from knight" do
      chess = Chess.new("3k4/8/8/8/8/4n3/8/3K4 w KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(true)
    end

    it "black should still be in check from knight, pawns don't block" do
      chess = Chess.new("3k4/3pp3/4N3/8/8/8/8/3K4 b KQkq - 0 1")
      expect(chess.in_check?(BLACK)).to eql(true)
    end

    it "white should still be in check from knight, pawns don't block" do
      chess = Chess.new("3k4/8/8/8/8/4n3/3PP3/3K4 b KQkq - 0 1")
      expect(chess.in_check?(WHITE)).to eql(true)
    end

  end

  describe '#checkmate?' do
    it "should be checkmate (scholar's mate)" do
      chess = Chess.new "r1bqkbnr/ppp2Qpp/2np4/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 1"
      expect(chess.checkmate?).to eql(true)
    end
  end

  describe '#stalemate?' do
    it "should be stalemate" do
      chess = Chess.new "8/p7/P7/8/5q2/5k1K/8/8 w - - 0 1"
      expect(chess.stalemate?).to eql(true)
      expect(chess.checkmate?).to eql(false)
    end
  end

  describe '#move!' do
    let(:chess) { Chess.new }

    context "pawn moves" do
      it "succeeds when white pawn takes a double step" do
        chess = Chess.new(EMPTY_FEN_WHITE)
        chess.place_piece("P", "e2")

        chess.move!("e4")

        expect(chess.piece_at("e2")).to eql(nil)
        expect(chess.piece_at("e4")).to eql("P")
        expect(chess.turn_color).to eql("b")
        expect(chess.en_passant_square).to eql("e3")
      end

      it "succeeds when white pawn takes a single step" do
        chess = Chess.new(EMPTY_FEN_WHITE)
        chess.place_piece("P", "e2")

        chess.move!("e3")

        expect(chess.piece_at("e2")).to eql(nil)
        expect(chess.piece_at("e3")).to eql("P")
        expect(chess.turn_color).to eql("b")
        expect(chess.en_passant_square).to eql("-")
      end

      it "succeeds when black pawn takes a double step" do
        chess = Chess.new(EMPTY_FEN_BLACK)
        chess.place_piece("p", "e7")

        chess.move!("e5")

        expect(chess.piece_at("e7")).to eql(nil)
        expect(chess.piece_at("e5")).to eql("p")
        expect(chess.turn_color).to eql("w")
        expect(chess.en_passant_square).to eql("e6")
      end

      it "succeeds when black pawn takes a single step" do
        chess = Chess.new(EMPTY_FEN_BLACK)
        chess.place_piece("p", "e7")

        chess.move!("e6")

        expect(chess.piece_at("e2")).to eql(nil)
        expect(chess.piece_at("e6")).to eql("p")
        expect(chess.turn_color).to eql("w")
        expect(chess.en_passant_square).to eql("-")
      end
    end

    it "succeeds for a knight move" do
      chess.move!("Nc3")

      expect(chess.piece_at("b1")).to eql(nil)
      expect(chess.piece_at("c3")).to eql("N")
      expect(chess.turn_color).to eql("b")
      expect(chess.en_passant_square).to eql("-")
      expect(chess.fen).to eql("rnbqkbnr/pppppppp/8/8/8/2N5/PPPPPPPP/R1BQKBNR b KQkq - 1 1")
    end

    context "castling" do
      it "succeeds when white castles kingside" do
        chess = Chess.new(EMPTY_FEN_WHITE)
        chess.castling = "KQkq"
        chess.place_piece("K", "e1")
        chess.place_piece("R", "h1")
        chess.move!("O-O")

        expect(chess.piece_at("e1")).to be_nil
        expect(chess.piece_at("h1")).to be_nil
        expect(chess.piece_at("g1")).to eql("K")
        expect(chess.piece_at("f1")).to eql("R")
        expect(chess.turn_color).to eql("b")
        expect(chess.en_passant_square).to eql("-")
        expect(chess.fen).to eql("8/8/8/8/8/8/8/5RK1 b kq - 1 1") # castling string is updated for white
      end

      it "succeeds when white castles queenside" do
        chess = Chess.new(EMPTY_FEN_WHITE)
        chess.castling = "KQkq"
        chess.place_piece("K", "e1")
        chess.place_piece("R", "a1")

        chess.move!("O-O-O")

        expect(chess.piece_at("e1")).to be_nil
        expect(chess.piece_at("a1")).to be_nil
        expect(chess.piece_at("c1")).to eql("K")
        expect(chess.piece_at("d1")).to eql("R")
        expect(chess.turn_color).to eql("b")
        expect(chess.castling).to eql("kq") # castling string is updated for white
      end

      it "succeeds when black castles kingside" do
        chess = Chess.new(EMPTY_FEN_BLACK)
        chess.castling = "KQkq"
        chess.place_piece("k", "e8")
        chess.place_piece("r", "h8")
        chess.move!("O-O")

        expect(chess.piece_at("e8")).to be_nil
        expect(chess.piece_at("h8")).to be_nil
        expect(chess.piece_at("g8")).to eql("k")
        expect(chess.piece_at("f8")).to eql("r")
        expect(chess.turn_color).to eql("w")
        expect(chess.castling).to eql("KQ") # castling string is updated for black
      end

      it "succeeds when black castles queenside" do
        chess = Chess.new(EMPTY_FEN_BLACK)
        chess.castling = "KQkq"
        chess.place_piece("k", "e8")
        chess.place_piece("r", "a8")
        chess.move!("O-O-O")

        expect(chess.piece_at("e8")).to be_nil
        expect(chess.piece_at("a8")).to be_nil
        expect(chess.piece_at("c8")).to eql("k")
        expect(chess.piece_at("d8")).to eql("r")
        expect(chess.turn_color).to eql("w")
        expect(chess.castling).to eql("KQ") # castling string is updated for black
      end

      it "updates castling when white king moves" do
        chess = Chess.new(EMPTY_FEN_WHITE)
        chess.castling = "KQkq"
        chess.place_piece("K", "e1")
        chess.place_piece("R", "h1")
        chess.move!("Ke2")

        expect(chess.castling).to eql("kq")
      end

      it "updates castling when black king moves" do
        chess = Chess.new(EMPTY_FEN_BLACK)
        chess.castling = "KQkq"
        chess.place_piece("k", "e8")
        chess.place_piece("r", "h8")
        chess.move!("Ke7")

        expect(chess.castling).to eql("KQ")
      end

      it "updates castling when white kingside rook moves" do
        chess = Chess.new(EMPTY_FEN_WHITE)
        chess.castling = "KQkq"
        chess.place_piece("K", "e1")
        chess.place_piece("R", "h1")
        chess.move!("Rh2")

        expect(chess.castling).to eql("Qkq")
      end

      it "updates castling when white queenside rook moves" do
        chess = Chess.new(EMPTY_FEN_WHITE)
        chess.castling = "KQkq"
        chess.place_piece("K", "e1")
        chess.place_piece("R", "a1")
        chess.move!("Ra2")

        expect(chess.castling).to eql("Kkq")
      end

      it "updates castling when black kingside rook moves" do
        chess = Chess.new(EMPTY_FEN_BLACK)
        chess.castling = "KQkq"
        chess.place_piece("k", "e8")
        chess.place_piece("r", "h8")
        chess.move!("Rh7")

        expect(chess.castling).to eql("KQq")
      end

      it "updates castling when white queenside rook moves" do
        chess = Chess.new(EMPTY_FEN_BLACK)
        chess.castling = "KQkq"
        chess.place_piece("k", "e8")
        chess.place_piece("r", "a8")
        chess.move!("Ra7")

        expect(chess.castling).to eql("KQk")
      end
    end
  end
end
