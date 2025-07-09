class WorkingHoursController < InheritedResources::Base

  private

    def working_hour_params
      params.require(:working_hour).permit(:date, :start_at, :end_at, :break_minutes, :duration_minutes, :user_id)
    end

end
