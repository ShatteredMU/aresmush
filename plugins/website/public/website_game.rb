module AresMUSH
  class Game
    attribute :recent_changes, :type => DataType::Array, :default => []
    attribute :recent_activity, :type => DataType::Array, :default => []
  end
end