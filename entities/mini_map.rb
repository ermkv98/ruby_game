# frozen_string_literal: true

class MiniMap
  UPDATE_FREQUENCY = 1_000
  WIDTH = 150
  HEIGHT = 100
  PADDING = 10
  BACKGROUND = Gosu::Color.new(255 * 0.33, 0, 0, 0)
  attr_accessor :target

  def initialize(object_pool, target)
    @object_pool = object_pool
    @target = target
    @last_update = 0
  end

  def update
    if Gosu.milliseconds - @last_update > UPDATE_FREQUENCY
      @nearby = nil
    end
    @nearby ||= @object_pool.nearby(@target, 2_000).select do |obj|
      obj.class == Cat && !obj.health.dead?
    end
  end

  def draw
    x1, y1, x2, y2 = mini_map_coords
    $window.draw_quad(
      x1, y1, BACKGROUND,
      x2, y1, BACKGROUND,
      x2, y2, BACKGROUND,
      x1, y2, BACKGROUND,
      200
    )
    draw_cat(@target, Gosu::Color::GREEN)
    @nearby && @nearby.each do |obj|
      draw_cat(obj, Gosu::Color::RED)
    end
  end

  private

  def draw_cat(cat, color)
    x1, y1, x2, y2 = mini_map_coords
    tx = x1 + WIDTH / 2 + (cat.x - @target.x) / 20
    ty = y1 + HEIGHT / 2 + (cat.y - @target.y) / 20
    if (x1..x2).include?(tx) && (y1..y2).include?(ty)
      $window.draw_quad(
        tx - 2, ty - 2, color,
        tx + 2, ty - 2, color,
        tx + 2, ty + 2, color,
        tx - 2, ty - 2, color,
        300
      )
    end
  end

  def mini_map_coords
    x1 = $window.width - WIDTH - PADDING
    x2 = $window.width - PADDING
    y1 = $window.height - HEIGHT + PADDING
    y2 = $window.height - PADDING
    [x1, y1, x2, y2]
  end
end
