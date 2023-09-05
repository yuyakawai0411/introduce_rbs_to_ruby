module Sample
  def put_name
    puts "name"
  end
end

module Sample2
  include Sample
  def put_age
    puts "age"
  end
end

class Introduction
  include Sample2
end

introduction = Introduction.new
introduction.put_name
introduction.put_age
