# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "array_trie/version"

Gem::Specification.new do |spec|
  spec.name          = "array_trie"
  spec.version       = ArrayTrie::VERSION
  spec.authors       = ["Jake Teton-Landis"]
  spec.email         = ["jake.tl@airbnb.com"]

  spec.summary       = <<-EOS
Trie-like, prefix-tree data structures that maps from ordered keys to values.
  EOS
  spec.description   = <<-EOS
Trie-like, prefix-tree data structures. First, a prefix-tree based on Arrays, which differs from a traditional trie, which maps strings to values. Second, a more general prefix-tree data structure that works for any type of keys, provided those keys can be transformed to and from an array.

Both of these data structures are implemented in terms of hashes.
  EOS
  spec.homepage      = "https://github.com/justjake/array-trie"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"
end
