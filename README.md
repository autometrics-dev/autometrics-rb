# autometrics-ruby

> WIP! This could use review and feedback from more a more experienced Ruby dev

## Quick Oerview

- Uses `"prometheus-client"` gem, the Ruby client for prometheus

- Counts calls to methods, using labels `function` and `module`
- Observes histogram of method execution time, with labels `function` and `module`

- For a simple test right now, run `bundle` and `bundle exec ruby autometrics_test_quick.rb`

**TODO**

- [ ] Provide an example of how to use this with a Rails app!

## Usage Samples

### Usage inside a class

```ruby

# Inlcude `Autometrics::On` to enable autometrics on all methods
class ClassWithAllAutometrics
  include Autometrics::On

  def foo
    p "This will be observed in prometheus!"
  end

  def bar
    p "Sooøøøoo will this!"
  end
end

# Inlcude `Autometrics` module to add ability to enable autometrics on specific methods

class ClassWithSomeAutometrics
  include Autometrics

  # Option 1: provide an allow-list of the methods to observe in prometheus
  autometrics only: :foo

  # Option 2: provide an exclusion-list of the methods we should not observe in prometheus
  autometrics skip: :bar

  def foo
    p "I'm getting observed!"
  end

  def bar
    p "I am not getting observed. :("
  end
end
```

### Usage with plain-old Ruby methods

```ruby
require "autometrics"

autometrics def top_level_foo
  p "I'm getting observed!"
end
```

## Developing Locally

To build the Gem:

```sh
gem build autometrics.gemspec
```

To use debug logs:

```sh
LOG_LEVEL=debug bundle exec ruby autometrics_test_quick.rb
```
