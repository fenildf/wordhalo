class CardsController < ApplicationController
    def play
        return redirect_to signin_path if not signed_in?
    end
end
