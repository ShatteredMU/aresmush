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

        Website.add_to_recent_changes(
          'motd',
          Website.format_input_for_html(t('login.motd_announce', :enactor => enactor_name, :message => "")),
          { class_id: "motd-#{Time.now.strftime("%d-%m-%Y-%H:%M")}" },
          enactor.name,
          Website.format_input_for_html(self.notice)
        )
      end
    end
  end
end