require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  def setup
	  @p = people(:one)
  end
  test "requires CaseID" do
	  assert @p.valid?
	  @p.caseid = nil
	  assert !@p.valid?
  end
end
