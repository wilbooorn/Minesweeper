require_relative 'board'
require 'byebug'
require 'time'
require 'yaml'

class Minesweeper
  attr_accessor :board

  def initialize(size = 9, level = 1)
    @board = Board.create_board(size, level)
  end

  def run
    start = Time.now
    board.render
    until over?
      make_move(get_input)
      board.render
    end
    end_time = Time.now
    board.reveal_all
    board.render
    if board.bombs?
      puts "You lost in #{(end_time - start).to_i/60} minutes, #{((end_time - start)%60).to_i} seconds."
    else
      puts "Congrats! You won in #{(end_time - start).to_i/60} minutes, #{((end_time - start)%60).to_i} seconds."
    end
  end

  def get_input
    pos = nil
    until valid?(pos)
      puts "> Enter a position in the form of x,y."
      puts "> To flag a bomb, enter \'f\'."
      puts "> To save, enter \'s\'"
      print ">> "
      pos = gets.chomp
      flag(pos) if pos=='f'
      save if pos=='s'
    end
    pos.split(",").map(&:to_i)
  end

  def save
    File.open('minesweeper', 'w') {|f| f.write(YAML.dump(board))}
    puts "Saved!"
  end

  def flag(pos)
    until valid_flag?(pos)
      print "Please input a position to flag or unflag in the form of x,y.\n>> "
      pos = gets.chomp
    end
    pos = pos.split(",").map(&:to_i)
    board[pos].flagged ? board[pos].flagged = false : board[pos].flagged = true
    board.render
  end

  def valid_flag?(pos)
    return false unless pos =~ /\d,\d/
    pos = pos.split(",").map(&:to_i)
    return false if pos.any? { |el| el < 0 || el > board.size }
    board[pos].revealed == false
    true
  end

  def valid?(pos)
    return false unless pos =~ /\d,\d/
    pos = pos.split(",").map(&:to_i)
    return false if pos.any? { |el| el < 0 || el > board.size }
    if board[pos].flagged == true
      puts "You must unflag #{pos} before revealing it."
      return false
    end
    true
  end

  def make_move(pos)
    board[pos].reveal
    explore_neighbors(pos) unless board[pos].bomb
  end

  def explore_neighbors(pos)
    if board[pos].bomb
      return
    elsif board.neighbors_bomb_count(pos) > 0
      board[pos].reveal
      return
    else
      board[pos].reveal
      neighbors = board.neighbors(pos)
      neighbors.each do |pos|
        explore_neighbors(pos) unless board[pos].revealed
      end
    end
  end

  def over?
    board.bombs? || board.won?
  end
end

if __FILE__==$PROGRAM_NAME
  game = Minesweeper.new
  game.run
end
