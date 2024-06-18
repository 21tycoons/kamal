module Kamal::Cli
  module Aliases
    extend ActiveSupport::Concern

    class_methods do
      def original_commands
        @original_commands
      end

      def dispatch(meth, given_args, given_opts, config)
        if @original_commands.nil?
          @original_commands = all_commands.keys.dup
        end

        if !@aliased && self == Kamal::Cli::Main
          if (first_arg = given_args.first)
            if first_arg !~ /^-/ && !all_commands[normalize_command_name(first_arg)]
              all_commands[first_arg] = Thor::Command.new("alias", nil, nil, nil, nil)
              given_args << first_arg
            end
          end
        end

        @aliased = true

        super
      end
    end
  end
end
