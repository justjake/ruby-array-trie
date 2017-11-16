require 'array_trie'

class ArrayTrie
  # A trie-like, prefix-tree data structure that maps arbitrary keys to values,
  # provided that the keys may be transformed to and from arrays, as each
  # instance uses an underlying {ArrayTrie} instance for storage.
  #
  # If you only care about trie membership, just map your values to `true`. If
  # your trie keys are already arrays, you can use {ArrayTrie}
  # directly for improved performance.
  class PrefixTrie
    # Create a new Trie for mapping paths to values. This could be useful for
    # storing a large amount of paths-to-data mappings, and querying the trie
    # based on path prefix.
    #
    # @return [PrefixTrie]
    def self.of_paths
      of_strings_split_by('/')
    end

    # Create a new trie for mapping strings to values. This could be useful
    #
    # @return [PrefixTrie]
    def self.of_strings
      of_strings_split_by('')
    end

    # Create a trie for mapping delimited strings to values.
    # String keys will be split by the delimiter for storage.
    #
    # @return [PrefixTrie]
    def self.of_strings_split_by(delim)
      new(
        proc { |str| str.split(delim) },
        proc { |parts| parts.join(delim) }
      )
    end

    # Create a new trie for mapping arrays to values.
    #
    # @return [PrefixTrie]
    def self.of_arrays
      new(
        proc { |x| x },
        proc { |x| x }
      )
    end

    # Create a new Trie
    #
    # @param to_a [#call] A callable that given a key, returns that key as an
    #   array.
    # @param from_a [#call] Inverse of to_a. A callable that given an array,
    #   returns the key form of that array.
    # @param trie [ArrayTrie] (ArrayTrie.new) Underlying trie to use for storage.
    def initialize(to_a, from_a, trie = ArrayTrie.new)
      @to_a = to_a
      @from_a = from_a
      @trie = trie
    end

    def [](key)
      @trie[to_a(key)]
    end

    def []=(key, value)
      @trie[to_a(key)] = value
    end

    def insert_subtrie(key, subtrie)
      @trie.insert_subtrie(to_a(key), subtrie.trie)
    end

    def subtrie(key)
      lower_subtrie = @trie.subtrie(to_a(key))
      return nil unless lower_subtrie
      self.class.new(@to_a, @from_a, lower_subtrie)
    end

    def include?(key)
      @trie.include?(to_a key)
    end

    def include_prefix?(key)
      @trie.include_prefix?(to_a key)
    end

    def count_prefix(key)
      @trie.count_prefix(to_a key)
    end

    def depth_first
      enum = transform_enumerator(@trie.depth_first)
      return enum unless block_given?
      enum.each { |path, value| yield(path, value) }
    end

    def breadth_first
      enum = transform_enumerator(@trie.breadth_first)
      return enum unless block_given?
      enum.each { |path, value| yield(path, value) }
    end

    def count
      @trie.count
    end

    protected

    attr_reader :trie

    private

    def transform_enumerator(enum)
      ::Enumerator.new do |y|
        loop do
          parts, value = enum.next
          y.yield(from_a(parts), value)
        end
      end
    end

    def to_a(key)
      @to_a.call(key)
    end

    def from_a(parts)
      @from_a.call(parts)
    end
  end
end

