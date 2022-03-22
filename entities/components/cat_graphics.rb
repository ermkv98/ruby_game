# frozen_string_literal: true

class CatGraphics < Component
  DEBUG_COLORS = [
    Gosu::Color::RED,
    Gosu::Color::BLUE,
    Gosu::Color::YELLOW,
    Gosu::Color::WHITE,
  ]

  FRAME_DELAY = 120#ms

  attr_accessor :direction

  def animation
    @@animation ||= Gosu::Image.load_tiles($window, Utils.media_path('frog.png'), 32, 32, false)
  end

  def initialize(game_object)
    super(game_object)
    @body = units.frame("frog1_calm.png")
    @body_dead = dead_units.frame("cat1_dead.png")
    @current_frame = 0
    @direction = :right
    # @shadow = units.frame("cat1_shadow.png")
    # @stuff = units.frame("cat1_stuff.png")
  end

  def update
    # @current_frame += 1 if frame_expired?
    advance_frame
  end

  def draw(viewport)
    if object.physics.moving?
      @current_frame += 1
      advance_frame
    else
      @current_frame = direction_left? ? 0 : 4
      advance_frame
    end
    @body.draw(x, y)
    draw_bounding_box
    # @shadow.draw_rot(x - 1, y - 1, 0, object.direction)
    # @stuff.draw_rot(x, y, 2, object.shoot_angle)
  end

  def draw_bounding_box
    i = 0
    object.physics.box.each_slice(2) do |x, y|
      color = DEBUG_COLORS[i]
      $window.draw_triangle(
        x - 3, y - 3, color,
        x, y, color,
        x + 3, y - 3, color,
        100
      )
      i = (i + 1) % 4
    end
  end

  private

  def direction_left?
    @direction == :left
  end

  def units
    @@units = Gosu::TexturePacker.load_json(Utils.media_path("frog.json"))
  end

  def dead_units
    @@units = Gosu::TexturePacker.load_json(Utils.media_path("cats.json"))
  end

  def current_frame
    if direction_left?
      animation[@current_frame % 4]
    else
      animation[@current_frame % 4 + 4]
    end
  end

  def advance_frame
    now = Gosu.milliseconds
    delta = now - (@last_frame ||= now)
    if delta > FRAME_DELAY
      @last_frame = now
      @body = current_frame
    end
    @current_frame += (delta / FRAME_DELAY).floor
    @body = @body_dead if object.health.dead?
  end
end
