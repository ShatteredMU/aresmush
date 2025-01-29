module AresMUSH
  module Website
    def self.add_to_recent_changes(type, message, data, author_name)
      changes = Game.master.recent_changes || []
      change_data = { 'type' => type,
        'data' => data,
        'message' => message,
        'author' => author_name,
        'timestamp' => Time.now
      }
      changes.unshift(change_data)
      if (changes.count > 99)
        changes.pop
      end
      activity_types = ["plot", "wiki", "creature"]
      if activity_types.include?(type)
        Website.add_to_recent_activity(type, message, data, author_name)
      end
      Game.master.update(recent_changes: changes)
    end

    def self.recent_changes(viewer, unique_only = false, limit = 50)
      all_changes = Game.master.recent_changes || []
      changes = []

      if (unique_only)
        found = []
        all_changes.each do |c|
          key = "#{c['message']}#{c['type']}"
          if (!found.include?(key))
            found << key
            changes << c
          end
        end
      else
        changes = all_changes
      end

      changes[0..limit].map { |c| {
        type: c['type'],
        message: c['message'],
        summary: c['summary'],
        data: c['data'],
        timestamp: OOCTime.local_long_timestr(viewer, c['timestamp']),
        author: c['author']
      } }
    end

    def self.add_to_recent_activity(type, message, data, author_name, summary = nil)
      activities = Game.master.recent_activity || []
      activity_data = { 'type' => type,
        'data' => data,
        'message' => message,
        'author' => author_name,
        'timestamp' => Time.now,
        'summary' => summary
      }
      activities.unshift(activity_data)
      if (activities.count > 99)
        activities.pop
      end
      Game.master.update(recent_activity: activities)
    end

    def self.recent_activity(viewer, unique_only = false, limit = 50)
      all_changes = Game.master.recent_activity || []
      changes = []

      if (unique_only)
        found = []
        all_changes.each do |c|
          key = "#{c['message']}#{c['type']}"
          if (!found.include?(key))
            found << key
            changes << c
          end
        end
      else
        changes = all_changes
      end

      changes[0..limit].map { |c| {
        type: c['type'],
        message: c['message'],
        summary: c['summary'],
        data: c['data'],
        timestamp: OOCTime.local_long_timestr(viewer, c['timestamp']),
        author: c['author']
      } }
    end

    def self.build_sitemap
      list = []
      list << { 'url' => Game.web_portal_url, 'lastmod' => Time.now }
      Scene.shared_scenes.each { |s| list << { 'url' => "#{Game.web_portal_url}/scene/#{s.id}", 'lastmod' => s.updated_at } }
      Character.all.each { |c| list << { 'url' => "#{Game.web_portal_url}/char/#{c.name}", 'lastmod' => c.profile_last_edited } }
      WikiPage.all.each { |w| list << { 'url' => "#{Game.web_portal_url}/wiki/#{w.name}", 'lastmod' => w.last_edited } }
      Plot.all.each { |p| list << { 'url' => "#{Game.web_portal_url}/plot/#{p.id}", 'lastmod' => p.updated_at } }
      Area.all.each { |r| list << { 'url' => "#{Game.web_portal_url}/location/#{r.id}", 'lastmod' => r.updated_at } }

      list << { 'url' => "#{Game.web_portal_url}/admins", 'lastmod' => Time.now }
      list << { 'url' => "#{Game.web_portal_url}/roster", 'lastmod' => Time.now }
      list << { 'url' => "#{Game.web_portal_url}/groups", 'lastmod' => Time.now }
      list << { 'url' => "#{Game.web_portal_url}/achievements", 'lastmod' => Time.now }
      list << { 'url' => "#{Game.web_portal_url}/census", 'lastmod' => Time.now }
      list << { 'url' => "#{Game.web_portal_url}/fs3combat/gear", 'lastmod' => Time.now }
      list << { 'url' => "#{Game.web_portal_url}/fs3skills/abilities", 'lastmod' => Time.now }

      list <<{ 'url' =>  "#{Game.web_portal_url}/help", 'lastmod' => Time.now }
      topics = Help.topic_keys.map { |k, v| v }.uniq
      topics.each { |h| list << { 'url' => "#{Game.web_portal_url}/help/#{h}", 'lastmod' => Time.now } }

      BbsPost.all.select{ |b| b.is_public? }
         .each { |b| list << { 'url' => "#{Game.web_portal_url}/forum/#{b.bbs_board.id}/#{b.id}", 'lastmod' => Time.now } }

      list
    end

  end
end
