# 個人情報を扱うクラス
class PersonalInformation
  def initialize
    @name = "山田太郎"
    @birth_day = "1990/01/01"
  end

  def self_introduction
    "私の名前は#{@name}です。生年月日は#{@birth_day}です。"
  end
end

puts PersonalInformation.new.self_introduction
