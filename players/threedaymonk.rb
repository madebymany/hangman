class ThreeDayMonkPlayer
  # Returns this players name.
  def name
    "threedaymonk (normal)"
  end

  # Prepares for a new game (no action required for this player).
  def new_game(dictionary)
    @dictionary = dictionary
    @letters_played = []
    @phrases_played = []
    @rejected = []
  end

  # For each turn, show a prompt to the user and return what was typed.
  def take_turn(pattern)
    guess = exact_phrase(pattern)
    if guess
      @phrases_played << guess
      return guess
    end

    most_likely(pattern).tap{ |play|
      @letters_played << play
    }
  end

private

  def threshold
    2
  end

  def exact_phrase(pattern)
    reject_pattern = rejection_pattern(pattern)
    if reject_pattern
      possible_words = @dictionary.select{ |w| w !~ reject_pattern }
    else
      possible_words = @dictionary
    end

    all = pattern.split("/").map{ |wpat|
      regexp = wpat_regexp(wpat)
      possible_words.select{ |w| w=~ regexp }
    }

    total = all.inject(0){ |a,e| a + e.length }
    if (total - pattern.split("/").length) < threshold
      all.map{ |w| w[rand(w.length)] }.join("/")
    else
      nil
    end
  end

  def most_likely(pattern)
    dict  = dictionary_for_turn(pattern)
    freqs = find_frequencies(dict)

    candidates = freqs.sort_by{ |l,f| -f }.
                       map{ |l,f| l }

    best(candidates - @letters_played)
  end

  def best(a)
    a.first
  end

  def find_frequencies(words)
    Hash.new{ |h, k| h[k] = 0 }.tap{ |f|
      words.each do |word|
        word.scan(/[a-z]/).each do |letter|
          f[letter] += 1
        end
      end
    }
  end

  def wpat_regexp(wpat)
    Regexp.new("^" + wpat.gsub("_", ".") + "$")
  end

  def rejection_pattern(pattern)
    rejected = @letters_played - pattern.scan(/[a-z]/)
    rejected.any? && Regexp.new("[" + rejected.join("") + "]")
  end

  def dictionary_for_turn(pattern)
    reject_pattern = rejection_pattern(pattern)
    [].tap{ |result|
      pattern.split("/").each do |known|
        regexp = wpat_regexp(known)
        @dictionary.each do |word|
          if word.match(regexp) && !(reject_pattern && word.match(reject_pattern))
            result << word
          end
        end
      end
    }
  end
end
