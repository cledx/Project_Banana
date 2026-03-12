namespace :backfill do
  desc "Populate recipes.cloudinary_public_id by looking up matching Cloudinary resources"
  task recipe_cloudinary_ids: :environment do
    require "cloudinary"

    puts "Backfilling recipes.cloudinary_public_id from Cloudinary..."

    Recipe.find_each do |recipe|
      slug = recipe.name.to_s.downcase.gsub(" ", "_")
      prefix = "recipe_images/#{slug}" # adjust/remove folder if needed

      begin
        result = Cloudinary::Api.resources(
          type: "upload",
          prefix: prefix,
          max_results: 1
        )

        resource = result["resources"].first

        if resource
          public_id = resource["public_id"]
          recipe.update_columns(cloudinary_public_id: public_id)
          puts "Updated Recipe ##{recipe.id} (#{recipe.name}) -> #{public_id}"
        else
          puts "NO MATCH for Recipe ##{recipe.id} (#{recipe.name}), prefix: #{prefix}"
        end
      rescue Cloudinary::Api::Error => e
        puts "Cloudinary error for Recipe ##{recipe.id} (#{recipe.name}): #{e.message}"
      end
    end

    puts "Backfill complete."
  end
end

