require 'minitest/autorun'
require_relative '../lib/rbs_type_check_invalid_smple'

# 個人情報を扱うテスト
class TestPersonalInformation < Minitest::Test
  def self_introduction_string
    info = PersonalInformation.new(name: 'ドラえもん', birth_day: '2112-09-03')
    expected_introduction = "ぼくドラえもんです。生年月日は2112-09-03です。"
    assert_equal expected_introduction, info.self_introduction
  end

  def test_self_introduction
    info = PersonalInformation.new(name: 1234, birth_day: 1234)
    expected_introduction = "ぼく1234です。生年月日は1234です。"
    assert_equal expected_introduction, info.self_introduction
  end
end
