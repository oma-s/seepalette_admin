class CreateUser < ActiveRecord::Migration[8.0]
  def up
    # Use raw SQL or the model's connection to avoid loading the model
    return if ActiveRecord::Base.connection.execute("SELECT 1 FROM users WHERE email = 'temp@example.com'").any?

    now = Time.now.utc.to_s(:db)
    # You need to encrypt the password! Easier to use model if you must
    User.create!(
      given_name: 'Temp',
      email: 'temp@example.com',
      password: 'temp1234',
      password_confirmation: 'temp1234',
      created_at: now,
      updated_at: now
    )
  end

  def down
    user = User.find_by(email: 'temp@example.com')
    user&.destroy
  end
end
