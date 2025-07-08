class CreateUser < ActiveRecord::Migration[8.0]
  def up
    return if User.exists?(email: 'temp@example.com')

    User.create!(
      given_name: 'Temp',
      email: 'temp@example.com',
      password: 'temp1234',
      password_confirmation: 'temp1234'
    )
  end

  def down
    User.find_by(email: 'temp@example.com')&.destroy
  end
end
