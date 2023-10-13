def trim_it(lists, characters=' '):
    new_words = []
    single_characters = list(characters)
    print(single_characters)
    for words in lists:
        split_words = list(words)
        split_words = [c for c in split_words if c not in single_characters]
        new_word = ''.join(split_words)
        new_words.append(new_word)
    return new_words


strings = ['Baloney', 'Salami', 'yummy', 'tofu']
result = trim_it(strings, 'am')
print(result)
