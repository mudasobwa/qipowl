Feature: Tags to their Typogrowl representation should be handy and working
  In order to make a markdown-like documents more readable
  I want to use unicode bullets and ruby DSL to produce correct output (it’s 2013, huh)

  Scenario: Tag should be returned by bullet properly
    Given bullet is one of given
    When bullets are "▶⏎§"
    Then tags produced by tag function are [:dt, :br, :h1]

  Scenario: Explicit bold elements should be well-formed
    Given the input string is "Big brown fox ≡≡jumps≡≡ over herself"
    When we normalize the string
    Then the result is "Big brown fox ≡≡ 〈jumps〉 over herself"

  Scenario: Implicit bold elements should be well-formed
    Given the input string is "Big brown fox ≡≡jumps over herself"
    When we normalize the string
    Then the result is "Big brown fox ≡≡ 〈jumps over〉 herself"

  Scenario: Explicit strong elements should be well-formed
    Given the input string is "Big brown fox ≡jumps≡ over herself"
    When we normalize the string
    Then the result is "Big brown fox ≡ 〈jumps〉 over herself"

  Scenario: Implicit strong elements should be well-formed
    Given the input string is "Big brown fox ≡jumps over herself"
    When we normalize the string
    Then the result is "Big brown fox ≡ 〈jumps over〉 herself"

  Scenario: Explicit emphasized elements should be well-formed
    Given the input string is "Big brown fox ≈≈jumps≈≈ over herself"
    When we normalize the string
    Then the result is "Big brown fox ≈≈ 〈jumps〉 over herself"

  Scenario: Implicit emphasized elements should be well-formed
    Given the input string is "Big brown fox ≈≈jumps over herself"
    When we normalize the string
    Then the result is "Big brown fox ≈≈ 〈jumps over〉 herself"

  Scenario: Explicit italic elements should be well-formed
    Given the input string is "Big brown fox ≈jumps≈ over herself"
    When we normalize the string
    Then the result is "Big brown fox ≈ 〈jumps〉 over herself"

  Scenario: Implicit italic elements should be well-formed
    Given the input string is "Big brown fox ≈jumps over herself"
    When we normalize the string
    Then the result is "Big brown fox ≈ 〈jumps over〉 herself"

  Scenario: Italic elements inside bold element should be well-formed
    Given the input string is "Big brown ≡≡fox ≈jumps over herself≡≡"
    When we normalize the string
    Then the result is "Big brown ≡≡ 〈fox ≈ 〈jumps over〉 herself〉"

  Scenario: Italic elements mixed against bold element should be _somehow_ fixed
    Given the input string is "Big brown ≡≡fox ≈jumps≡≡ over≈ herself"
    When we normalize the string
    Then the result is "Big brown ≡≡ 〈fox ≈ 〈jumps〉 over〉 herself"

  Scenario: Screened element should be printed as is
    Given the input string is "Big brown ≡ fox ≈jumps over herself"
    When we normalize the string
    Then the result is "Big brown ≡ fox ≈jumps over herself"

  Scenario: Anchor elements should be well-formed
    Given the input string is "Big brown fox¹jumps over herself"
    When we normalize the string
    Then the result is "Big ⚓ 〈brown fox‖jumps〉 over herself"

  Scenario: Abbr elements should be well-formed
    Given the input string is "Big brown fox†jumps over herself†"
    When we normalize the string
    Then the result is "Big † 〈brown fox‖jumps over herself〉"

  Scenario: Small elements should be well-formed
    Given the input string is "Big ↓brown fox↓ jumps over herself"
    When we normalize the string
    Then the result is "Big ↓ 〈brown fox〉 jumps over herself"

  Scenario: Code elements should be well-formed
    Given the input string is "Big λbrown foxλ jumps over herself"
    When we normalize the string
    Then the result is "Big λ 〈brown fox〉 jumps over herself"

  Scenario: Images should be well-formed
    Given the input string is "Big http://brown.fox/jumps.jpg over herself"
    When we normalize the string
    Then the result is "Big ⚐ 〈http://brown.fox/jumps.jpg〉 over herself"

  Scenario: Images with alt should be well-formed
    Given the input string is "Big over herself¹http://brown.fox/jumps.jpg"
    When we normalize the string
    Then the result is "Big over ⚐ 〈herself‖http://brown.fox/jumps.jpg〉"

  Scenario: Inlines are correctly replaced with HTML
    Given the input string is "Big ≡≡brown fox ≈jumps over≡≡ herself"
    When we process the string
    Then the result is "Big <b>brown fox <em>jumps</em> over</b> herself"

  Scenario: Anchors are correctly replaced with HTML
    Given the input string is "Big brown fox¹http://jumps over herself"
    When we process the string
    Then the result is "Big <a href='http://jumps'>brown fox</a> over herself"

  Scenario: Abbrs are correctly replaced with HTML
    Given the input string is "Big brown fox†jumps over† herself"
    When we process the string
    Then the result is "Big <abbr title='jumps over'>brown fox</abbr> herself"

  Scenario: Implicit abbrs are correctly replaced with HTML
    Given the input string is "Big brown fox†jumps over herself"
    When we process the string
    Then the result is "Big <abbr title='jumps over herself'>brown fox</abbr>"

  Scenario: Full load of inlines should be processed
    Given the input string is "Big ≡brown fox¹jumps over ≈herself≈≡"
    When we process the string
    Then the result is "Big <strong>brown <abbr title='jumps'>fox</abbr> over <em>herself</em></strong>"

  Scenario: Inplace ruby is _somehow_ supported
    Given the input string is "Big #{'='*10} brown fox jumps over herself"
    When we process the string
    Then the result is "Big #{'='*10} brown fox jumps over herself"

