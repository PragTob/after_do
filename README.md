# AfterDo [![Gem Version](https://badge.fury.io/rb/after_do.png)](http://badge.fury.io/rb/after_do)[![Build Status](https://travis-ci.org/PragTob/after_do.png?branch=master)](https://travis-ci.org/PragTob/after_do)[![Code Climate](https://codeclimate.com/github/PragTob/after_do.png)](https://codeclimate.com/github/PragTob/after_do)[![Coverage Status](https://coveralls.io/repos/PragTob/after_do/badge.png)](https://coveralls.io/r/PragTob/after_do)

AfterDo is simple gem, that allows you to execute a specified block after specified method of a class are called. If the class extends `AfterDo` you can simply do this by `MyClass.after :some_method do puts 'whatever you want?' end`

This shall not be done to alter behavior but rather to fight cross-cutting concerns such as logging. E.g. with logging you litter all your code wit logging statements - that concern is spread over many files. With AfterDo you could put all the logging in one file.

AfterDo has no external runtime dependencies and the code is not even 120 lines of code (blank lines included) with lots of small methods. So simplecov reports there are not even 70 relevant lines.

## Installation

Add this line to your application's Gemfile:

    gem 'after_do'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install after_do

## Usage

With AfterDo you can do simple things like putting something out every time a method is called as in this example:

```ruby
class Dog
  def bark
    puts 'Woooof'
  end
end

Dog.extend AfterDo
Dog.after :bark do puts 'I just heard a dog bark!' end

dog = Dog.new
dog2 = Dog.new

dog.bark
dog2.bark

# Output is:
# Woooof
# I just heard a dog bark!
# Woooof
# I just heard a dog bark!

```

As another example: If you have an activity and want the activity to be saved every time you change it, but you don't want to mix that persistence concern with what the activity actually does you could do something like this:

```ruby
persistor  = FilePersistor.new
Activity.extend AfterDo
Activity.after :start, :pause, :finish, :resurrect,
             :do_today, :do_another_day do |activity|
  persistor.save activity
end
```

Doesn't that seem a lot drier then calling some save method manually after each of those in addition to separating the concerns?

## Is there a before method?

Yes. It works just like the `after` method, but the callbacks are executed before the original method is called. You can also mix and match before and after calls.

Before for me is a far less common use case, that's why it was only added later (in the 0.2 release).

## Is this a good idea?

Always depends on what you are doing with it. As many things out there it has its use cases but can easily be misused.

### Advantages

- Get cross cutting concerns packed together in one file - don't have them scattered all over your code base obfuscating what the real responsibility of that class is
- Don't repeat yourself, define what is happening when in one file
- I feel like it helps the Single Responsibility principle, as it enables classes to focus on what their main responsibility is and not deal with other stuff. I initially wrote this gem when I wanted to decouple an object of my domain from the way it is saved.

### Drawbacks

- You lose clarity. With this gem it is not immediately visible what happens when a method is called as some behavior might be defined elsewhere.
- You could use this to modify the behaviour of classes everywhere. Don't. Use it for what it is meant to be used for - a concern that is not the primary concern of the class you are adding the callback to but that class is still involved with.

## Does it work with Ruby interpreter X?

Thanks to the awesome [travis CI](https://travis-ci.org/) the specs are run with MRI 1.9.3, 2.0, the latest jruby and rubinius releases in 1.9 mode. So in short, this should work with all of them and is aimed at doing so :-)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
