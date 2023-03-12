# autometrics-ruby

> :warning: **Autometrics for Ruby is under active development.** We are seeking feedback from the community on the API and implementation. Please open an issue if you have any questions or feedback!

A Ruby module that makes it easy to understand the error rate, response time, and production usage of any function in your code.

Once complete, you should only have to add a one or two lines of code, and then be able to jump straight from your IDE to live Prometheus charts for each of your HTTP/RPC handlers, database methods, or any other piece of application logic.

## Features

- ✨ `include Autometrics` exposes utilities that can instrument any function or class method to track useful metrics for your application
- ⚡ Minimal runtime overhead

**Coming Soon**

- 💡 Writes Prometheus queries so you can understand the data generated without
  knowing PromQL
- 🔗 Create links to live Prometheus charts directly into each functions docstrings via SolarGraph

- 📊 Grafana dashboard showing the performance of all
  instrumented functions

## Usage

Autometrics makes use of `"prometheus-client"` under the hood, which is the aptly named Ruby client for Prometheus.

For now, you simply need to add the autometrics gem to your project, `include Autometrics` in any class you wish to observer, and then set up a `/metrics` endpoint in your app that exposes the metrics to Prometheus, if one does not already exist.

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

## TODOs

- [ ] Provide an example of how to use Autometrics with a Rails app
- [ ] Look for other methods to exclude by default, like `initialize`. (E.g., should we exclude private methods?)
- [ ] Add tests
- [ ] Investigate ability to swap out the prometheus client, e.g., using the [`prometheus_exporter` gem](https://github.com/discourse/prometheus_exporter)

## Developing Locally

For a simple test right now, run `bundle` and `bundle exec ruby autometrics_test_quick.rb`.

To build the Gem:

```sh
gem build autometrics.gemspec
```

To use debug logs:

```sh
LOG_LEVEL=debug bundle exec ruby autometrics_test_quick.rb
```
