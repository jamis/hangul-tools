# Hangul

A library for automatically romanizing Korean text.

Supports the two primary systems for romanizing Hangul:

* McCune-Reischauer (an older system which includes diacritics and has a stronger emphasis on representing actual pronunciation)
* Revised (the standard used by the government of South Korea; does not use diacritics but the pronunciation is less obvious)

## Usage

Given a string containing Korean text (possibly intermingled with non-Korean characters):

```ruby
require 'hangul_tools'

s = 'I told him, "안녕하십니까."'

puts HangulTools.romanize(s, :revised)
# => I told him, "annyeonghasimnikka."

puts HangulTools.romanize(s, :mccune_reischauer)
# => I told him, "annyŏnghashimnikka."
```

If you omit the system to use, it defaults to revised:

```ruby
s = 'I told him, "안녕하십니까."'

puts HangulTools.romanize(s)
# => I told him, "annyeonghasimnikka."
```

## Caveats

The results are not guaranteed to be accurate for all inputs, and are not even guaranteed to conform exactly to the Revised or McCune-Reischauer systems.

If you notice an inaccuracy, please:

1. Write a failing test that demonstrates the problem.
2. Fix the problem.
3. Submit a pull request.

Thank you!
