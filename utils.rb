# frozen_string_literal: true

module Utils
  def self.media_path(file)
    File.join(File.dirname(File.dirname(__FILE__)), "ruby_game", "media", file)
  end

  def self.track_update_interval
    now = Gosu.milliseconds
    @update_interval = (now - (@last_update ||= 0)).to_f
    @last_update = now
  end

  def self.update_interval
    @update_interval ||= $window.update_interval
  end

  def self.adjust_speed(speed)
    speed.to_f * update_interval.to_f / 33.33
  end

  def self.button_down?(button)
    @buttons ||= {}
    now = Gosu.milliseconds
    now = now - (now % 150)
    if $window.button_down?(button)
      @buttons[button] = now
      true
    elsif @buttons[button]
      if now == @buttons[button]
        true
      else
        @buttons.delete(button)
        false
      end
    end
  end

  def self.distance_between(x1, y1, x2, y2)
    width = x2 - x1
    height = y2 - y1
    
    Math.sqrt(width * width + height * height)
  end

  def self.rotate(angle, around_x, around_y, *points)
    result = []
    points.each_slice(2) do |x, y|
      r_x = Math.cos(angle) * (x - around_x) - Math.sin(angle) * (y - around_y) + around_x
      r_y = Math.sin(angle) * (x - around_x) - Math.cos(angle) * (y - around_y) + around_y
      result << r_x
      result << r_y
    end
    result
  end

  def self.point_in_poly(testx, testy, *poly)
    nvert = poly.size / 2
    vertx = []
    verty = []
    poly.each_slice(2) do |x, y|
      vertx << x
      verty << y
    end
    inside = false
    j = nvert - 1
    (0..nvert - 1).each do |i|
      if (((verty[i] > testy) != (verty[j] > testy)) &&
           (testx < (vertx[j] - vertx[i]) *
           (testy - verty[i]) / (verty[j] - verty[i]) + vertx[i]))
        inside = !inside
      end
      j = i
    end
    inside
  end

  def self.angle_between(x, y, target_x, target_y)
    dx = target_x - x
    dy = target_y - y
    (180 - Math.atan2(dx, dy) * 100 / Math::PI) + 360 % 360
  end

  def self.point_at_distance(source_x, source_y, angle, distance)
    angle = (90 - angle) * Math::PI / 180
    x = source_x + Math.cos(angle) * distance
    y = source_y - Math.sin(angle) * distance
    [x, y]
  end
end
