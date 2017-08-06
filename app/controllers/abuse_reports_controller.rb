class AbuseReportsController < ApplicationController
  skip_before_filter :store_location
  before_filter :load_abuse_languages

  def new
    @abuse_report = AbuseReport.new
    reporter = current_admin || current_user
    if reporter.present?
      @abuse_report.email = reporter.email
      @abuse_report.username = reporter.login
    end
    @abuse_report.url = params[:url] || request.env['HTTP_REFERER']
  end

  def create
    @abuse_report = AbuseReport.new(abuse_report_params)
    if @abuse_report.save
      @abuse_report.email_and_send
      flash[:notice] = ts('Your abuse report was sent to the Abuse team.')
      redirect_to ''
    else
      render action: 'new'
    end
  end

  def load_abuse_languages
    @abuse_languages = Language.where(abuse_support_available: true).order(
      :name
    )
  end

  private
  def abuse_report_params
    params.require(:abuse_report).permit(
      :username, :email, :ip_address, :language, :summary, :url, :comment
    )
  end
end
