# frozen_string_literal: true

class AiCatFleeingState < AiCatMotionState
  def initialize(object, vision, fireball)
    super(object, vision)
    @object = object
    @vision = vision
    @fireball = fireball
  end

  def update
    change_direction if should_change_direction?
    drive
  end

  def change_direction
    @object.physics.change_direction(@fireball.desired_shoot_angle - @fireball.desired_shoot_angle % 45)
    @changed_direction_at = Gosu.milliseconds
    @will_keep_direction_for = turn_time
  end

  def drive_time
    10_000
  end

  def turn_time
    rand(300..600)
  end

  def can_flee?
    !@object.health.dead?
  end
end
