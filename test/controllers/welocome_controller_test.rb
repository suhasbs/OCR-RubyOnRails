require 'test_helper'

class WelocomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get welocome_index_url
    assert_response :success
  end

end
