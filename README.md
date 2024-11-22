A chess library used for chess move generation/validation, piece placement/movement, and check/checkmate/stalemate
detection - basically everything but the AI.

used by <a href="https://www.chesshub.com">chesshub.com</a>

## Installation

Add chess_rules to your Gemfile and run bundle.

```ruby
gem 'chess_rules'
```

## Example Code
This is an example where both sides make moves and then castle kingside, moves are made using standard algebraic notation

```ruby
chess = Chess.new

puts chess.ascii
  #  r  n  b  q  k  b  n  r
  #  p  p  p  p  p  p  p  p
  #  -  -  -  -  -  -  -  -
  #  -  -  -  -  -  -  -  -
  #  -  -  -  -  -  -  -  -
  #  -  -  -  -  -  -  -  -
  #  P  P  P  P  P  P  P  P
  #  R  N  B  Q  K  B  N  R

chess.initial_fen # rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
chess.turn_color # w
chess.castling # KQkq
chess.en_passant_square # -
chess.half_moves # 0
chess.full_move # 1

chess.move!("e4") # white moves pawn
  #<ChessRules::PawnMove:0x0000000109134390 @san="e4", @color="w", @symbol="P", @from_squares=["e2"], @to_squares=["e4"], @promotion=nil, @en_passant_square="e3">

chess.move!("e5") # black moves pawn
  #<ChessRules::PawnMove:0x0000000107038ee8 @san="e5", @color="b", @symbol="p", @from_squares=["e7"], @to_squares=["e5"], @promotion=nil, @en_passant_square="e6">

chess.move!("Nf3") # white moves kingside knight
  #<ChessRules::StandardMove:0x0000000106d96320 @san="Nf3", @color="w", @symbol="N", @from_squares=["g1"], @to_squares=["f3"]>

chess.move!("Nf6") # black moves kingside knight
  #<ChessRules::StandardMove:0x0000000105e7eab8 @san="Nf6", @color="b", @symbol="n", @from_squares=["g8"], @to_squares=["f6"]>

chess.move!("O-O") # white attempts to castle, but bishop is in the way
  *** CastlingMoveError Exception: f1 square is not empty

chess.move!("Be2") # white moves kingside bishop out of the way
  #<ChessRules::StandardMove:0x0000000106ddb790 @san="Be2", @color="w", @symbol="B", @from_squares=["f1"], @to_squares=["e2"]>

chess.move!("Be7") # black moves kingside bishop
  #<ChessRules::StandardMove:0x0000000109132180 @san="Be7", @color="b", @symbol="b", @from_squares=["f8"], @to_squares=["e7"]>

chess.move!("O-O") # now that bishop out of the way, white can castle
  #<ChessRules::CastlingMove:0x0000000107031d28 @san="O-O", @color="w", @symbol="K", @from_squares=["e1", "h1"], @to_squares=["g1", "f1"]>

chess.move!("O-O") # black castles
  #<ChessRules::CastlingMove:0x0000000105f94d80 @san="O-O", @color="b", @symbol="k", @from_squares=["e8", "h8"], @to_squares=["g8", "f8"]>

chess.fen
  # rnbq1rk1/ppppbppp/5n2/4p3/4P3/5N2/PPPPBPPP/RNBQ1RK1 w - - 6 5

puts chess.ascii
  #  r  n  b  q  -  r  k  -
  #  p  p  p  p  b  p  p  p
  #  -  -  -  -  -  n  -  -
  #  -  -  -  -  p  -  -  -
  #  -  -  -  -  P  -  -  -
  #  -  -  -  -  -  N  -  -
  #  P  P  P  P  B  P  P  P
  #  R  N  B  Q  -  R  K  -
```

## API

### Constructor

The .new constructor takes an optional parameter which specifies the board configuration in
[Forsyth-Edwards Notation (FEN)](http://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation).
Throws an exception if an invalid FEN string is provided.

```ruby
# an empty constructor defaults the starting position
chess = Chess.new

# pass in a FEN string to load a particular position
chess = Chess.new('r1k4r/p2nb1p1/2b4p/1p1n1p2/2PP4/3Q1NB1/1P3PPP/R5K1 b - - 0 19')
```

### .move!(san)

Takes a string in [Standard Algebraic Notation (SAN)](https://en.wikipedia.org/wiki/Algebraic_notation_(chess)).
makes the move and returns a move object
Throws an exception if invalid notation or an invalid move is provided
```sh
chess = Chess.new

chess.move!("e4") # white moves pawn
  # <ChessRules::PawnMove:0x00000001238b8430 @san="e4", @color="w", @symbol="P", @from_squares=["e2"], @to_squares=["e4"], @promotion=nil, @en_passant_square="e3">

chess.move!("Nf6") # black moves kingside knight
  #<ChessRules::StandardMove:0x0000000105e7eab8 @san="Nf6", @color="b", @symbol="n", @from_squares=["g8"], @to_squares=["f6"]>
```

### .ascii
prints an ascii representation of the board

```ruby
chess = Chess.new()
chess.ascii
  r  n  b  q  -  r  k  -
  p  p  p  p  b  p  p  p
  -  -  -  -  -  n  -  -
  -  -  -  -  p  -  -  -
  -  -  -  -  P  -  -  -
  -  -  -  -  -  N  -  -
  P  P  P  P  B  P  P  P
  R  N  B  Q  -  R  K  -
```

### .fen
Returns the FEN string for the current position.

```ruby
chess = Chess.new()

chess.fen
  # rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1

```

### .valid?
returns a boolean specifying validity or the errors found within the FEN string.

```ruby
chess = Chess.new()

chess.valid? # true

chess = Chess.new("junk")

chess.valid? # false

chess.errors
  #<ActiveModel::Errors [#<ActiveModel::Error attribute=base, type=FEN string must contain six space delimited fields, options={}>]>
```
