module AresMUSH
  module Login
    class MotdSetCmd
      include CommandHandler

      attr_accessor :notice

      def parse_args
        self.notice = cmd.args
      end

      def check_can_set
        return t('dispatcher.not_allowed')  if !Login.can_manage_login?(enactor)
        return nil
      end

      def handle
        Game.master.update(login_motd: self.notice)
        client.emit_success t('login.motd_set')
        if (!self.notice.blank?)
          Manage.announce t('login.motd_announce', :enactor => enactor_name, :message => self.notice)
        end

        id = Time.now.strftime("%d-%m-%Y-%H-%M")
        recent_activity = Game.master.recent_activity.delete_if {|change| change['type'] == "motd" && change['data']['class_id'] == id}
        Game.master.update(recent_activity: recent_activity)
        Website.add_to_recent_activity(
          'motd',
          Website.format_markdown_for_html(t('login.motd_announce', :enactor => enactor_name, :message => "")),
          { class_id: id, icon: 'fa-scroll' },
          enactor.name,
          Website.format_markdown_for_html(self.notice)
        )
      end
    end
  end
end