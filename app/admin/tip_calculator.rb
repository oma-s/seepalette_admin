ActiveAdmin.register_page 'Tip Calculator' do
  menu priority: 100, label: 'Tip Calculator'

  content do
    panel 'Tip Calculator' do
      div do
        para "Enter the total tip amount and select a timeframe to calculate each user's share."
      end

      # Form
      form action: admin_tip_calculator_index_path, method: :post do |_f|
        # CSRF token for Rails
        input type: 'hidden', name: request_forgery_protection_token.to_s, value: form_authenticity_token
        div do
          label 'Total Tip Amount', for: 'tip_amount'
          input type: 'number', name: 'tip_amount', id: 'tip_amount', min: 0, step: 0.01, value: params[:tip_amount]
        end
        div do
          label 'Start Date', for: 'start_date'
          input type: 'date', name: 'start_date', id: 'start_date', value: params[:start_date]
        end
        div do
          label 'End Date', for: 'end_date'
          input type: 'date', name: 'end_date', id: 'end_date', value: params[:end_date]
        end
        div style: 'margin-top: 1em; margin-bottom: 2em;' do
          input type: 'submit', value: 'Calculate', class: 'button',
                style: 'padding: 0.5em 1.5em; font-size: 1em; background: #2563eb; color: #fff; border: none; border-radius: 4px; cursor: pointer;'
        end
      end

      # Results

      if params[:tip_amount].present? && params[:start_date].present? && params[:end_date].present?
        tip_amount = params[:tip_amount].to_f
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])

        # Fetch working hours in timeframe
        user_hours = User.joins(:working_hours)
                         .where(working_hours: { date: start_date..end_date })
                         .group('users.id')
                         .select('users.*, SUM(working_hours.duration_minutes) as total_minutes')

        total_minutes = user_hours.sum { |u| u.total_minutes.to_f }

        if total_minutes > 0
          table_for user_hours do
            column 'Name' do |user|
              user.to_s
            end
            column 'Hours Worked' do |user|
              (user.total_minutes.to_f / 60.0).round(2)
            end
            column 'Tip Share' do |user|
              number_to_currency((user.total_minutes.to_f / total_minutes) * tip_amount, locale: :de)
            end
          end
        else
          para 'No working hours found in the selected timeframe.'
        end
      end
    end
  end

  page_action :index, method: :get do
    # just render
  end

  page_action :index, method: :post do
    # just render
  end
end
