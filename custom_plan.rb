require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def test(argv=ARGV)
    # disable autorun in case the user left it in spec_helper.rb
    RSpec::Core::Runner.disable_autorun!
    exit RSpec::Core::Runner.run(argv.length > 0 ? argv : ['spec'])
  end
end

Zeus.plan = CustomPlan.new
