require_relative 'lib/autometrics'

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

module AutometricsTest
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
end

class_with_some = AutometricsTest::ClassWithSomeAutometrics.new
class_with_some.foo
class_with_some.bar


autometrics def bare_function
  puts "[bare_function] You should see [self.autometrics] around this function call"
end

bare_function

puts "*****"
puts "Now let's check the metrics we've collected"
puts Autometrics::PROMETHEUS.test_get_values