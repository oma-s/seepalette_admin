class ExpensesController < InheritedResources::Base

  private

    def expense_params
      params.require(:expense).permit(:user_id, :date, :start_address, :end_address, :km, :factor)
    end

end
