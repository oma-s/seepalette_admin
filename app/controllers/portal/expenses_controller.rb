# frozen_string_literal: true

module Portal
  class ExpensesController < BaseController
    before_action :set_expense, only: %i[edit update destroy]

    def index
      @month = requested_month
      @expenses = current_user.expenses.where(date: @month.all_month).chronological
      @total = @expenses.sum("km * factor")
    end

    def new
      @expense = current_user.expenses.new(
        date: Time.zone.today,
        start_address: current_user.addresses.first&.to_s,
        factor: Expense::DEFAULT_FACTOR
      )
    end

    def create
      @expense = current_user.expenses.new(expense_params.merge(factor: Expense::DEFAULT_FACTOR))
      if @expense.save
        redirect_to portal_expenses_path(month: @expense.date.strftime("%Y-%m")), notice: "Fahrtkosten wurden erfasst."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @expense.update(expense_params)
        redirect_to portal_expenses_path(month: @expense.date.strftime("%Y-%m")), notice: "Fahrtkosten wurden aktualisiert."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      month = @expense.date.strftime("%Y-%m")
      @expense.destroy!
      redirect_to portal_expenses_path(month: month), notice: "Fahrtkosten wurden gelöscht."
    end

    private

    def set_expense
      @expense = current_user.expenses.find(params[:id])
    end

    def expense_params
      params.require(:expense).permit(:date, :start_address, :end_address, :purpose, :km)
    end

    def requested_month
      Date.strptime(params[:month].to_s, "%Y-%m").beginning_of_month
    rescue Date::Error
      Time.zone.today.beginning_of_month
    end
  end
end
