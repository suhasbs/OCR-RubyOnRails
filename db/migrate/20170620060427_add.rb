class Add < ActiveRecord::Migration[5.1]
  def change
    add_column :file_uploads, :status, :integer
  end
end
