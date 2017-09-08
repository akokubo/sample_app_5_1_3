require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  def setup
    #self.default_url_options = { locale: I18n.default_locale }
  end

  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
  end

  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
