require "spec_helper"
require "tmpdir"

describe "jetpack - basics" do
  before(:all) do
    reset
    @project = 'spec/sample_projects/no_dependencies'
    @result = x!("bin/jetpack #{@project}")
  end

  after(:all) do
    reset
  end

  it "will put the jruby jar under vendor" do
    @result[:stderr].should == ""
    @result[:exitstatus].should == 0
    File.exists?("#{@project}/vendor/jruby.jar").should be_true
  end

  describe "creates a ruby script that" do
    it "allows you to execute using the jruby jar" do
      rake_result = x("#{@project}/bin/ruby --version")
      rake_result[:stderr].should     == ""
      rake_result[:stdout].should include("jruby")
      rake_result[:exitstatus].should == 0
    end

    it 'does not spawn a new PID' do
      # This makes writing daemon wrappers around bin/ruby much easier.
      Dir.mktmpdir do |dir|
        tmpfile = File.join(dir, 'test_pid')
        # Use exec so that we replace the "shell" process that Travis creates
        pid = Process.spawn("exec #{@project}/bin/ruby -e 'puts Process.pid'", STDOUT=>tmpfile)
        Process.wait(pid)
        pid.should == File.read(tmpfile).chomp.to_i
      end
    end
  end
end
