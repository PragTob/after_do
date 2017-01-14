## 0.5.0 (unreleased)

* Introduces AfterDo::AlternativeNaming to have all methods (`after`, `before`, `remove_all_callbacks`) prefixed with `ad_` to avoid naming conflicts for instance in ActionCable
* get all core functionality into AfterDo::Core so people can write their own interfaces with own method names

## 0.4.0 (March 25th, 2016)

* Hand new arguments to callbacks, namely method name and return value (for after). New Order of block arguments for before is: `arguments, method_name, object`, for after it is: `arguments, method_name, return_value, object`. To migrate to this version you need to change blocks that either use `*args` and then access `args` or calls that do `arg_1, arg_2, object` as the third argument is now the method name. You can change them to `arg_1, arg_2, *, object`.
* Dropped explicit rubinius support, it should work but dropped testing. If you need it please get in touch.

## 0.3.1 (March 27th, 2014)

* improve error reporting
* run warning free with -w

## 0.3.0 (January 19th, 2014)

* Work properly with inheritance (callbacks are just called if `super` is really invoked)
* Work properly with modules (callbacks on module methods are executed when the methods are called)
