module SessionsHelper
    def sign_in(user)
        remember_token = User.new_remember_token
        cookies.permanent[:remember_token] = remember_token
        user.update_attribute(:remember_token, User.hash(remember_token))
        self.current_user = user
    end
    
    def signed_in?
        !current_user.nil?
    end
    
    def sign_out
        self.current_user.update_attribute(:remember_token, User.hash(User.new_remember_token))
        self.current_user = nil
        cookies.delete(:remember_token)
    end
    
    def current_user=(user)
        @current_user = user
    end
    
    def current_user
        remember_token = User.hash(cookies[:remember_token])
        @current_user ||= User.find_by(remember_token: remember_token)
    end
    
    def query(word_title)
        word_title = word_title.downcase
        word = Word.find_by(title: word_title)
        return word if word != nil
        
        word = Word.new
        word.version = 1
        word.fetch_content(word_title)
          
        return word
    end
end
