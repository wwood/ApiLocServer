require File.dirname(__FILE__) + '/../test_helper'

class OrthomclRunTest < ActiveSupport::TestCase
  def test_version_name_to_local_data_dir
    assert_equal 'v4', OrthomclRun.version_name_to_local_data_dir(OrthomclRun::ORTHOMCL_OFFICIAL_VERSION_4_NAME)
    assert_raise Exception do
      OrthomclRun.version_name_to_local_data_dir('not a run')
    end
  end
end
