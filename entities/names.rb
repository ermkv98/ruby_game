# frozen_string_literal: true

class Names
  def initialize(file)
    @names = File.read(file).split("\n")
  end

  def random
    name = @names.sample
    @names.delete(name)
    name
  end
end
