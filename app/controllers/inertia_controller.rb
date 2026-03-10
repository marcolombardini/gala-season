# frozen_string_literal: true

class InertiaController < ApplicationController
  inertia_share current_user: -> { Current.user&.as_json(only: %i[id first_name last_name email username]) },
                current_organization: -> { Current.organization&.as_json(only: %i[id name email slug]) }
end
