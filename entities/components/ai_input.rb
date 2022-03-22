# frozen_string_literal: true

class AiInput < Component
  NAME_COLOR = Gosu::Color.argb(0xeeb10000)
  UPDATE_RATE = 200 # ms

  def initialize(name, object_pool)
    @name = name
    @object_pool = object_pool
    super(nil)
    @last_update = Gosu.milliseconds
  end

  def control(obj)
    self.object = obj
    @vision = AiVision.new(obj, @object_pool, rand(700..1_200))
    @fireball = AiFireball.new(obj, @vision)
    @motion = AiCatMotionFSM.new(obj, @vision, @fireball)
  end

  def draw(viewport)
    @name_image ||= Gosu::Image.from_text($window, @name, Gosu.default_font_name, 20)
    @name_image.draw(
      x - @name_image.width / 2 - 1,
      y + 36,
      100, 1, 1, Gosu::Color::WHITE
    )
    @name_image.draw(
      x - @name_image.width / 2,
      y + 36,
      100, 1, 1, NAME_COLOR
    )
  end

  def on_collision(with)
    @motion.on_collision(with)
  end

  def on_damage(amount)
    @motion.on_damage(amount)
  end

  def update
    return if object.health.dead?
    @fireball.adjust_angle
    now = Gosu.milliseconds
    return if now - @last_update < UPDATE_RATE
    @last_update = now
    @vision.update
    @fireball.update
    @motion.update
  end
end
