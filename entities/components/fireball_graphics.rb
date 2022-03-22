# frozen_string_literal: true

class FireballGraphics < Component
  DEBUG_COLORS = [
    Gosu::Color::RED,
    Gosu::Color::BLUE,
    Gosu::Color::YELLOW,
    Gosu::Color::WHITE,
  ]
  COLOR = Gosu::Color::BLACK

  def draw(viewport)
    $window.draw_quad(x - 2, y - 2, COLOR,
                      x + 2, y - 2, COLOR,
                      x - 2, y + 2, COLOR,
                      x + 2, y + 2, COLOR,
                      1)
    draw_bounding_box
  end

  def draw_bounding_box
    i = 0
    object.physics.box.each_slice(2) do |x, y|
      color = DEBUG_COLORS[i]
      $window.draw_triangle(
        x - 3, y - 3, color,
        x, y, color,
        x + 3, y - 3, color,
        100
      )
      i = (i + 1) % 4
    end
  end
end
