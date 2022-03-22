# frozen_string_literal: true

class AiVision
  CACHE_TIMEOUT = 500
  attr_reader :in_sight

  def initialize(viewer, object_pool, distance)
    @viewer = viewer
    @object_pool = object_pool
    @distance = distance
  end

  def update
    @in_sight = @object_pool.nearby(@viewer, @distance)
  end

  def closest_tank
    now = Gosu.milliseconds
    @closest_tank = nil
    if now - (@cache_updated_at ||= 0) > CACHE_TIMEOUT
      @closest_tank = nil
      @cache_updated_at = now
    end
    @closest_tank ||= find_closest_tank
  end

  private

  def find_closest_tank
    @in_sight.select do |obj|
      obj.class == Cat && !obj.health.dead?
    end.sort do |first_target, second_target|
      x, y = @viewer.x, @viewer.y
      d1 = Utils.distance_between(x, y, first_target.x, first_target.y)
      d2 = Utils.distance_between(x, y, second_target.x, second_target.y)
      d1 <=> d2
    end.first
  end
end
