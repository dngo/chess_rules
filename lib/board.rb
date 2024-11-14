module ChessRules
  class Board
    attr_accessor :board_2d, :turn_color

    #  SQUARE_NAMES = {
    #    a8:   0, b8:   1, c8:   2, d8:   3, e8:   4, f8:   5, g8:   6, h8:   7,
    #    a7:   8, b7:   9, c7:  10, d7:  11, e7:  12, f7:  13, g7:  14, h7:  15,
    #    a6:  16, b6:  17, c6:  18, d6:  19, e6:  20, f6:  21, g6:  22, h6:  23,
    #    a5:  24, b5:  25, c5:  26, d5:  27, e5:  28, f5:  29, g5:  30, h5:  31,
    #    a4:  32, b4:  33, c4:  34, d4:  35, e4:  36, f4:  37, g4:  38, h4:  39,
    #    a3:  40, b3:  41, c3:  42, d3:  43, e3:  44, f3:  45, g3:  46, h3:  47,
    #    a2:  48, b2:  49, c2:  50, d2:  51, e2:  52, f2:  53, g2:  54, h2:  55,
    #    a1:  56, b1:  57, c1:  58, d1:  59, e1:  60, f1:  61, g1:  62, h1:  63
    #  }.with_indifferent_access

    RANKS = [8, 7, 6, 5, 4, 3, 2, 1]
    FILES = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

    def initialize(fen = STARTING_FEN)
      self.board_2d = Array.new(RANKS.length) { Array.new(FILES.length) }
      self.turn_color = fen.split(/\s+/)[1]

      parse_fen(fen)
    end

    def move!(notation)
      move = MoveFactory.create(notation, self)

      move.from_squares.each_with_index do |from, index|
        move_from_to!(Board.get_coordinates(from), Board.get_coordinates(move.to_squares[index]), move.promotion)
      end

      self.turn_color = swap_color(turn_color)
      move
    end


    def clear!
      self.board_2d = Array.new(RANKS.length) { Array.new(FILES.length) }
    end

    #we check for attack using pieces of the same color
    #place a piece of each type onto the square
    #if it can attack any opponents piece from the square, inversely an opponent piece of the same type can attack the square
    #this is faster than looping through all the opponents pieces and
    #seeing if they can attack this square, since this is only 5 piece checks
    #its faster as long as the opponent has more than 5 pieces left
    def attacked?(attacker_color, coordinate)
      piece_chars = attacker_color == WHITE ? BLACK_PIECES : WHITE_PIECES
      piece_chars.each do |char|
        piece = PieceFactory.create(char, coordinate, board_2d)
        piece.moves.each do |move|
          if piece.color == WHITE
            return true if piece.char.downcase == piece_at(move)
          elsif piece.color == BLACK
            return true if piece.char.upcase == piece_at(move)
          end
        end
      end

      false
    end

    # accepts piece and either square_name or rank and file
    def place_piece(*args)
      case args.length # hack since ruby doesnt support method overloading
      when 2
        piece, square_name = args[0], args[1]
        rank, file = Board.get_coordinates(square_name)
      when 3
        piece, rank, file = args[0], args[1], args[2]
      else
        raise ArgumentError, "Invalid number of arguments: expected 1 or 2, got #{args.length}"
      end

      return false unless PIECES.include?(piece) #check for piece

      board_2d[rank][file] = piece
    end

    def self.get_coordinates(square_name)
      rank = RANKS.index square_name[-1].to_i
      file = FILES.index square_name[0]
      [rank, file]
    end

    def self.get_algebraic(coordinate)
    "#{FILES[coordinate.last]}#{RANKS[coordinate.first]}"
    end

    def self.get_square_num(coordinates)
      coordinates.first * 8 + coordinates.last
    end

    #takes algebraic name or coordinate
    def piece_at(square)
      if square.is_a?(Array)
        board_2d[square.first][square.last]
      else
        rank = RANKS.index(square[-1].to_i)
        file = FILES.index(square[0])
        board_2d[rank][file]
      end
    end

    def find_piece(search_char)
      coordinates = []
      board_2d.each.with_index do |chars, rank|
        chars.each.with_index do |char, file|
          coordinates << [rank, file] if board_2d[rank][file] == search_char
        end
      end

      coordinates
    end

    def to_fen
      fen = ''

      empty = 0
      board_2d.each.with_index do |chars, rank|
        chars.each.with_index do |char, file|
          if char
            if empty > 0
              fen += empty.to_s
              empty = 0
            end
            fen += char
          else
            empty += 1
          end

          if file == 7 #last file
            if empty > 0
              fen += empty.to_s
              empty = 0
            end
            fen += "/" unless rank == 7 && file == 7
          end
        end
      end

      fen
    end

    def move_from_to(from, to)
      test_board = Marshal.load(Marshal.dump(board_2d)) #the only real way to copy any array, dup and clone still result in references, not true copy

      test_board[to.first][to.last] = test_board[from.first][from.last]
      test_board[from.first][from.last] = nil
      test_board
    end

    def move_from_to!(from, to, promotion = nil)
      board_2d[to.first][to.last] = board_2d[from.first][from.last]
      board_2d[to.first][to.last] = promotion if promotion
      board_2d[from.first][from.last] = nil
      board_2d
    end

    def swap_color(color)
      color == WHITE ? BLACK : WHITE
    end

    protected

    def parse_fen(fen)
      position = fen.split(/\s+/)[0]

      rank, file = 0, 0
      position.each_char do |char|
        case char
        when /\d/
          file += char.to_i
        when "/"
          rank, file = next_rank(rank)
        else
          place_piece_if_in_bounds(char, rank, file)
          file += 1
        end
      end
    end

    def next_rank(current_rank)
      [current_rank + 1, 0]
    end

    def place_piece_if_in_bounds(char, rank, file)
      return if file > 7 || rank > 7

      place_piece(char, rank, file)
    end

  end
end
