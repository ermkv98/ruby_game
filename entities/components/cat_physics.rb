# frozen_string_literal: true

class CatPhyscis < Component
  attr_accessor :speed

  def initialize(game_object, object_pool)
    super(game_object)
    @object_pool = object_pool
    @map = object_pool.map
    game_object.x, game_object.y = *@map.find_spawn_point
    @speed = 0.0
  end

  def can_move_to?(x, y)
    old_x, old_y = object.x, object.y
    object.x = x
    object.y = y
    return false unless @map.can_move_to?(x, y)
    @object_pool.nearby(object, 100).each do |obj|
      if collides_with_poly?(obj.physics&.box)
        # Allow to get unstuck
        old_distance = Utils.distance_between(obj.x, obj.y, old_x, old_y)
        new_distance = Utils.distance_between(obj.x, obj.y, x, y)
        return false if new_distance < old_distance
      end
    end
    true
  ensure
    object.x = old_x
    object.y = old_y
  end

  def moving?
    @speed > 0
  end

  def update
    if object.throttle_down && !object.health.dead?
      accelerate
    else
      decelerate
    end
    if moving?
      new_x, new_y = x, y
      speed = apply_movement_penalty(@speed)
      shift = Utils.adjust_speed(speed)
      case @object.direction.to_i
      when 0
        new_y -= shift
      when 45
        new_x += shift
        new_y -= shift
      when 90
        new_x += shift
      when 135
        new_x += shift
        new_y += shift
      when 180
        new_y += shift
      when 225
        new_x -= shift
        new_y += shift
      when 270
        new_x -= shift
      when 315
        new_x -= shift
        new_y -= shift
      end
      if can_move_to?(new_x, new_y)
        object.x, object.y = new_x, new_y
      else
        object.sounds.collide if @speed > 1
        @speed = 0.0
      end
    end
  end

  def box
    frame_width = 32
    frame_height = 32
    # TODO skipped this part
    [
      x,               y,
      x + frame_width, y,
      x,               y + frame_height,
      x + frame_width, y + frame_height,
    ]
  end

  def change_direction(new_direction)
    change = (new_direction - object.direction + 360) % 360
    change = 360 - change if change > 180
    if change > 90
      @speed = 0
    elsif change > 45
      @speed *= 0.33
    elsif change > 0
      @speed *= 0.66
    end
    object.direction = new_direction
  end

  def on_collision(object)
    return unless object
    # Avoid recursion
    if object.class == Cat
      # Inform Ai about hit
      object.input.on_collision(object)
    else
      # Call only on non-cats to avoid recursion
      object.on_collision(self)
    end
    # Fireballs should not slow down cats
    if object.class != Fireball
      @sounds.collide if @physics.speed > 1
    end
  end

  private

  def collides_with_poly?(poly)
    if poly
      poly.each_slice(2) do |x, y|
        return true if Utils.point_in_poly(x, y, *box)
      end
      box.each_slice(2) do |x, y|
        return true if Utils.point_in_poly(x, y, *poly)
      end
    end
    false
  end

  def apply_movement_penalty(speed)
    speed * (1.0 - @map.movement_penalty(x, y))
  end

  def accelerate
    @speed += 0.08 if @speed < 5
  end

  def decelerate
    @speed -= 0.05 if @speed > 0
    @speed = 0.0 if @speed < 0.1 #damp
  end
end
