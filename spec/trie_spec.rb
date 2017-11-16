RSpec.shared_examples 'trie with array keys' do
  let(:path) { %w(foo bar) }
  let(:value) { Object.new }

  describe '#[]=' do
    it 'can set keys' do
      key = %w(foo)
      subject[key] = value
      expect(subject[key]).to be(value)
    end

    it 'rejects non-array keys' do
      expect { subject['huh?'] = value }.to raise_error(ArgumentError, /must be an array/)
    end
  end

  describe '#count' do
    it 'returns the number of keys' do
      subject[%w(foo)] = value
      subject[%w(bar)] = value
      expect(subject.count).to eq(2)
      subject[%w(baz)] = value
      expect(subject.count).to eq(3)
    end
  end

  describe '#subtrie' do
    let(:path) { %w(the foo) }
    before do
      subject[path] = value
      subject[path + %w(bar)] = 1
      subject[path + %w(baz)] = 2
    end
    let(:subtrie) { subject.subtrie(path) }

    it 'returns a subtrie at the given path' do
      expect(subtrie[%w(bar)]).to eq(1)
      expect(subtrie[%w(baz)]).to eq(2)
    end

    it 'shares structure with its parent' do
      subtrie[%w(quux)] = 3
      expect(subject[%w(the foo quux)]).to eq(3)

      subject[path + %w(doggo)] = value
      expect(subtrie[%w(doggo)]).to be(value)
    end

    it 'has a correct #count' do
      expect(subtrie.count).to eq(3)
    end

    it 'shares structure with other subtries of the same path' do
      subtrie2 = subject.subtrie(path)
      subtrie2[%w(doggo)] = value
      expect(subtrie[%w(doggo)]).to be(value)
    end
  end

  describe '#insert_subtrie' do
    let(:child) do
      child = subject2
      child[%w(red)] = 1
      child[%w(blue)] = 2
      child
    end

    before do
      subject.insert_subtrie(path, child)
    end

    it 'gains access to subtrie data' do
      expect(subject[path + %w(red)]).to eq(1)
      expect(subject[path + %w(blue)]).to eq(2)
    end

    it 'shares structure witht the inserted trie' do
      subject[path + %w(green)] = value
      expect(child[%w(green)]).to be(value)
    end
  end

  describe '#include?' do
    before do
      subject[path] = nil
    end

    it 'returns true for set keys' do
      expect(subject.include?(path)).to be(true)
    end

    it 'returns false for unset keys' do
      expect(subject.include?(path[0..-2])).to be(false)
    end
  end

  describe '#include_prefix?' do
    before do
      subject[path] = nil
    end

    it 'returns true for set keys' do
      expect(subject.include_prefix?(path)).to be(true)
    end

    it 'returns true for the prefix of set keys' do
      expect(subject.include_prefix?(path[0..-2])).to be(true)
    end

    it 'returns false for other paths' do
      expect(subject.include_prefix?(path[1..-1])).to be(false)
    end
  end

  context 'with many items' do
    before do
      i = 0
      %w(a b).each do |first|
        %w(1 2 3).each do |second|
          subject[[first, second]] = i
          i += 1
        end
      end
      subject[%w(b)] = 3
      subject[%w(b 3 final)] = i
    end
    let(:result) { subject.count_prefix(path) }
    let(:path) { 'a' }

    describe '#count_prefix' do
      shared_examples 'it returns' do |num|
        it "returns the correct result" do
          expect(result).to eq(num)
        end
      end

      context 'when exact match' do
        let(:path) {%w(a 1)}
        include_examples 'it returns', 1
      end

      context 'when no match' do
        let(:path) { %w(race car) }
        include_examples 'it returns', 0
      end

      context 'basic group' do
        let(:path) { %w(a) }
        include_examples 'it returns', 3
      end

      context 'nested group' do
        let(:path) { %w(b) }
        include_examples 'it returns', 5
      end
    end

    shared_examples 'enumerates all' do
      it 'yields each key if called with block' do
        calls = 0
        subject.depth_first do |key, val|
          calls += 1
          expect(subject[key]).to eq(val)
        end
        expect(calls).to eq(subject.count)
      end

      it 'returns an enumerator' do
        expect(subject.depth_first).to be_a(::Enumerator)
      end
    end

    describe '#depth_first' do
      it 'traverses in depth-first order' do
        value_order = subject.depth_first.to_a.map(&:last)
        expect(value_order).to eq(value_order.sort)
      end

      include_examples 'enumerates all'
    end

    describe '#breadth_first' do
      before do
        subject[%w(b)] = value
      end

      it 'traverses in breadth-first order' do
        value_order = subject.breadth_first.to_a.map(&:last)
        expect(value_order.first).to be(value)
        rest = value_order[1..-1]
        expect(rest).to eq(rest.sort)
      end

      include_examples 'enumerates all'
    end
  end
end

require 'array_trie'

RSpec.describe ArrayTrie do
  subject { described_class.new }
  let(:subject2) { described_class.new }
  it_behaves_like 'trie with array keys'
end

require 'array_trie/prefix_trie'

RSpec.describe ArrayTrie::PrefixTrie do
  context '.of_arrays' do
    subject { described_class.of_arrays }
    let(:subject2) { described_class.of_arrays }
    it_behaves_like 'trie with array keys'
  end
end
