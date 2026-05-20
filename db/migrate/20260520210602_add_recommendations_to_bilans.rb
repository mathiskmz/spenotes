class AddRecommendationsToBilans < ActiveRecord::Migration[8.1]
  def change
    add_column :bilans, :recommendations, :text
  end
end
