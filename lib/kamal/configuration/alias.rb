class Kamal::Configuration::Alias
  include Kamal::Configuration::Validation

  delegate :argumentize, :optionize, to: Kamal::Utils

  attr_reader :name, :command, :options, :arguments, :invocation

  def initialize(name, config:)
    @name, @config, @command = name.inquiry, config, config.raw_config["aliases"][name]

    validate! \
      command,
      example: validation_yml["aliases"]["uname"],
      context: "aliases/#{name}",
      with: Kamal::Configuration::Validator::Alias

    parse_command!
  end

  private
    def parse_command!
      command_parts = Shellwords.split(command)
      first_part = command_parts.shift

      if (cli = "Kamal::Cli::#{first_part.capitalize}".safe_constantize)
        command_name, cli_name = command_parts.shift, first_part
      else
        cli = Kamal::Cli::Main
        command_name, cli_name = first_part, "main"
      end

      args, array_options = Thor::Options.split(command_parts)
      cli_options = cli.class_options.merge(cli.all_commands[command_name].options)
      thor_options = Thor::Options.new(cli_options, {}, true, false, { exclusive_option_names: [], at_least_one_option_names: [] })

      @options = thor_options.parse(array_options).dup
      @arguments = Thor::Arguments.new(cli.arguments) \
        .tap { |thor_args| thor_args.parse(args + thor_options.remaining) } \
        .remaining
      @invocation = "#{cli_name}:#{command_name}"
    end
end
