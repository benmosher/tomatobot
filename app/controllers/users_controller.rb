class UsersController < ApplicationController
  before_action :load_user
  before_action :check_url_key, except: :update_token

  def edit 
  end

  def update
    @user.update(user_params)
    redirect_to edit_user_path(id: @user.id, key: @user.url_key), 
                alert: t("users.update.successful")
  end

  def update_token
    if params[:code].present?
      return notify_error if exchanged_token[:ok] == false
      @user.update(slack_token: exchanged_token[:access_token])
      redirect_to edit_user_path(id: @user.id, key: @user.url_key), 
                  alert: t("users.update_token.successful")
    else
      redirect_to edit_user_path(id: @user.id, key: @user.url_key), 
                  alert: t("users.update_token.no_code")
    end
  end

private

  def load_user
    @user = User.find(params[:id])
  end

  def check_url_key
    not_found_error unless @user.url_key == params["key"]
  end

  def exchanged_token
    @exchanged_token ||= SlackTokenExchanger.
                         new(params[:code]).
                         exchange(redirect_uri: token_redirect_uri).
                         symbolize_keys
  end

  def user_params
    params.require(:user).permit(:dnd_mode, :timezone)
  end

  def token_redirect_uri
    update_user_token_url(id: @user.id, key: @user.url_key)
  end

  def notify_error
    logger.warn "Token exchange failed for token: #{@exchanged_token}"
    redirect_to edit_user_path(key: @user.url_key), 
                alert: t("users.update_token.exchange_failed")
  end
end
