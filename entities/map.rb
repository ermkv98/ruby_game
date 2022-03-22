require "perlin_noise"
require "gosu_texture_packer"
require "pry"

class Map
  MAP_WIDTH = 20
  MAP_HEIGHT = 20
  TILE_SIZE = 32

  attr_accessor :map

  def initialize(object_pool)
    load_tiles
    @object_pool = object_pool
    object_pool.map = self
    @map = generate_map
    generate_trees
  end

  def find_spawn_point
    while true
      x = rand(0..MAP_WIDTH * TILE_SIZE)
      y = rand(0..MAP_HEIGHT * TILE_SIZE)
      if can_move_to?(x, y)
        return [x, y]
      else
        puts "Invalid spawn point: #{[x, y]}"
      end
    end
  end

  def can_move_to?(x, y)
    return false if x.negative? || y.negative?

    tile = tile_at(x, y)
    index = [@water, @grass2, @grass4].find_index(tile)
    tile_names = [:water, :grass2, :grass4]
    if tile
      [@grass4, @grass2].include?(tile)
    else
      false
    end
  end

  def movement_penalty(x, y)
    tile = tile_at(x, y)
    case tile
    when @grass2
      0.33
    else
      0
    end
  end

  def draw(viewport)
    # viewport = camera.viewport
    viewport.map! { |coord| coord / TILE_SIZE }
    x0, x1, y0, y1 = viewport.map(&:to_i)
    (x0..x1).each do |x|
      (y0..y1).each do |y|
        row = @map[x]
        map_x = x * TILE_SIZE
        map_y = y * TILE_SIZE
        if row
          tile = @map[x][y]
          if tile
            tile.draw(map_x, map_y, 0)
          else
            @water.draw(map_x, map_y, 0)
          end
        else
          @water.draw(map_x, map_y, 0)
        end
      end
    end
          
    # @map.each do |x, row|
    #   row.each do |y, val|
    #     tile = @map[x][y]
    #     map_x = x * TILE_SIZE
    #     map_y = y * TILE_SIZE
    #     tile.draw(map_x, map_y, 0)
    #   end
    # end
  end

  private

  def tile_at(x, y)
    t_x = ((x / TILE_SIZE) % TILE_SIZE).floor
    t_y = ((y / TILE_SIZE) % TILE_SIZE).floor
    row = @map[t_x]
    row ? row[t_y] : @water
  end

  def load_tiles
    # tiles = Gosu::Image.load_tiles($window, Game.media_path("ground.png"), 32, 32, true)
    @ground = Gosu::TexturePacker.load_json(Utils.media_path("ground.json"), :precise)
    @grass = @ground.frame("grass1.png")
    @grass2 = @ground.frame("grass2.png")
    @grass3 = @ground.frame("grass3.png")
    @grass4 = @ground.frame("grass4.png")
    @water = @ground.frame("water1.png")
    @water2 = @ground.frame("water2.png")
    @water3 = @ground.frame("water3.png")
    # @tree = @ground.frame("tree1.png")
    # @sand = tiles[3]
    # @grass = tiles[8]
    # @water = tiles[5]
  end

  def generate_map
    noises = Perlin::Noise.new(2)
    contrast = Perlin::Curve.contrast(Perlin::Curve::CUBIC, 2)
    map = {}
    MAP_WIDTH.times do |x|
      map[x] = {}
      MAP_HEIGHT.times do |y|
        n = noises[x * 0.1, y * 0.1]
        n = contrast.call(n)
        map[x][y] = choose_tile(n)
      end
    end

    map
  end

  def generate_trees
    noises = Perlin::Noise.new(2)
    contrast = Perlin::Curve.contrast(Perlin::Curve::CUBIC, 2)
    trees = 0
    target_trees = rand(100..200)
    while trees < target_trees
      x = rand(0..MAP_WIDTH * TILE_SIZE)
      y = rand(0..MAP_HEIGHT * TILE_SIZE)
      n = noises[x * 0.001, y * 0.001]
      n = contrast.call(n)
      if tile_at(x, y) == @grass4 && n > 0.5
        Tree.new(@object_pool, x, y, n * 2 - 1)
        trees += 1
      end
    end
  end

  # def choose_tile(val)
  #   case val
  #   # when 0.0..0.3
  #   #   @water
  #   # when 0.3..0.45
  #   #   @sand
  #   # else
  #   #   @grass
  #   # end
  #   when 0.0..0.1
  #     @water
  #   when 0.1..0.2
  #     @water2
  #   when 0.2..0.3
  #     @water3
  #   when 0.3..0.35
  #     @grass
  #   when 0.35..0.4
  #     @grass2
  #   when 0.4..0.8
  #     @grass4
  #   when 0.8..0.9
  #     @grass3
  #   else
  #     @tree
  #   end
  # end

  def choose_tile(val)
    case val
    when 0.0..0.3
      @water
    when 0.3..0.4
      @grass2
    else
      @grass4
    end
  end
end
