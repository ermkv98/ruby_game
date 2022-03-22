# frozen_string_literal: true

require "gosu"

root_dir = File.dirname(__FILE__)
require_pattern = File.join(root_dir, "**/*.rb")
@failed = []

Dir.glob(require_pattern).each do |f|
  next if f.end_with?("/main.rb")
  begin
    require_relative f.gsub("#{root_dir}/", "")
  rescue
    @failed << f
  end
end

@failed.each do |f|
  require_relative f.gsub("#{root_dir}/", "")
end

$window = GameWindow.new
GameState.switch(MenuState.instance)
$window.show
