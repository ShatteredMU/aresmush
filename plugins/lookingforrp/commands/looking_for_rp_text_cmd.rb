module AresMUSH
  module LookingForRp
    class LookingForRpTextCommand
      include CommandHandler

      attr_accessor :duration

      def parse_args
        self.duration = case cmd.args
            when 'off'
              nil
            when nil
              1
            else
              cmd.args.to_i
            end
      end

      def check_errors
        return "Incorrect syntax. See 'qr lookingforrp' for help." if self.duration && !self.duration.integer?
        return "You can't set yourself 'Looking for RP' for longer than 3 hours." if duration.to_i > 3
      end

      def handle
        if self.duration.nil?
          LookingForRp.expire(enactor)
          client.emit_success t('lookingforrp.expire')
        else
          LookingForRp.set(enactor, self.duration.to_i, "text")
          client.emit_success t('lookingforrp.set_txt', :duration => self.duration)
        end
      end
    end
  end
end
