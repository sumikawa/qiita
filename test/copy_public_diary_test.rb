#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../scripts/copy_public_diary'

class CopyPublicDiaryTest < Minitest::Test
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
end
