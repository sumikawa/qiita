#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'yaml'

SOURCE_DIR = File.expand_path('../public', __dir__)
TARGET_ROOT = '/usr/local/src/www/source/diary'
FILE_PATTERN = /\A(20\d{2})(\d{2})(\d{2})-.+\.md\z/
FRONT_MATTER_PATTERN = /\A---\n(?<header>.*?)\n---\n?/m

def transform_body(body)
  transformed = body.gsub(/^```diff_[^\n]*$/, '```diff')
  transformed = transformed.gsub(/```mermaid\n(.*?)\n```/m) do
    "<pre class=\"mermaid\">\n#{$1}\n</pre>"
  end

  transformed = transformed.gsub(/(?<!`)(?<ticks>`+)([^`\n]+?)\k<ticks>(?!`)(?=\S)/, '\0 ')
  transformed = transformed.gsub(/^## /, '### ')
  transformed.gsub(/^# /, '## ')
end

def build_output(content, front_matter, metadata)
  id = metadata['id']
  title = metadata['title']
  tags = Array(metadata['tags']).filter_map do |tag|
    normalized = tag.to_s.strip.downcase
    normalized unless normalized.empty?
  end
  tags << 'qiita'
  tags.uniq!

  rewritten = +"---\n"
  rewritten << "title: #{title}\n"
  rewritten << "tags: #{tags.join(', ')}\n"
  rewritten << "qiita_url: https://qiita.com/sumikawa@github/items/#{id}\n"
  rewritten << "---\n"
  rewritten << "<%= qiita %>\n"
  rewritten << "\n"
  if content.length > front_matter[0].length
    body = content[front_matter[0].length..]
    rewritten << transform_body(body)
  end
  rewritten
end

def main
  files = Dir.children(SOURCE_DIR).sort.select { |name| FILE_PATTERN.match?(name) }

  if files.empty?
    warn "No matching files found in #{SOURCE_DIR}"
    return 0
  end

  files.each do |name|
    match = FILE_PATTERN.match(name)
    year = match[1]
    month = match[2]
    day = match[3]

    source = File.join(SOURCE_DIR, name)
    target_dir = File.join(TARGET_ROOT, year)
    target = File.join(target_dir, "#{month}#{day}-qiita.html.md.erb")
    content = File.read(source)
    front_matter = FRONT_MATTER_PATTERN.match(content)

    unless front_matter
      warn "Skip #{source}: YAML front matter not found"
      next
    end

    metadata = YAML.safe_load(front_matter[:header], permitted_classes: [], aliases: false) || {}
    id = metadata['id']
    title = metadata['title']

    unless id
      warn "Skip #{source}: id not found in YAML front matter"
      next
    end

    unless title
      warn "Skip #{source}: title not found in YAML front matter"
      next
    end

    rewritten = build_output(content, front_matter, metadata)

    FileUtils.mkdir_p(target_dir)
    File.write(target, rewritten)

    puts "#{source} -> #{target}"
  end

  0
end

exit(main) if $PROGRAM_NAME == __FILE__
