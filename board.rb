require_relative 'tile'
require 'byebug'
require 'colorize'

class Board
  attr_accessor :grid

  def self.create_board(size, level)
    grid = Array.new(size) do
      Array.new(size) { Tile.random_tile(level) }
    end
    self.new(grid)
  end


  def initialize(grid)
    @grid = grid
  end

  def neighbors_bomb_count(pos)
    neighbors(pos).select { |pos| self[pos].bomb == true }.count
  end

  def size
    grid.length - 1
  end

  def bombs?
    grid.flatten.any? { |tile| tile.revealed && tile.bomb }
  end

  def won?
    grid.flatten.select { |tile| !tile.bomb }.all? { |tile| tile.revealed }
  end

  def neighbors(pos)
    neighbors = []
    x, y = pos
    -1.upto(1) do |horiz|
      -1.upto(1) do |vert|
        next if horiz == 0 && vert == 0
        i, j = x + horiz, y + vert
        next if [i, j].any? { |coord| coord < 0 || coord > size }
        neighbors << [i, j]
      end
    end
    neighbors
  end

  def render
    puts "  #{(0..size).to_a.join(" ") }"
    0.upto(size) do |x|
      tiles = []
      0.upto(size) do |y|
        if self[[x,y]].flagged
          tiles << "F".colorize(:light_blue)
        elsif !self[[x,y]].revealed
          tiles << "*"
        else
          if self[[x, y]].bomb
            tiles << "X".colorize(:red)
          else
            bombs = neighbors_bomb_count([x, y])
            case bombs
            when 0
              tiles << "_"
            when 1
              tiles << "#{bombs}".colorize(:blue)
            when 2
              tiles << "#{bombs}".colorize(:green)
            else
              tiles << "#{bombs}".colorize(:orange)
            end
          end
        end
      end
      puts "#{x} #{tiles.join(" ")}"
    end
  end

  def [](pos)
    x, y = pos
    grid[x][y]
  end

  def []=(pos, value)
    x, y = pos
    grid[x][y] = value
  end

  def reveal_all
    grid.flatten.each { |tile| tile.reveal }
  end

end
