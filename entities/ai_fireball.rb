# frozen_string_literal: true

class AiFireball < Component
  DECISION_DELAY = 1_000
  attr_reader :target, :desired_shoot_angle

  def initialize(object, vision)
    @object = object
    @vision = vision
    @desired_shoot_angle = rand(0..360)
    @retarget_speed = rand(1..5)
    @accuracy = rand(0..10)
    @agressivness = rand(1..5)
  end

  def adjust_angle
    adjust_desired_angle
    adjust_shoot_angle
  end

  def update
    if @vision.in_sight.any?
      if @vision.closest_tank != @target
        change_target(@vision.closest_tank)
      end
    else
      @target = nil
    end

    if @target
      if (0..10 - rand(0..@accuracy)).include?((@desired_shoot_angle - @object.shoot_angle).abs.round)
        distance = distance_to_target
        if distance - 50 <= FireballPhysics::MAX_DIST
          target_x, target_y = Utils.point_at_distance(@object.x, @object.y, @object.shoot_angle, distance + 10 - rand(0..@accuracy))
          # if can_make_new_decision? && @object.can_shoot? && @object.should_shoot?
          if can_make_new_decision? && should_shoot?
            @object.shoot(target_x, target_y)
          end
        end
      end
    end
  end

  def distance_to_target
    Utils.distance_between(@object.x, @object.y, @target.x, @target.y)
  end

  def should_shoot?
    rand * @agressivness > 0.5
  end

  def can_make_new_decision?
    now = Gosu.milliseconds

    if now - (@last_decision ||= 0) > DECISION_DELAY
      @last_decision = now
      true
    end
  end

  def adjust_desired_angle
    @desired_shoot_angle = if @target
      Utils.distance_between(@object.x, @object.y, @target.x, @target.y)
    else
      @object.direction
    end
  end

  def change_target(new_target)
    @target = new_target
    adjust_desired_angle
  end

  def adjust_shoot_angle
    actual = @object.shoot_angle
    desired = @desired_shoot_angle
    if actual > desired
      if actual - desired > 100 # 0 -> 360 fix
        @object.shoot_angle = (actual + @retarget_speed) % 360
        if @object.shoot_angle < desired
          @object.shoot_angle = desired # damp
        end
      else
        @object.shoot_angle = [actual - @retarget_speed, desired].max
      end
    elsif
      if desired - actual > 100 # 360 -> 0 fix
        @object.shoot_angle = (360 + actual - @retarget_speed) % 360
        if @object.shoot_angle > desired
          @object.shoot_angle = desired # damp
        end
      else
        @object.shoot_angle = [actual + @retarget_speed, desired].min
      end
    end
  end
end
