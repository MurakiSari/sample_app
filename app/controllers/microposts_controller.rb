class MicropostsController < ApplicationController
  before_action :user_should_have_logged_in, only: %i(create destroy)
  before_action :set_micropost, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost&.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end

  def set_micropost
    @micropost = current_user.microposts.find_by(id: params[:id])

  rescue ActiveRecord::RecordNotFound => e
    redirect_back(fallback_location: root_path, danger: e.message)
  end
end
