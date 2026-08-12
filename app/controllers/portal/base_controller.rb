# frozen_string_literal: true

module Portal
  class BaseController < ApplicationController
    before_action :authenticate_user!

    layout "portal"
  end
end
