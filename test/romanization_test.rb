require 'hangul_tools'
require 'test/unit'

class RomanizationTest < Test::Unit::TestCase
  def test_decompose_with_vowels
    hangul = %w( 아 애 야 얘 어 에 여 예 오 와 왜 외 요 우 워 웨 위 유 으 의 이 )
    hangul.each.with_index do |given, idx|
      assert_equal [[ 12, idx + 1, 0 ]], HangulTools.decompose(given)
    end
  end

  def test_decompose_with_lead_consonants
    hangul = %w( 가 까 나 다 따 라 마 바 빠 사 싸 아 자 짜 차 카 타 파 하 )
    hangul.each.with_index do |given, idx|
      assert_equal [[ idx + 1, 1, 0 ]], HangulTools.decompose(given)
    end
  end

  def test_decompose_with_tail_consonants
    hangul = %w( 악 앆 앇 안 앉 않 앋 알 앍 앎 앏 앐 앑 앒 앓 암 압 앖 앗 았 앙 앚 앛 앜 앝 앞 앟 )
    hangul.each.with_index do |given, idx|
      assert_equal [[ 12, 1, idx + 1 ]], HangulTools.decompose(given)
    end
  end

  def test_revised_romanization_of_vowels
    hangul = %w( 아 애 야 얘 어 에 여 예 오 와 왜 외 요 우 워 웨 위 유 으 의 이 )
    latin  = %w( a ae ya yae eo e yeo ye o wa wae oe yo u weo we wi yu eu yi i )

    hangul.zip(latin).each do |(given, expect)|
      assert_nothing_raised "given #{given.inspect} expect #{expect.inspect}" do
        actual = HangulTools.romanize(given, system: :revised)
        assert_equal expect, actual
      end
    end
  end

  def test_revised_romanization_of_lead_consonants
    hangul = %w( 가 까 나 다 따 라 마 바 빠 사 싸 아 자 짜 차 카 타 파 하 )
    latin  = %w( ga kka na da tta ra ma ba ppa sa ssa a ja jja cha ka ta pa ha )

    hangul.zip(latin).each do |(given, expect)|
      assert_nothing_raised "given #{given.inspect} expect #{expect.inspect}" do
        actual = HangulTools.romanize(given, system: :revised)
        assert_equal expect, actual
      end
    end
  end

  def test_revised_romanization_of_tail_consonants
    hangul = %w( 악 앆 앇 안 앉 않 앋 알 앍 앎 앏 앐 앑 앒 앓 암 압 앖 앗 았 앙 앚 앛 앜 앝 앞 앟 )
    latin  = %w( ak ak ak an ant an at al alk alm alp alt alt alp al am ap ap at at ang at at ak at ap at )

    hangul.zip(latin).each do |(given, expect)|
      assert_nothing_raised "given #{given.inspect} expect #{expect.inspect}" do
        actual = HangulTools.romanize(given, system: :revised)
        assert_equal expect, actual
      end
    end
  end

  def test_revised_romanization_concatenation_of_consecutive_syllables
    given = "안녕하십니까"
    actual = HangulTools.romanize(given, system: :revised)

    assert_equal "annyeonghasimnikka", actual
  end

  def test_romanization_of_mixed_hangul_and_latin_romanizes_only_hangul
    given = 'I said, "안녕하십니까," and she said "누구세요?"'
    actual = HangulTools.romanize(given, system: :revised)

    assert_equal 'I said, "annyeonghasimnikka," and she said "nuguseyo?"', actual
  end

  def test_mccune_reischauer_romanization_of_vowels
    hangul = %w( 아 애 야 얘 어 에 여 예 오 와 왜 외 요 우 워 웨 위 유 으 의 이 )
    latin  = %w( a ae ya yae ŏ e yŏ ye o wa wae oe yo u wŏ we wi yu ŭ ŭi i )

    hangul.zip(latin).each do |(given, expect)|
      assert_nothing_raised "given #{given.inspect} expect #{expect.inspect}" do
        actual = HangulTools.romanize(given, system: :mccune_reischauer)
        assert_equal expect, actual
      end
    end
  end

  def test_mccune_reischauer_romanization_of_lead_consonants
    hangul = %w( 가 까 나 다 따 라 마 바 빠 사 싸 아 자 짜 차 카 타 파 하 )
    latin  = %w( ka kka na ta tta ra ma pa ppa sa ssa a cha tcha ch'a k'a t'a p'a ha )

    hangul.zip(latin).each do |(given, expect)|
      assert_nothing_raised "given #{given.inspect} expect #{expect.inspect}" do
        actual = HangulTools.romanize(given, system: :mccune_reischauer)
        assert_equal expect, actual
      end
    end
  end

  def test_mccune_reischauer_romanization_of_tail_consonants
    hangul = %w( 악 앆 앇 안 앉 않 앋 알 앍 앎 앏 앐 앑 앒 앓 암 압 앖 앗 았 앙 앚 앛 앜 앝 앞 앟 )
    latin  = %w( ak akk ak an ant an at al alk alm alp alt alt alp' al am ap ap at at ang at at ak at ap at )

    hangul.zip(latin).each do |(given, expect)|
      assert_nothing_raised "given #{given.inspect} expect #{expect.inspect}" do
        actual = HangulTools.romanize(given, system: :mccune_reischauer)
        assert_equal expect, actual
      end
    end
  end

  def test_mccune_reischauer_romanization_concatenation_of_consecutive_syllables
    given = "안녕하십니까"
    actual = HangulTools.romanize(given, system: :mccune_reischauer)

    assert_equal "annyŏnghashimnikka", actual
  end

  def test_romanize_with_initial_voiced
    given = "가자"
    actual = HangulTools.romanize(given, system: :mccune_reischauer, initial: :voiced)

    assert_equal "gaja", actual
  end
end
