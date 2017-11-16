# ArrayTrie

[![Ruby gem](https://img.shields.io/gem/v/array_trie.svg)](https://rubygems.org/gems/array_trie)
[API docs](https://www.rubydoc.info/gems/array_trie)

Trie-like, prefix-tree data structures. First, a prefix-tree based on Arrays, which differs from a traditional trie, which maps strings to values. Second, a more general prefix-tree data structure that works for any type of keys, provided those keys can be transformed to and from an array.

Both of these data structures are implemented in terms of hashes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'array_trie'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install array_trie

## Usage

Use the base `ArrayTrie` class if you want to work with an array-keyed trie.
The more general `ArrayTrie::PrefixTrie` class can be used with any sort of
ordered key.

```ruby
require 'array_trie/prefix_trie'

# You can store any sort of ordered key in a PrefixTrie, provided you can
# convert to and from arrays in a stable way.
path_to_a = -> (path) { path.split('/') }
a_to_path = -> (array) { array.join('/') }
paths = ArrayTrie::PrefixTrie.new(path_to_a, a_to_path)

# Store some keys in the trie
paths['/usr/local/bin/ruby'] = 'executable'
paths['/usr/local/etc/nginx/nginx.cfg'] = 'config file'
paths['/bin/bash'] = 'executable'

# Tries have efficient prefix queries
paths.include_prefix?('/usr/local') 
# => true
paths.count_prefix('/usr/local')
# => 2

# You can obtain a subtrie to operate on a subsection of your trie
usr_local = paths.subtrie('/usr/local')
usr_local['bin/ruby']
# => 'executable'

usr_local['bin/fish'] = 'executable'
paths['/usr/local/bin/fish']
# => executable

# Use #breadth_first and #depth_first to enumarate your keys and values
paths.breadth_first do |k, v|
  puts "Path #{k} is of type #{v}"
end
# STDOUT: Path /bin/bash is of type executable
# STDOUT: Path /usr/local/bin/ruby is of type executable
# STDOUT: Path /usr/local/etc/nginx/nginx.cfg is of type config file

# These methods return Enumerators, so you can use them with #map, etc.
enum = paths.depth_first
as_hash = Hash[enum.to_a]
# => {
# "/usr/local/bin/ruby"=>"executable",
# "/usr/local/etc/nginx/nginx.cfg"=>"config file",
# "/bin/bash"=>"executable"}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Finally, use `bin/test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/justjake/array_trie.
