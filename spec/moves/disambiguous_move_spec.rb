require 'spec_helper'

describe ChessRules::DisambiguousMove do
  describe '.new' do
    it "initializes correctly with a notation" do
      notation = "Ka2"

      move = ChessRules::DisambiguousMove.new(notation)

      expect(move.notation).to eql("Ka2")
    end
  end

  describe '.disambiguated?' do
    context 'rank and file are disambiguated' do
      it 'returns true when rank and file match the disambiguation' do
        move = ChessRules::DisambiguousMove.new('Qh4e1')

        result = move.disambiguated?("h4")

        expect(result).to be_truthy
      end

      it 'returns false when file doesnt match the disambiguation' do
        move = ChessRules::DisambiguousMove.new('Qh4e1')

        result = move.disambiguated?("a4")

        expect(result).to be_falsey
      end

      it 'returns false when rank doesnt match the disambiguation' do
        move = ChessRules::DisambiguousMove.new('Qh4e1')

        result = move.disambiguated?("h5")

        expect(result).to be_falsey
      end
    end

    context 'file is disambiguated' do
      it 'returns true when file matches the disambiguation' do
        move = ChessRules::DisambiguousMove.new('Rab8')

        result = move.disambiguated?("a8")

        expect(result).to be_truthy
      end

      it 'returns false when file doesnt match the disambiguation' do
        move = ChessRules::DisambiguousMove.new('Rab8')

        result = move.disambiguated?("h8")

        expect(result).to be_falsey
      end
    end

    context 'rank is disambiguated' do
      it 'returns true when rank matches the disambiguation' do
        move = ChessRules::DisambiguousMove.new('R1a2')

        result = move.disambiguated?("a1")

        expect(result).to be_truthy
      end

      it 'returns false when rank doesnt match the disambiguation' do
        move = ChessRules::DisambiguousMove.new('R1a2')

        result = move.disambiguated?("a8")

        expect(result).to be_falsey
      end
    end
  end

  describe '.from_to_squares' do
    context 'for a rank and file disambiguation' do
      it "returns when disambuated rooks are on the same file" do
        board = ChessRules::Board.new("8/8/8/8/4Q2Q/8/8/7Q w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Qh4e1')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("h4")
        expect(to).to eql("e1")

        move = ChessRules::DisambiguousMove.new('Qe4e1')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("e4")
        expect(to).to eql("e1")

        move = ChessRules::DisambiguousMove.new('Qh1e1')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("h1")
        expect(to).to eql("e1")
      end

      it "errors when piece is not on the expected rank" do
        board = ChessRules::Board.new("8/8/8/8/4Q2Q/8/8/7Q w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Qh3e1')

        expect{ move.from_to_squares(board) }.to raise_error(DisambiguousMoveError, "white queen cannot move to e1")
      end

      it "errors when piece is not on the expected file" do
        board = ChessRules::Board.new("8/8/8/8/4Q2Q/8/8/7Q w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Qd4e1')

        expect{ move.from_to_squares(board) }.to raise_error(DisambiguousMoveError, "white queen cannot move to e1")
      end
    end

    context 'for a rank disambiguation' do
      it "returns when disambuated rooks are on the same file" do
        board = ChessRules::Board.new("R7/8/8/8/8/8/8/R7 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('R1a2')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a1")
        expect(to).to eql("a2")

        move = ChessRules::DisambiguousMove.new('R8a2')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a8")
        expect(to).to eql("a2")
      end

      it "errors when piece is not on the expected file" do
        board = ChessRules::Board.new("1R6/8/8/8/8/8/8/1R6 w KQkq - 0 1")
        move = ChessRules::DisambiguousMove.new('R1a2')

        expect{ move.from_to_squares(board) }.to raise_error(DisambiguousMoveError, "white rook cannot move to a2")
      end
    end

    context 'for a file disambiguation' do
      it "returns when disambuated rooks are on the same row" do
        board = ChessRules::Board.new("R6R/8/8/8/8/8/8/8 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Rab8')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a8")
        expect(to).to eql("b8")

        move = ChessRules::DisambiguousMove.new('Rhb8')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("h8")
        expect(to).to eql("b8")
      end

      it "errors when piece is not on the expected file" do
        board = ChessRules::Board.new("1R6/8/8/8/8/8/8/1R6 w KQkq - 0 1")
        move = ChessRules::DisambiguousMove.new('R1a2')

        expect{ move.from_to_squares(board) }.to raise_error(DisambiguousMoveError, "white rook cannot move to a2")
      end

    end

    describe '.from_to_squares when checkmating' do
      it "returns for disambiguated rank and file with checkmate" do
        board = ChessRules::Board.new("k7/2RR4/1R6/1R6/8/8/8/8 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Rb6b8#')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b6")
        expect(to).to eql("b8")
      end

      it "returns for disambiguated rank with checkmate" do
        board = ChessRules::Board.new("1Q6/8/k7/8/8/8/8/1Q6 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Q1b6#')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("b1")
        expect(to).to eql("b6")
      end

      it "returns for disambiguated file with checkmate" do
        board = ChessRules::Board.new("3k4/Q6Q/8/8/8/8/8/8 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Qad7#')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a7")
        expect(to).to eql("d7")
      end
    end

    describe '.from_to_squares when capturing' do
      it "returns for a piece capture move" do
        board = ChessRules::Board.new("Q2p3Q/8/8/8/8/8/8/8 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Qaxd8')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a8")
        expect(to).to eql("d8")
      end

      it "returns for a checking capture move" do
        board = ChessRules::Board.new("Q2p3Q/3k4/8/8/8/8/8/8 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Qaxd8+')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a8")
        expect(to).to eql("d8")
      end

      it "returns for a double checking capture move" do
        board = ChessRules::Board.new("Q2p3Q/3k4/8/8/8/8/8/8 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Qaxd8++')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a8")
        expect(to).to eql("d8")
      end
    end

    describe '.from_to_squares when checking' do
      it "returns for a checking move" do
        board = ChessRules::Board.new("Q7/8/1k6/8/8/8/8/Q7 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Q1a6+')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a1")
        expect(to).to eql("a6")
      end

      it "returns for a double checking move" do
        board = ChessRules::Board.new("3k4/8/3N4/N2Q4/8/8/8/8 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('N5b7++')
        from, to = move.from_to_squares(board)[0]

        expect(from).to eql("a5")
        expect(to).to eql("b7")
      end
    end

    describe '.from_to_squares when' do
      it "it is the wrong side's turn" do
        board = ChessRules::Board.new("Q7/8/1k6/8/8/8/8/Q7 b KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Q1a6')

        expect{ move.from_to_squares(board) }.to raise_error(DisambiguousMoveError, "black queen not found")
      end

      it "destination is unreachable by the current player's pieces" do
        board = ChessRules::Board.new("Q7/8/1k6/8/8/8/8/Q7 w KQkq - 0 1")

        move = ChessRules::DisambiguousMove.new('Q1h2')

        expect{ move.from_to_squares(board) }.to raise_error(DisambiguousMoveError, "white queen cannot move to h2")
      end
    end
  end
end
