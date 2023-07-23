# frozen_string_literal: true

# 個人情報を扱うクラス
class PersonalInformation
  def initialize(name:, age:, birth_day:)
    @name = name
    @age = age
    @birth_day = birth_day
  end

  def print_self_introduction
    self_introduction = "#{@name}です。#{@age}歳です。誕生日は#{@birth_day}です。"

    puts self_introduction
  end
end

info = PersonalInformation.new(name: 'yuya', age: 29, birth_day: '1994-04-11')
info.print_introduction
