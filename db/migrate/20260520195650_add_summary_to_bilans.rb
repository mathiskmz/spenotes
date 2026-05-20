class AddSummaryToBilans < ActiveRecord::Migration[8.1]
  def change
    add_column :bilans, :summary, :text
  end
end
