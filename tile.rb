# require_relative 'board'

class Tile
  attr_accessor :bomb, :flagged, :revealed

  def initialize(bomb = false)
    @bomb = bomb
    @flagged = false
    @revealed = false
  end

  def self.random_tile(level)
    rand(10 - level).zero? ? Tile.new(true) : Tile.new
  end

  def inspect
    { bomb: bomb, flagged: flagged, revealed: revealed }.inspect
  end

  def reveal
    self.revealed = true if revealed == false
  end
end
