# Example RubyLLM tool. Replace or remove when adding your real tools.
#
# Use: RubyLLM.chat.with_tool(ExampleTool).ask("What's 2 + 2?")
# I asked AI to make me an example tool so I could see how to use it.
# I've left it here for now to reference
#

class ExampleTool < RubyLLM::Tool
  description "Returns a friendly greeting or echo"

  param :message, desc: "Message to echo back"
  param :greet, type: :boolean, desc: "If true, prepend a greeting", required: false

  def execute(message:, greet: false)
    if greet
      "Hello! You said: #{message}"
    else
      message
    end
  end
end
