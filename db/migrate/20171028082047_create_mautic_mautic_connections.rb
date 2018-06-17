class CreateMauticMauticConnections < ActiveRecord::Migration[4.2]
  def change
    create_table :mautic_connections do |t|
      t.string :type

      t.string :url
      t.string :client_id
      t.string :secret

      t.string :token
      t.string :refresh_token

      t.timestamps null: false
    end
  end
end
