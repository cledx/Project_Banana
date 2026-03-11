#!/usr/bin/env ruby
# Beautifies recipe instructions with Markdown: step headers, bold for Optional, clear structure.

require "json"

def beautify_instructions(raw)
  return raw if raw.to_s.strip.empty?

  text = raw.to_s.strip
  # Split on numbered steps: "1. ", "2. ", etc.
  steps = text.split(/\s*(?=\d+\.\s)/).map(&:strip).reject(&:empty?)

  return raw if steps.empty?

  formatted = steps.map.with_index(1) do |block, i|
    content = block.sub(/\A\d+\.\s*/, "").strip
    content = content.gsub(/\b(Optional:)\s*/i, '**\1** ')
    "### Step #{i}\n\n#{content}"
  end.join("\n\n")

  formatted
end

path = File.expand_path("../db/data/recipesV3.json", __dir__)
data = JSON.parse(File.read(path))

data["data"].each do |recipe|
  next if recipe["instructions"].to_s.strip.empty?
  recipe["instructions"] = beautify_instructions(recipe["instructions"])
end

File.write(path, JSON.pretty_generate(data))
puts "Beautified instructions in #{path}"
