# frozen_string_literal: true

require "ruby-prof" if ENV["enable_profiling"]
class PlayState < GameState
  attr_accessor :update_interval

  def initialize
    @object_pool = ObjectPool.new
    @map = Map.new(@object_pool)
    @camera = Camera.new
    @names = Names.new(Utils.media_path("names.txt"))
    @cat = Cat.new(@object_pool, PlayerInput.new(@names.random, @camera))
    @camera.target = @cat
    @mini_map = MiniMap.new(@object_pool, @cat)
    @camera.x = @cat.x
    @camera.y = @cat.y

    5.times do
      Cat.new(@object_pool, AiInput.new(@names.random, @object_pool))
    end
  end

  def enter
    RubyProf.start if ENV["enable_profiling"]
  end

  def leave
    if ENV["enable_profiling"]
      result = RubyProf.stop
      printer = RubyProf::FlatPrinter.new(result)
      printer.print(STDOUT)
    end
  end

  def update
    @object_pool.objects.map(&:update)
    @object_pool.objects.reject!(&:removable?)
    @camera.update
    @mini_map.update
    update_caption
  end

  def draw
    cam_x = @camera.x
    cam_y = @camera.y
    off_x = $window.width / 2 - cam_x
    off_y = $window.height / 2 - cam_y
    viewport = @camera.viewport
    $window.translate(off_x, off_y) do
      zoom = @camera.zoom
      $window.scale(zoom, zoom, cam_x, cam_y) do
        @map.draw(viewport)
        @object_pool.objects.map { |o| o.draw(viewport) }
      end
    end
    @camera.draw_crosshair
    @mini_map.draw
  end

  def button_down(id)
    if id == Gosu::KbQ
      leave
      $window.close
    end
    if id == Gosu::KbT
      cat = Cat.new(@object_pool, AiInput.new(@object_pool))
      cat.x, cat.y = @camera.mouse_coords
    end
    if id == Gosu::KbEscape
      GameState.switch(MenuState.instance)
    end
  end

  private

  def update_caption
    now = Gosu.milliseconds
    if now - (@caption_update_at || 0) > 1000
      $window.caption = "Cats Prototype FPS: #{Gosu.fps} CAT @ #{@cat.x.round}, #{@cat.y.round}"
      @caption_update_at = now
    end
  end
end
