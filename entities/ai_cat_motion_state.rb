# frozen_string_literal: true

class AiCatMotionState
  def initialize(object, vision)
    @object = object
    @vision = vision
  end

  def enter
    # overrride if neccessary
  end

  def change_direction
    # override
  end

  def wait_time
    # override
  end

  def drive_time
    # override
  end

  def turn_time
    # override
  end

  def update
    # override
  end

  def wait
    @sub_state = :waiting
    @started_waiting = Gosu.milliseconds
    @will_wait_for = wait_time
    @object.throttle_down = false
  end

  def drive
    @sub_state = :driving
    @started_driving = Gosu.milliseconds
    @will_drive_for = drive_time
    @object.throttle_down = true
  end

  def should_change_direction?
    return true unless @changed_direction_at
    Gosu.milliseconds - @changed_direction_at > @will_keep_direction_for
  end

  def substate_expired?
    now = Gosu.milliseconds
    case @sub_state
    when :waiting
      true if now - @started_waiting > @will_wait_for
    when :driving
      true if now - @started_driving > @will_drive_for
    else
      true
    end
  end

  def on_collision(with)
    change = case rand(0..100)
    when 0..30
      -90
    when 30..60
      90
    when 60..70
      135
    when 80..90
      -135
    else
      180
    end
    @object.physics.change_direction(@object.direction + change)
  end
end
