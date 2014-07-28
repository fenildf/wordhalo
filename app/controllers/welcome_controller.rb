class WelcomeController < ApplicationController

  def home
    @user = current_user
  end

  def about
  end

  def contact
  end
end
