Feature: All internal functions should behave properly
   In order make the parsing and HTML generation available
   I want to have a sandbox to test internal functions

  Scenario: Block string should be identified properly
    Given the input string is "✎ Comment"
    When we check it against Map::inline?
    Then the result is expected: "true"

  Scenario: Inline string should be identified properly
    Given the input string is "Big ≡≡brown fox ≈jumps over≡≡ herself"
    When we check it against Map::inline?
    Then the result is expected: "true"

  Scenario: Pure string should be identified properly
    Given the input string is "Big brown fox jumps over herself"
    When we check it against Map::inline?
    Then the result is expected: "false"

  Scenario: Same tag works properly
    Given the input strings are "»" and "“"
    When we check it against Map::same_tag?
    Then the result is expected: "true"

  Scenario: Different tags works properly
    Given the input strings are "§" and "“"
    When we check it against Map::same_tag?
    Then the result is expected: "false"

  Scenario: Monkeypatch for String.tg_styling should work as expected
    Given the input string is "Big ≡≡brown fox ≡jumps over≡≡ herself"
    When we call tg_styling method on it
    Then the result is expected: "Big ≡≡ 〈brown fox ≡ 〈jumps〉 over〉 herself"

