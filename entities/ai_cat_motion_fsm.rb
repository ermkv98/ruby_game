# frozen_string_literal: true

class AiCatMotionFSM
  STATE_CHANGE_DELAY = 500

  def initialize(object, vision, fireball)
    @object = object
    @vision = vision
    @fireball = fireball
    @roaming_state = AiCatRoamingState.new(object, vision)
    @fighting_state = AiCatFightingState.new(object, vision)
    @fleeing_state = AiCatFleeingState.new(object, vision, fireball)
    @chasing_state = AiCatChasingState.new(object, vision, fireball)
    set_state(@roaming_state)
  end

  def on_collision(with)
    @current_state.on_collision(with)
  end

  def on_damage(amount)
    if @current_state == @roaming_state
      set_state(@fighting_state)
    end
  end

  def update
    choose_state
    @current_state.update
  end

  def set_state(state)
    return unless state
    return if state == @current_state
    @last_state_change = Gosu.milliseconds
    @current_state = state
    state.enter
  end

  def choose_state
    return unless (Gosu.milliseconds - @last_state_change) > STATE_CHANGE_DELAY
    if @fireball.target
      if @object.health.health > 40
        if @fireball.distance_to_target > FireballPhysics::MAX_DIST
          new_state = @chasing_state
        else
          new_state = @fighting_state
        end
      else
        if @fleeing_state.can_flee?
          new_state = @fleeing_state
        else
          new_state = @fighting_state
        end
      end
    else
      new_state = @roaming_state
    end
    set_state(new_state)
  end
end
