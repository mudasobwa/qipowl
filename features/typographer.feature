Feature: Text is to be typographed (spacing and pubctuation are to be sanitized)

  # Known bug: see last example in first scenario outline
  Scenario Outline: Quotes and punctuation in English
    Given the input string is <input>
    When input string is processed with Typogrowl’s typography parser
    Then the typoed result should equal to <output>
    And neither single nor double quotes are left in the string

    Examples:
        | input                          | output                             |
        | "And God said \"∇×(∇×F) = ∇(∇·F) − ∇2F\" and there was light." | "And God said “∇×(∇×F) = ∇(∇·F) − ∇2F” and there was light." |
        | "And God said \"I--heard \"Booh \"Bah\" Booh\" and \"Bam\" in heaven\" and there was light." | "And God said “I—heard ‘Booh “Bah” Booh’ and ‘Bam’ in heaven” and there was light." |
        | "And God said \"I - heard \"Booh Bah Booh\" and \"Bam\" in heaven\" and there was light." | "And God said “I—heard ‘Booh Bah Booh’ and ‘Bam’ in heaven” and there was light." |
        | "And God said \"Oslo coordinates are: 59°57′N 10°45′E\" and there was light." | "And God said “Oslo coordinates are: 59°57′N 10°45′E” and there was light." |
        | "And God said \"That's a 6.3\" man, he sees sunsets at 10°20'30\" E.\" and there was light." | "And God said “That’s a 6.3″ man, he sees sunsets at 10°20′30″ E.” and there was light." |
        | "And God said \"Foo\" , and there was light." | "And God said “Foo,” and there was light." |
        | "And God said \"Baz heard 'Foos' Bar' once\" , and there was light." | "And God said “Baz heard ‘Foos’ Bar’ once,” and there was light." |

  Scenario Outline: Quotes and punctuation in Russian
    Given the input string is <input>
    When input string is processed with Typogrowl’s typography parser with lang "ru"
    Then the typoed result should equal to <output>
    And neither single nor double quotes are left in the string

    Examples:
        | input                          | output                             |
        | "И Бог сказал: \"Я - слышу \"Бум\" и \"Бам\" где-то там\" , и стало светло." | "И Бог сказал: «Я — слышу „Бум“ и „Бам“ где-то там», и стало светло." |
        | "И Бог сказал: \"Я - слышу \"Бум \"и\" Бам\" где-то там\" , и стало светло." | "И Бог сказал: «Я — слышу „Бум «и» Бам“ где-то там», и стало светло." |
 