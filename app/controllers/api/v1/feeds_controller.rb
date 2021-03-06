class Api::V1::FeedsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_format

  def group_all
    if params[:group_id] == 'home'
      @feed_items = current_user.readable(:posts) + current_user.readable(:books)
    else
      group = Group.find(params[:group_id])
      authorize! :read, group
      @feed_items = group.content
    end
    @feed_items.sort!{|a,b| a.created_at <=> b.created_at }.reverse!
  end
end