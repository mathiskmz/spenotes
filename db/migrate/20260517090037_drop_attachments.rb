class DropAttachments < ActiveRecord::Migration[8.1]
  def change
    drop_table :attachments
  end
end
