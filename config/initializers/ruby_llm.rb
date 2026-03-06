# RubyLLM configuration. Add the API keys you need to .env (or ENV).
# See https://rubyllm.com/configuration
#
# Use OPENAI_API_KEY for api.openai.com, or GITHUB_TOKEN + Azure base for GitHub Azure inference.
#
RubyLLM.configure do |config|
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.openai_api_base = "https://api.openai.com/v1"
end
