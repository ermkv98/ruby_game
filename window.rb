# frozen_string_literal: true

require "gosu"

class GameWindow < Gosu::Window
  attr_accessor :state, :height, :width

  def initialize
    @height = 640
    @width = 640
    super(width, height, false)
  end

  def update
    Utils.track_update_interval
    @state.update
  end

  def draw
    @state.draw
  end

  def needs_redraw?
    @state.needs_redraw?
  end

  def needs_cursor?
    # Utils.update_interval > 200 # @TODO fix interval update
    false
  end

  def button_down(id)
    @state.button_down(id)
  end
end
