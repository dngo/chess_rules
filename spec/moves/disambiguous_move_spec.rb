require 'spec_helper'
include ChessRules

describe DisambiguousMove do
  describe '.new' do
    context 'for a rank and file disambiguation' do
      it "returns when disambuated rooks are on the same file" do
        board = Board.new("8/8/8/8/4Q2Q/8/8/7Q w KQkq - 0 1")

        move = DisambiguousMove.new('Qh4e1', board)
        expect(move.from_squares).to eql(["h4"])
        expect(move.to_squares).to eql(["e1"])

        move = DisambiguousMove.new('Qe4e1', board)
        expect(move.from_squares).to eql(["e4"])
        expect(move.to_squares).to eql(["e1"])

        move = DisambiguousMove.new('Qh1e1', board)
        expect(move.from_squares).to eql(["h1"])
        expect(move.to_squares).to eql(["e1"])
        expect(move.lan).to eql("h1e1")
      end

      it "errors when piece is not on the expected rank" do
        board = Board.new("8/8/8/8/4Q2Q/8/8/7Q w KQkq - 0 1")

        expect { DisambiguousMove.new('Qh3e1', board) }.to raise_error(DisambiguousMoveError, "white queen cannot move to e1")
      end

      it "errors when piece is not on the expected file" do
        board = ChessRules::Board.new("8/8/8/8/4Q2Q/8/8/7Q w KQkq - 0 1")

        expect { DisambiguousMove.new('Qd4e1', board) }.to raise_error(DisambiguousMoveError, "white queen cannot move to e1")
      end
    end

    context 'for a rank disambiguation' do
      it "returns when disambuated rooks are on the same file" do
        board = Board.new("R7/8/8/8/8/8/8/R7 w KQkq - 0 1")

        move = DisambiguousMove.new('R1a2', board)
        expect(move.from_squares).to eql(["a1"])
        expect(move.to_squares).to eql(["a2"])

        move = DisambiguousMove.new('R8a2', board)
        expect(move.from_squares).to eql(["a8"])
        expect(move.to_squares).to eql(["a2"])
      end

      it "errors when piece is not on the expected file" do
        board = Board.new("1R6/8/8/8/8/8/8/1R6 w KQkq - 0 1")

        expect { DisambiguousMove.new('R1a2', board) }.to raise_error(DisambiguousMoveError, "white rook cannot move to a2")
      end
    end

    context 'for a file disambiguation' do
      it "returns when disambuated rooks are on the same row" do
        board = Board.new("R6R/8/8/8/8/8/8/8 w KQkq - 0 1")

        move = DisambiguousMove.new('Rab8', board)
        expect(move.from_squares).to eql(["a8"])
        expect(move.to_squares).to eql(["b8"])

        move = DisambiguousMove.new('Rhb8', board)
        expect(move.from_squares).to eql(["h8"])
        expect(move.to_squares).to eql(["b8"])
      end

      it "errors when piece is not on the expected file" do
        board = Board.new("1R6/8/8/8/8/8/8/1R6 w KQkq - 0 1")

        expect { DisambiguousMove.new('R1a2', board) }.to raise_error(DisambiguousMoveError, "white rook cannot move to a2")
      end
    end

    context 'when checkmating' do
      it "returns for disambiguated rank and file with checkmate" do
        board = Board.new("k7/2RR4/1R6/1R6/8/8/8/8 w KQkq - 0 1")

        move = DisambiguousMove.new('Rb6b8#', board)

        expect(move.from_squares).to eql(["b6"])
        expect(move.to_squares).to eql(["b8"])
      end

      it "returns for disambiguated rank with checkmate" do
        board = Board.new("1Q6/8/k7/8/8/8/8/1Q6 w KQkq - 0 1")

        move = DisambiguousMove.new('Q1b6#', board)

        expect(move.from_squares).to eql(["b1"])
        expect(move.to_squares).to eql(["b6"])
      end

      it "returns for disambiguated file with checkmate" do
        board = Board.new("3k4/Q6Q/8/8/8/8/8/8 w KQkq - 0 1")

        move = DisambiguousMove.new('Qad7#', board)

        expect(move.from_squares).to eql(["a7"])
        expect(move.to_squares).to eql(["d7"])
      end
    end

    context '.from_to_squares when capturing' do
      it "returns for a piece capture move" do
        board = Board.new("Q2p3Q/8/8/8/8/8/8/8 w KQkq - 0 1")

        move = DisambiguousMove.new('Qaxd8', board)

        expect(move.from_squares).to eql(["a8"])
        expect(move.to_squares).to eql(["d8"])
      end

      it "returns for a checking capture move" do
        board = Board.new("Q2p3Q/3k4/8/8/8/8/8/8 w KQkq - 0 1")

        move = DisambiguousMove.new('Qaxd8+', board)

        expect(move.from_squares).to eql(["a8"])
        expect(move.to_squares).to eql(["d8"])
      end

      it "returns for a double checking capture move" do
        board = Board.new("Q2p3Q/3k4/8/8/8/8/8/8 w KQkq - 0 1")

        move = DisambiguousMove.new('Qaxd8++', board)

        expect(move.from_squares).to eql(["a8"])
        expect(move.to_squares).to eql(["d8"])
      end
    end

    context 'when checking' do
      it "returns for a checking move" do
        board = Board.new("Q7/8/1k6/8/8/8/8/Q7 w KQkq - 0 1")

        move = DisambiguousMove.new('Q1a6+', board)

        expect(move.from_squares).to eql(["a1"])
        expect(move.to_squares).to eql(["a6"])
      end

      it "returns for a double checking move" do
        board = Board.new("3k4/8/3N4/N2Q4/8/8/8/8 w KQkq - 0 1")

        move = DisambiguousMove.new('N5b7++', board)

        expect(move.from_squares).to eql(["a5"])
        expect(move.to_squares).to eql(["b7"])
      end
    end

    context 'it fails when' do
      it "is the wrong side's turn" do
        board = Board.new("Q7/8/1k6/8/8/8/8/Q7 b KQkq - 0 1")

        expect { DisambiguousMove.new('Q1a6', board) }.to raise_error(DisambiguousMoveError, "black queen not found")
      end

      it "destination is unreachable by the current player's pieces" do
        board = Board.new("Q7/8/1k6/8/8/8/8/Q7 w KQkq - 0 1")

        expect { DisambiguousMove.new('Q1h2', board) }.to raise_error(DisambiguousMoveError, "white queen cannot move to h2")
      end
    end
  end

  describe '.disambiguated?' do
    context 'rank and file are disambiguated' do
      let(:board) { Board.new("8/8/8/8/7Q/8/8/8 w KQkq - 0 1") }

      it 'returns true when rank and file match the disambiguation' do
        move = DisambiguousMove.new('Qh4e1', board)

        expect(move.disambiguated?("h4")).to be_truthy
      end

      it 'returns false when file doesnt match the disambiguation' do
        move = DisambiguousMove.new('Qh4e1', board)

        expect(move.disambiguated?("a4")).to be_falsey
      end

      it 'returns false when rank doesnt match the disambiguation' do
        move = DisambiguousMove.new('Qh4e1', board)

        expect(move.disambiguated?("h5")).to be_falsey
      end
    end

    context 'file is disambiguated' do
      let(:board)  { Board.new("R7/8/8/8/8/8/8/8 w KQkq - 0 1") }

      it 'returns true when file matches the disambiguation' do
        move = DisambiguousMove.new('Rab8', board)

        expect(move.disambiguated?("a8")).to be_truthy
      end

      it 'returns false when file doesnt match the disambiguation' do
        move = DisambiguousMove.new('Rab8', board)

        expect(move.disambiguated?("h8")).to be_falsey
      end
    end

    context 'rank is disambiguated' do
      let(:board)  { Board.new("8/8/8/8/8/8/8/R7 w KQkq - 0 1") }

      it 'returns true when rank matches the disambiguation' do
        move = DisambiguousMove.new('R1a2', board)

        expect(move.disambiguated?("a1")).to be_truthy
      end

      it 'returns false when rank doesnt match the disambiguation' do
        move = DisambiguousMove.new('R1a2', board)

        expect(move.disambiguated?("a8")).to be_falsey
      end
    end
  end
end
