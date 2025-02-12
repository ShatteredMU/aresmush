module AresMUSH
  module Magic

    def self.spell_data_from_set(list)
      list.to_a.sort_by { |a| a.level }.map { |a|
        {
          name: a.name,
          level: a.level,
          school: a.school,
          learned: a.learning_complete,
          desc: Website.format_markdown_for_html(Global.read_config("spells", a.name, "desc")),
          potion: Global.read_config("spells", a.name, "potion"),
          weapon: Global.read_config("spells", a.name, "weapon"),
          weapon_specials:  Global.read_config("spells", a.name, "weapon_special"),
          armor: Global.read_config("spells", a.name, "armor"),
          armor_specials: Global.read_config("spells", a.name, "armor_specials"),
          attack_mod: Global.read_config("spells", a.name, "attack_mod"),
          init_mod: Global.read_config("spells", a.name, "init_mod"),
          lethal_mod: Global.read_config("spells", a.name, "lethal_mod"),
          spell_mod:  Global.read_config("spells", a.name, "spell_mod"),
          defense_mod:  Global.read_config("spells", a.name, "defense_mod"),
          duration: Global.read_config("spells", a.name, "duration"),
          casting_time: Global.read_config("spells", a.name, "casting_time"),
          range: Global.read_config("spells", a.name, "range"),
          area: Global.read_config("spells", a.name, "area"),
          targets: Global.read_config("spells", a.name, "targets"),
          heal: Global.read_config("spells", a.name, "heal_points"),
          effect: Global.read_config("spells", a.name, "effect"),
          damage_type:  Global.read_config("spells", a.name, "damage_type"),
          available: Global.read_config("spells", a.name, "available"),
          los:  Global.read_config("spells", a.name, "line_of_sight")
          }}
    end

    def self.spell_data_from_array_or_hash(list)
      # Typically used with a list of spells drawn from config (ie, all spells in a school, all spells overall, all spells in search result)
      list.sort.map { |name, data| {
        key: name,
        name: name,
        desc: Website.format_markdown_for_html(data['desc']),
        available: data['available'],
        level: data['level'],
        school: data['school'],
        potion: data['is_potion'],
        duration: data['duration'],
        casting_time: data['casting_time'],
        range: data['range'],
        area: data['area'],
        los: data['line_of_sight'],
        targets: data['target_num'],
        heal: data['heal_points'],
        defense_mod: data['defense_mod'],
        init_mod: data['init_mod'],
        attack_mod: data['attack_mod'],
        lethal_mod: data['lethal_mod'],
        spell_mod: data['spell_mod'],
        weapon: data['weapon'],
        armor: data['armor'],
        armor_specials: data['armor_specials'],
        weapon_specials: data['weapon_specials'],
        effect: data['effect'],
        damage_type: data['damage_type'],
        shields_against: data['shields_against']
        }
      }
    end

    def self.spell_xp(spell)
      if spell[:level] == 8
        xp = 12
      elsif spell[:level] == 7
        xp = 8
      elsif spell[:level] == 6
        xp = 7
      elsif spell[:level] == 5
        xp = 6
      elsif spell[:level] == 4
        xp = 5
      elsif spell[:level] == 3
        xp = 4
      elsif spell[:level] == 2
        xp = 3
      elsif spell[:level] == 1
        xp = 2
      end
      return xp
    end

    def self.spell_list_all_data(list)
      if list.is_a?(Array) || list.is_a?(Hash)
        spells = Magic.spell_data_from_array_or_hash(list)
      else
        spells = Magic.spell_data_from_set(list)
      end
      spells.each do |s|
        # weapon = Global.read_config("spells", s[:name], "weapon")
        # weapon_specials = Global.read_config("spells", s[:name], "weapon_specials")
        # armor = Global.read_config("spells", s[:name], "armor")
        # armor_specials = Global.read_config("spells", s, "armor_specials")
        # attack = Global.read_config("spells", s[:name], "attack_mod")
        # lethal = Global.read_config("spells", s[:name], "lethal_mod")
        # spell = Global.read_config("spells", s[:name], "spell_mod")
        # defense = Global.read_config("spells", s[:name], "defense_mod")
        s[:xp] = Magic.spell_xp(s)
        if s[:level] == 8
          s[:level_8] = true
        end
        if s[:range] == "Massive"
          s[:range_desc] = "(2 miles)"
        elsif s[:range] == "Short"
          s[:range_desc] = "(10 yards)"
        elsif s[:range] == "Long"
          s[:range_desc] = "(100 yards)"
        end
        s[:weapon_or_specials] = true if s[:weapon] || s[:weapon_specials]
        weapon = s[:weapon]
        s[:weapon_lethality] = FS3Combat.weapon_stat(weapon, "lethality")
        s[:weapon_penetration] = FS3Combat.weapon_stat(weapon, "penetration")
        s[:weapon_type] = FS3Combat.weapon_stat(weapon, "weapon_type")
        s[:weapon_accuracy] = FS3Combat.weapon_stat(weapon, "accuracy")
        s[:weapon_shrapnel] = FS3Combat.weapon_stat(weapon, "has_shrapnel")
        s[:weapon_init] = FS3Combat.weapon_stat(weapon, "init_mod")
        s[:weapon_damage_type] = FS3Combat.weapon_stat(weapon, "damage_type")
        if s[:weapon_specials]
          weapon_special = s[:weapon_specials]
          s[:weapon_special_lethality] = FS3Combat.weapon_specials[weapon_special]["lethality"]
          s[:weapon_special_penetration] = FS3Combat.weapon_specials[weapon_special]["penetration"]
          s[:weapon_special_init] = FS3Combat.weapon_specials[weapon_special]["init_mod"]
          s[:weapon_special_accuracy] = FS3Combat.weapon_specials[weapon_special]["accuracy"]
        end

        if (s[:attack_mod] || s[:defense_mod] || s[:lethal_mod] || s[:spell_mod] || s[:init_mod])
          s[:mod] = true
        end
        s[:armor_or_specials] = true if s[:armor] || s[:armor_specials]
        if s[:armor_specials]
          armor_special = s[:armor_specials]
          s[:armor_special_protection] = FS3Combat.armor_specials[armor_special]["protection"].values.first
          s[:armor_special_defense] = FS3Combat.armor_specials[armor_special]["defense"]
        end
        protection = FS3Combat.armor_stat(s[:armor], "protection")
        if protection
          protection = protection["Chest"]
        end
        s[:armor_protection] = protection
        s[:armor_defense] = FS3Combat.armor_stat(s[:armor], "defense")
        if s[:targets] == nil

        elsif s[:targets] == 1
          s[:single_target] = true
        elsif s[:targets] > 1
          s[:multi_target] = true
        end
      end
    end

    def self.major_school_spells(char, spell_list)
      major_school = char.major_schools.first
      major_spells = []
      spell_list.each do |s|
        if (s[:school] == major_school)
          major_spells.concat [s]
        end
      end
      return major_spells
    end

    def self.minor_school_spells(char, spell_list)
      minor_school = char.minor_schools.first
      if minor_school != "None"
        minor_spells = []
        spell_list.each do |s|
          if (s[:school] == minor_school)
            minor_spells.concat [s]
          end
        end
      else
        minor_spells = nil
      end
      return minor_spells
    end

    def self.other_spells(char, spell_list)
      minor_school = char.minor_schools.first
      major_school = char.major_schools.first
      other_spells = []
      spell_list.each do |s|
        if (s[:school] != minor_school && s[:school] != major_school)
          other_spells.concat [s]
        end
      end
      return other_spells
    end

  end
end
