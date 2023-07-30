require 'minitest/autorun'
require_relative '../lib/rbs_type_check_invalid_smple'

# 個人情報を扱うテスト
class TestPersonalInformation < Minitest::Test
  def test_self_introduction
    info = PersonalInformation.new
    expected_introduction = "私の名前は山田太郎です。生年月日は1990/01/01です。"
    assert_equal expected_introduction, info.self_introduction
  end
end
