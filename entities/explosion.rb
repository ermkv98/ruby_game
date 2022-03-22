# frozen_string_literal: true

class Explosion < GameObject
  attr_accessor :x, :y, :physics

  def initialize(object_pool, x, y)
    super(object_pool)
    @x, @y = x, y
    @physics = nil
    ExplosionGraphics.new(self)
    # ExplosionSounds.play
    inflict_damage
  end

  private

  def inflict_damage
    object_pool.nearby(self, 100).each do |obj|
      if obj.class == Cat
        obj.health.inflict_damage(
          Math.sqrt(3 * 100 - Utils.distance_between(obj.x, obj.y, x, y))
        )
      end
    end
  end
end
