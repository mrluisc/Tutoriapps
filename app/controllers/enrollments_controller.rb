class EnrollmentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @group = Group.find(params[:group_id])
    authorize! :manage, @group
    enrollment = @group.enrollments.build(params[:enrollment])
    if enrollment.save
      redirect_to root_path, :notice => I18n.t('helpers.messages.added', 
        :model => I18n.t('activerecord.models.user'))
    else
    end
  end
end