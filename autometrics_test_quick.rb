require_relative 'autometrics'

# A class that has autometrics off by default
class ClassWithNoAutometrics
  include Autometrics

  # Uncomment this line to turn on autometrics for this class
  # autometrics

  def instance_method_of_class
    p "[instance_method_of_class] You should see no [autometrics] around this function call"
  end

  def another_instance_method_of_class
    p "[another_instance_method_of_class] You should see no [autometrics] around this function call"
  end
end

class_with_none = ClassWithNoAutometrics.new
class_with_none.instance_method_of_class
class_with_none.another_instance_method_of_class

class ClassWithSomeAutometrics
  include Autometrics::On

  autometrics only: :foo

  def foo
    p "`foo` here! You should see some [autometrics::foo] logs around me"
  end

  def bar
    p "`bar` here! You shouldn't see any [autometrics::bar] logs by me"
  end
end


class_with_some = ClassWithSomeAutometrics.new
class_with_some.foo
class_with_some.bar