module AresMUSH
  module LookingForRp

    def self.set(char, duration, type="scene")
      end_at = LookingForRp.end_at(duration)
      char.update(looking_for_rp_expires_at: end_at)
      char.update(looking_for_rp: true)
      char.update(looking_for_rp_type: type)
    end

    def self.end_at(duration)
      Time.now + duration.hour
    end

    def self.expire(char)
      char.update(looking_for_rp: false)
    end

    def self.chars_looking_for_rp
      Chargen.approved_chars.select { |c| c.looking_for_rp == true }
    end

    def self.char_names
      chars_looking_for_rp.map { |c| c.name }
    end

  end
end