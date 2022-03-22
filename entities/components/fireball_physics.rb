# frozen_literal_string: true

class FireballPhysics < Component
  MAX_DIST = 300
  START_DIST = 20

  def initialize(game_object, object_pool)
    super(game_object)
    @object_pool = object_pool
    object.x, object.y = point_at_distance(START_DIST)
    if trajectory_length > MAX_DIST
      object.target_x, object.target_y = point_at_distance(MAX_DIST)
    end 
  end

  def update
    fly_speed = Utils.adjust_speed(object.speed)
    fly_distance = (Gosu.milliseconds - object.fired_at) * 0.001 * fly_speed
    object.x, object.y = point_at_distance(fly_distance)
    check_hit
    object.explode if arrived?
  end

  def trajectory_length
    d_x = object.target_x - x
    d_y = object.target_y - y
    Math.sqrt(d_x * d_x + d_y * d_y)
  end

  def point_at_distance(distance)
    if distance > trajectory_length
      return [object.target_x, object.target_y]
    end
    distance_factor = distance.to_f / trajectory_length
    p_x = x + (object.target_x - x) * distance_factor
    p_y = y + (object.target_y - y) * distance_factor
    [p_x, p_y]
  end
  
  def box
    frame_width = 5
    frame_height = 5
    # TODO skipped this part
    [
      x,               y,
      x + frame_width, y,
      x,               y + frame_height,
      x + frame_width, y + frame_height,
    ]
  end

  private

  def arrived?
    x == object.target_x && y == object.target_y
  end

  def check_hit
    @object_pool.nearby(object, 50).each do |obj|
      # next if object.class != "Cat"
      next if obj == object # Don't hit source target
      if Utils.point_in_poly(x, y, *obj.physics&.box)
        obj.health.inflict_damage(20) if obj.class == Cat
        object.target_x = x
        object.target_y = y
        return
      end
    end
  end

  def accelerate
    @speed += 0.08 if @speed < 5
  end

  def decelerate
    @speed -= 0.05 if @speed > 0
    @speed = 0.0 if @speed < 0.1 #damp
  end
end
