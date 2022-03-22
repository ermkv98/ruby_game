# frozen_string_literal: true

class Cat < GameObject
  SHOOT_DELAY = 500
  attr_accessor :x, :y, :throttle_down, :direction, :shoot_angle, :sounds, :physics, :graphics, :health

  def initialize(object_pool, input)
    super(object_pool)
    @input = input
    @input.control(self)
    @direction = rand(0..7) * 45
    @physics = CatPhyscis.new(self, object_pool)
    @graphics = CatGraphics.new(self)
    @sounds = CatSounds.new(self)
    @health = CatHealth.new(self, object_pool)
    @shoot_angle = rand(0..360)
  end

  def shoot(target_x, target_y)
    if Gosu.milliseconds - (@last_shot || 0) > SHOOT_DELAY
      @last_shot = Gosu.milliseconds
      Fireball.new(object_pool, @x, @y, target_x, target_y).fire(100)
    end
  end
end
