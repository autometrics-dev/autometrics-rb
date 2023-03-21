# autometrics-ruby

> :warning: **Autometrics for Ruby is under active development.** We are seeking feedback from the community on the API and implementation. Please open an issue if you have any questions or feedback!

A Ruby gem that makes it easy to understand the error rate, response time, and production usage of any function in your code.

Once we complete all our `TODOs`, you should only have to add a one or two lines of code, and then be able to jump straight from your IDE to live Prometheus charts for each of your HTTP/RPC handlers, database methods, or any other piece of application logic.

## Features

- ✨ `include Autometrics` exposes utilities that can instrument class methods, in order to track useful metrics for your application
- ⚡ Minimal runtime overhead

**Coming Soon**

- 💡 Writes Prometheus queries so you can understand the data generated without knowing PromQL
- 🔗 Create links to live Prometheus charts directly into each function's docstrings, via SolarGraph

- 📊 Grafana dashboard showing the performance of all instrumented functions

## Usage

Autometrics makes use of `"prometheus-client"` under the hood, which is the aptly named Ruby client for Prometheus.

For now, you simply need to add the autometrics gem to your project (`gem install autometrics`), `include Autometrics` in any class you wish to observe, and then set up a `/metrics` endpoint in your app that exposes the metrics to Prometheus, if one does not already exist. There is an example Sinatra app in this repo to show how you might do this.

### Usage inside a class

```ruby
# Include the `Autometrics` module, then call `autometrics` to enable autometrics on specific methods

class ClassWithSomeAutometrics
  include Autometrics

  # Option 1: Specify an allow-list of the methods to observe
  autometrics only: :foo

  # Option 2: Provide an exclusion-list of the methods we should not observe
  autometrics skip: :bar

  def foo
    p "I'm getting observed!"
  end

  def bar
    p "I am not getting observed. :("
  end
end

# Include `Autometrics::On` to enable autometrics on all methods (`initialize` is excluded by default)
class ClassWithAllAutometrics
  include Autometrics::On

  def foo
    p "This will be observed in prometheus!"
  end

  def bar
    p "Sooøøøoo will this!"
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

## TODOs

- [ ] Provide an example of how to use Autometrics with a Rails app
- [ ] Look for other methods to exclude by default, like `initialize`. (E.g., should we exclude private methods?)
- [ ] Add tests
- [ ] Investigate ability to swap out the prometheus client, e.g., using the [`prometheus_exporter` gem](https://github.com/discourse/prometheus_exporter)

## Developing Locally

To build the Gem:

```sh
gem build autometrics.gemspec
```

For a simple smoke test, run `bundle` and `bundle exec ruby autometrics_test_quick.rb`.

To use debug logs:

```sh
LOG_LEVEL=debug bundle exec ruby autometrics_test_quick.rb
```
