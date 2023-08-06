# 個人情報を扱うクラス
class PersonalInformation
  def initialize(name:, birth_day:)
    @name = name
    @birth_day = birth_day
  end

  def self_introduction
    "ぼく#{@name}です。生年月日は#{@birth_day}です。"
  end
end

puts PersonalInformation.new(name: 'ドラえもん', birth_day: '2112-09-03').self_introduction
