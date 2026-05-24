# AGENTS.md

## Overview

- This repository manages Qiita article sources under `public/`.
- Date-based article files follow `public/YYYYMMDD-title.md`.
- `scripts/copy_public_diary.rb` converts selected Qiita articles into diary pages for another site.

## Key Files

- `public/`: Markdown article sources with YAML front matter.
- `scripts/copy_public_diary.rb`: Copies `20YYYYMMDD-title.md` files into `/usr/local/src/www/source/diary/YYYY/MMDD-qiita.html.md.erb` and rewrites content.
- `test/copy_public_diary_test.rb`: Regression tests for body and output rewriting.
- `Makefile`: Wrapper commands for Qiita preview and publish.

## Working Rules

- Prefer editing existing article files in `public/` instead of creating alternate copies.
- Preserve YAML front matter fields in Qiita source files unless the task explicitly changes publishing metadata.
- When changing `scripts/copy_public_diary.rb`, update or add tests in `test/copy_public_diary_test.rb`.
- Do not write generated diary output into this repository; the script targets `/usr/local/src/www/source/diary`.

## Commands

- Preview articles locally: `make preview`
- Publish all articles: `make upload`
- Run script syntax check: `ruby -c scripts/copy_public_diary.rb`
- Run rewrite tests: `MT_NO_PLUGINS=1 ruby test/copy_public_diary_test.rb`

## Conversion Notes

- The diary conversion script rewrites front matter to `title`, `tags`, and `qiita_url`.
- The generated ERB body starts with `<%= qiita %>`.
- Markdown transformations in the script are covered by tests; keep tests in sync with any rule changes.
