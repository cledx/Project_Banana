class Ai::Schemas::WeekSchema < RubyLLM::Schema
  array :days, description: "The list of days in the week" do
    object do
        string :date, description: "The datetime string of the day"
            array :meals, description: "The list of dishes for a day" do
                object do
                    integer :breakfast, description: "The id number of recipe for the breakfast"
                    integer :lunch, description: "The id number of recipe for the lunch"
                    integer :dinner, description: "The id number of recipe for the dinner"
                end
            end
        end
    end
end