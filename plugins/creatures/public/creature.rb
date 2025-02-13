module AresMUSH
  class Creature < Ohm::Model
    include ObjectModel
    include FindByName

    attribute :name
    attribute :name_upcase
    index :name_upcase
    attribute :sapient, :type => DataType::Boolean, :default => false

    attribute :traits
    attribute :combat
    attribute :society
    attribute :magical_abilities
    attribute :events
    attribute :pinterest
    attribute :found
    attribute :short_desc
    attribute :banner_image
    attribute :profile_image
    attribute :speed
    attribute :height
    attribute :length
    attribute :image_gallery, :type => DataType::Array, :default => []
    before_save :save_upcase

    collection :scenes, "AresMUSH::Scene"
    set :gms, "AresMUSH::Character"
    set :plots, "AresMUSH::Plot"

    def save_upcase
      self.name_upcase = self.name ? self.name.upcase : nil
    end

    def self.find_any_by_name(name_or_id)
      return [] if !name_or_id

      if (name_or_id.start_with?("#"))
        return find_any_by_id(name_or_id)
      end

      find(name_upcase: name_or_id.upcase).to_a
    end

    def self.find_one_by_name(name_or_id)
      creature = Creature[name_or_id]
      return creature if creature

      find_any_by_name(name_or_id).first
    end

    def self.named(name)
      find_one_by_name(name)
    end

  end
end
