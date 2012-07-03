require File.dirname(__FILE__) + '/helper'

class TestRevListParser < Test::Unit::TestCase
  def setup
    @r = Repo.new(File.join(File.dirname(__FILE__), *%w[dot_git_signed_tag_merged]), :is_bare => true)
  end

  def test_parsing_single_commit
    sha = '671d0b0a85af271395eb71ff91f942f54681b144'
    rev_list = @r.git.rev_list({:pretty => "raw", :max_count => 1}, sha)

    parser = Grit::RevListParser.new(rev_list)
    assert_equal 1, parser.entries.size
    assert entry = parser.entries.first
    assert_equal "Merge tag 'v1.1' into bar", entry.message_lines.first
    assert_equal '671d0b0a85af271395eb71ff91f942f54681b144', entry.meta['commit'].to_s
    assert_equal 'a9ac6c1e58bbdd7693e49ce34b32d9b0b53c0bcf', entry.meta['tree'].to_s
    assert_equal [
      'dce37589cfa5748900d05ab07ee2af5010866838', 'b2b1760347d797f3dc79360d487b9afa7baafd6a'],
      entry.meta['parent']

    assert_match /^Jonathan /, entry.meta['author'].to_s
    assert_match /^Jonathan /, entry.meta['committer'].to_s
    assert_equal 'object b2b1760347d797f3dc79360d487b9afa7baafd6a', entry.meta['mergetag'].to_s
  end

  def test_parsing_multiple_commits
    rev_list = @r.git.rev_list({:pretty => "raw", :all => true})

    parser = Grit::RevListParser.new(rev_list)
    assert_equal 4, parser.entries.size
    shas = %w(671d0b0a85af271395eb71ff91f942f54681b144
              dce37589cfa5748900d05ab07ee2af5010866838
              b2b1760347d797f3dc79360d487b9afa7baafd6a
              2ae8b20538f5d358e97978632965efc380c42c9a)
    shas.each_with_index do |sha, idx|
      assert entry = parser.entries[idx], "no entry for commit #{idx+1}"
      assert_equal sha, entry.meta['commit'].to_s, "different sha for commit #{idx+1}"
    end
  end
end

