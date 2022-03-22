# frozen_string_literal: true

class FireballSounds
  class << self
    def play
      # sound.play
    end

    private

    def sound
      @@sound ||= Gosu::Sample.new($window, Utils.media_path("fire.mp3"))
    end
  end
end
