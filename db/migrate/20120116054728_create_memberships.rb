class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references  :user
      t.references  :group
      t.string      :role,        default: 'user'
      t.integer     :roles_mask
      t.timestamps
    end
    add_index :memberships, :group_id
  end
end
