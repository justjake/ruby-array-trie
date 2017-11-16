# ArrayTrie is a trie-like, prefix-tree data structure that maps from arrays to
# values. This differs from a traditional trie, which maps strings to values.
#
# ArrayTrie is implemented in terms of Ruby hashes, so members of your array
# keys must behave by Ruby's hash contracts:
# https://ruby-doc.org/core-2.3.1/Hash.html#class-Hash-label-Hash+Keys
#
# If you wish to construct a prefix tree with non-Array keys, please see
# {ArrayTrie::PrefixTrie}, which can map arbitrary keys to values, so long as
# your keys can be converted to and from arrays.
class ArrayTrie
  require 'array_trie/version'

  # Just a unique marker value.
  # Using Class.new is better than using Object.new, because it makes sense
  # when inspected.
  #
  # @api private
  STOP = Class.new

  def initialize(root = {})
    @root = root
  end

  # Retrieve a value for the given key
  #
  # @param parts [Array]
  # @return [Any] the previously stored value
  # @return [nil] if the given key was not found
  def [](parts)
    last_node, remaining = traverse(@root, parts)
    return nil unless remaining.empty?
    last_node[STOP]
  end

  # Set a key to a value
  #
  # @param parts [Array] the key
  # @param value [Any] the value
  def []=(parts, value)
    last_node, * = traverse(@root, parts, true)
    last_node[STOP] = value
  end

  # insert a subtrie into this trie.
  #
  # @param parts [Array]
  # @param trie [ArrayTrie]
  # @return self
  def insert_subtrie(parts, trie)
    raise ArgumentError.new("trie must be a trie") unless trie.is_a? self.class
    raise ArgumentError.new("cannot insert a subtrie at the root") if parts.empty?
    parent, * = traverse(@root, parts[0...-1], true)
    parent[parts.last] = trie.root
    self
  end

  # Retrieve a view into this trie at the given key. Underlying data storage is
  # shared with the subtrie.
  #
  # @param parts [Array]
  # @return [ArrayTrie]
  def subtrie(parts)
    last_node, remaining = traverse(@root, parts)
    return nil unless remaining.empty?
    self.class.new(last_node)
  end

  # Returns true if this array is a key in this trie.
  #
  # @param parts [Array]
  # @return [Boolean]
  def include?(parts)
    last_node, remaining = traverse(@root, parts)
    return false unless remaining.empty?
    last_node.key?(STOP)
  end

  # Returns true if this array is a prefix of an array in this trie
  #
  # @param parts [Array]
  # @return [Boolean]
  def include_prefix?(parts)
    _, remaining = traverse(@root, parts)
    remaining.empty?
  end

  # @return [Integer] Number of keys under the given prefix
  def count_prefix(parts)
    trie = subtrie(parts)
    trie ? trie.count : 0
  end

  # @return [Enumerator] a depth-first enumerator
  def depth_first
    enum = depth_first_enumerator(@root)
    return enum unless block_given?
    enum.each { |path, value| yield(path, value) }
  end

  # @return [Enumerator] a breadth-first enumerator
  def breadth_first
    enum = breadth_first_enumerator(@root)
    return enum unless block_given?
    enum.each { |path, value| yield(path, value) }
  end

  # Count the number of key-value pairs in this trie.
  #
  # @return [Integer]
  def count
    breadth_first.count
  end

  protected

  attr_reader :root

  private

  def depth_first_enumerator(node, current_path = [])
    ::Enumerator.new do |y|
      depth_first_scan(node, current_path) { |path, value| y.yield(path, value) }
    end
  end

  def breadth_first_enumerator(node, start_path = [])
    ::Enumerator.new do |y|
      breadth_first_scan(node, start_path) { |path, value| y.yield(path, value) }
    end
  end

  # recursive version was just too much easier
  def depth_first_scan(current_node, current_path = [], &block)
    if current_node.key?(STOP)
      yield(current_path, current_node[STOP])
    end

    current_node.each do |key, value|
      # already handled
      next if key == STOP

      # recurse
      depth_first_scan(value, current_path + [key], &block)
    end
  end

  def breadth_first_scan(node, start_path = [])
    raise ::ArgumentError.new('block required') unless block_given?

    queue = [ [node, start_path] ]
    loop do
      break if queue.empty?
      current_node, current_path = queue.shift

      if current_node.key?(STOP)
        yield(current_path, current_node[STOP])
      end

      current_node.each do |key, value|
        next if key == STOP
        queue << [value, current_path + [key]]
      end
    end
  end

  # traverse from node `start`, to the node at path `parts`
  #
  # traversals are best-effort, and return the furthest node they can
  # reach, and the remaining parts of the traversal path.
  def traverse(start, parts, inserting = false)
    assert_is_array!(parts)

    if parts.empty?
      return [start, []]
    end

    current_node = start
    parts.each_with_index do |part, index|
      if inserting
        next_node = current_node[part] ||= {}
      else
        next_node = current_node[part]
        return [current_node, parts[index..-1]] unless next_node
      end

      if index == parts.length - 1
        return [next_node, []]
      end

      current_node = next_node
    end
  end

  def assert_is_array!(parts)
    unless parts.is_a?(::Array)
      raise ::ArgumentError.new("key must be an array, instead is #{parts.inspect}")
    end
  end
end
