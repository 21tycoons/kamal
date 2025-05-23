require_relative "cli_test_case"

class CliRegistryTest < CliTestCase
  test "login" do
    run_command("login").tap do |output|
      assert_match /docker login -u \[REDACTED\] -p \[REDACTED\] as .*@localhost/, output
      assert_match /docker login -u \[REDACTED\] -p \[REDACTED\] on 1.1.1.\d/, output
    end
  end

  test "login skip local" do
    run_command("login", "-L").tap do |output|
      assert_no_match /docker login -u \[REDACTED\] -p \[REDACTED\] as .*@localhost/, output
      assert_match /docker login -u \[REDACTED\] -p \[REDACTED\] on 1.1.1.\d/, output
    end
  end

  test "login skip remote" do
    run_command("login", "-R").tap do |output|
      assert_match /docker login -u \[REDACTED\] -p \[REDACTED\] as .*@localhost/, output
      assert_no_match /docker login -u \[REDACTED\] -p \[REDACTED\] on 1.1.1.\d/, output
    end
  end

  test "logout" do
    run_command("logout").tap do |output|
      assert_match /docker logout as .*@localhost/, output
      assert_match /docker logout on 1.1.1.\d/, output
    end
  end

  test "logout skip local" do
    run_command("logout", "-L").tap do |output|
      assert_no_match /docker logout as .*@localhost/, output
      assert_match /docker logout on 1.1.1.\d/, output
    end
  end

  test "logout skip remote" do
    run_command("logout", "-R").tap do |output|
      assert_match /docker logout as .*@localhost/, output
      assert_no_match /docker logout on 1.1.1.\d/, output
    end
  end

  test "login with no docker" do
    stub_setup
    SSHKit::Backend::Abstract.any_instance.stubs(:execute)
      .with(:docker, "--version", "&&", :docker, :buildx, "version")
      .raises(SSHKit::Command::Failed.new("command not found"))

    assert_raises(Kamal::Cli::DependencyError) { run_command("login") }
  end

  test "allow remote login with no docker" do
    stub_setup
    SSHKit::Backend::Abstract.any_instance.stubs(:execute)
      .with(:docker, "--version", "&&", :docker, :buildx, "version")
      .raises(SSHKit::Command::Failed.new("command not found"))

    SSHKit::Backend::Abstract.any_instance.stubs(:execute)
      .with { |*args| args[0..1] == [ :docker, :login ] }

    assert_nothing_raised { run_command("login", "--skip-local") }
  end


  private
    def run_command(*command)
      stdouted { Kamal::Cli::Registry.start([ *command, "-c", "test/fixtures/deploy_with_accessories.yml" ]) }
    end
end
