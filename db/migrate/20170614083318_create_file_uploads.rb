class CreateFileUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :file_uploads do |t|
      t.string :filename
      t.string :path

    end
  end
end
