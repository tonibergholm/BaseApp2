class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  before_filter :find_user, 
    :only => [:profile, 
              :edit_password,   :update_password, 
              :edit_email,      :update_email ]
  
  layout 'login'
  

  def troubleshooting
    # Render troubleshooting.html.erb
    render :layout => 'login'
  end

  def clueless
    # These users are beyond our automated help...
    render :layout => 'login'
  end

  
  def edit_password
    if ! @user.not_using_openid?
      flash[:notice] = "You cannot update your password. You are using OpenID!"
      redirect_to :back
    end
    
    # render edit_password.html.erb
  end
  
  def update_password    
    if ! @user.not_using_openid?
      flash[:notice] = "You cannot update your password. You are using OpenID!"
      redirect_to :back
    end
    
    if current_user == @user
      current_password, new_password, new_password_confirmation = params[:current_password], params[:new_password], params[:new_password_confirmation]
      
      if @user.encrypt(current_password) == @user.crypted_password
        if new_password == new_password_confirmation
          if new_password.blank? || new_password_confirmation.blank?
            flash[:error] = "You cannot set a blank password."
            redirect_to edit_password_user_url(@user)
          else
            @user.password = new_password
            @user.password_confirmation = new_password_confirmation
            @user.save
            flash[:notice] = "Your password has been updated."
            redirect_to profile_url(@user)
          end
        else
          flash[:error] = "Your new password and it's confirmation don't match."
          redirect_to edit_password_user_url(@user)
        end
      else
        flash[:error] = "Your current password is not correct. Your password has not been updated."
        redirect_to edit_password_user_url(@user)
      end
    else
      flash[:error] = "You cannot update another user's password!"
      redirect_to edit_password_user_url(@user)
    end
  end
  
  def edit_email
    if ! @user.not_using_openid?
      flash[:notice] = "You cannot update your email address. You are using OpenID!"
      redirect_to :back
    end
    
    # render edit_email.html.erb
  end
  
  def update_email
    if ! @user.not_using_openid?
      flash[:notice] = "You cannot update your email address. You are using OpenID!"
      redirect_to :back
    end
    
    if current_user == @user
      if @user.update_attributes(:email => params[:email])
        flash[:notice] = "Your email address has been updated."
        redirect_to profile_url(@user)
      else
        flash[:error] = "Your email address could not be updated."
        redirect_to edit_email_user_url(@user)
      end
    else
      flash[:error] = "You cannot update another user's email address!"
      redirect_to edit_email_user_url(@user)
    end
  end  
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    current_user.delete!
    
    logout_killing_session!
    
    flash[:notice] = "Your account has been removed."
    redirect_back_or_default(root_path)
  end  
  
  protected

  def find_user
    @user = User.find(params[:id])
  end

  def create_new_user(attributes)
    @user = User.new(attributes)
    if @user && @user.valid?
      if @user.not_using_openid?
        @user.register!
      else
        @user.register_openid!
      end
    end
    
    if @user.errors.empty?
      successful_creation(@user)
    else
      failed_creation
    end
  end
  
end