class WelcomeController < ApplicationController
  def play
    return redirect_to signin_path if not signed_in?
  end

  def home
  end

  def about
  end

  def contact
  end
end
