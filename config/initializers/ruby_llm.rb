# RubyLLM configuration. Add the API keys you need to .env (or ENV).
# See https://rubyllm.com/configuration
#
# Use OPENAI_API_KEY for api.openai.com, or GITHUB_TOKEN + Azure base for GitHub Azure inference.
#
RubyLLM.configure do |config|
  config.openai_api_key = ENV["GITHUB_TOKEN"]
  config.openai_api_base = "https://models.inference.ai.azure.com"
end
