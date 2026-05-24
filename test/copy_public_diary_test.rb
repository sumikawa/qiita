#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../scripts/copy_public_diary'

class CopyPublicDiaryTest < Minitest::Test
  def test_build_output_uses_qiita_url_front_matter_and_argless_helper
    content = <<~MD
      ---
      title: Example Title
      tags:
        - Ruby
      id: abc123
      ---
      body
    MD
    front_matter = FRONT_MATTER_PATTERN.match(content)
    metadata = YAML.safe_load(front_matter[:header], permitted_classes: [], aliases: false)

    output = build_output(content, front_matter, metadata)

    assert_includes output, "qiita_url: https://qiita.com/sumikawa@github/items/abc123\n"
    assert_includes output, "<%= qiita %>\n"
    refute_includes output, "<%= qiita('https://qiita.com/sumikawa@github/items/abc123') %>"
  end

  def test_adds_space_after_single_backtick_inline_code
    assert_equal "`code` x", transform_body("`code`x")
  end

  def test_does_not_change_single_backtick_inline_code_when_space_exists
    assert_equal "`code` x", transform_body("`code` x")
  end

  def test_adds_space_after_triple_backtick_inline_code
    assert_equal "```code``` x", transform_body("```code```x")
  end

  def test_does_not_change_triple_backtick_inline_code_when_space_exists
    assert_equal "```code``` x", transform_body("```code``` x")
  end

  def test_normalizes_diff_fence_suffix
    input = "```diff_ruby\n- old\n+ new\n```"
    expected = "```diff\n- old\n+ new\n```"
    assert_equal expected, transform_body(input)
  end
end
