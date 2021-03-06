# frozen_string_literal: true

class CatSounds < Component
  def update
    if object.physics.moving?
      if @driving && @driving.paused?
        @driving.resume
      elsif @driving.nil?
        # @driving = driving_sound.play(1, 1, true)
      end
    else
      if @driving && @driving.playing?
        @driving.pause
      end
    end
  end

  def collide
    # crash_sound.play(1, 0.25, false)
  end

  private

  def driving_sound
    @@driving_sound ||= Gosu::Sample.new(
      $window, Utils.media_path("cat_flying.mp3")
    )
  end

  def crash_sound
    @@crash_sound ||= Gosu::Sample.new(
      $window, Utils.media_path("explosion.mp3")
    )
  end
end
