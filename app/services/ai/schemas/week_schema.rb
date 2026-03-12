class Ai::Schemas::WeekSchema < RubyLLM::Schema
  array :days, description: "Exactly 7 day objects, one per day Monday through Sunday, in order. Each object must have date (ISO string) and meals (array of one object with breakfast, lunch, dinner as recipe IDs or 0)." do
    object do
        string :date, description: "The datetime string of the day"
            array :meals, description: "The list of dishes for a day" do
                object do
                    integer :breakfast, description: "Recipe ID from the list for breakfast, or 0 if this meal is not needed"
                    integer :lunch, description: "Recipe ID from the list for lunch, or 0 if this meal is not needed"
                    integer :dinner, description: "Recipe ID from the list for dinner, or 0 if this meal is not needed"
                end
            end
        end
    end
end