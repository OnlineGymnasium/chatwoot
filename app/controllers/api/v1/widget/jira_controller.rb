require 'httparty'
require 'jira-ruby'
require 'base64'

class Api::V1::Widget::JiraController < ApplicationController
  protect_from_forgery with: :null_session

  def get_project
    email = 'solano.lifan3@bk.ru'
    headers = {
      "Authorization" => 'Basic ' + Base64.encode64(email + ':5iWsuY2MrQF6TPLWQDdL46EB'),
      "Accept" => 'application/json',
      "ContentType" => 'application/json',
    }

    data = {
      
    }

    response = HTTParty.get('https://lifanticket.atlassian.net/rest/api/2/project', :query => data, :headers => headers)

    @res = response.body

    render json: @res
  end

  def get_operating_system(user_agent)
    if request.env['HTTP_USER_AGENT'].downcase.match(/mac/i)
      return "Mac"
    elsif request.env['HTTP_USER_AGENT'].downcase.match(/windows/i)
      return "Windows"
    elsif request.env['HTTP_USER_AGENT'].downcase.match(/linux/i)
      return "Linux"
    elsif request.env['HTTP_USER_AGENT'].downcase.match(/unix/i)
      return "Unix"
    else
      return "Unknown"
    end
  end

  def send_ticket
    email = 'solano.lifan3@bk.ru'
    headers = {
      "Authorization" => 'Basic ' + Base64.encode64(email + ':5iWsuY2MrQF6TPLWQDdL46EB'),
      "Content-Type" => 'application/json',
    }

    browser = request.headers['HTTP_USER_AGENT']

    description = params[:ticket][:username].to_s + "; " + params[:ticket][:email].to_s + "; " + browser + "; " + self.get_operating_system(browser)
    + "; " + params[:ticket][:message].to_s + "; " + params[:ticket][:first_appeal_date].to_s + "; " + params[:ticket][:dialog_category].to_s + "; "
    + params[:ticket][:begin_link].to_s
    
    data = {
      :fields => {
        :project => {
          :key => params[:ticket][:projectKey]
        },
        :summary => "REST ye merry gentlemen.",
        :description => description,
        :issuetype => {
          :name => "Task"
        }
        # :username => params[:ticket][:username],
        # :email => params[:ticket][:email],
        # :browser => browser,
        # :OS => self.get_operating_system(browser),
        # :message => params[:ticket][:message],
        # :first_appeal_date => params[:ticket][:first_appeal_date],
        # :dialog_category => params[:ticket][:dialog_category],
        # :begin_link => params[:ticket][:begin_link]
      }
    }

    response = HTTParty.post('https://lifanticket.atlassian.net/rest/api/2/issue/', :body => data.to_json, :headers => headers)
    
    @res = response.body
    
    render json: @res
  end
  
  private
    def ticket_params
      params.require(:ticket).permit(
        :email,
        :username,
        :browser,
        :os,
        :message,
        :first_appeal,
        :dialog_category,
        :begin_link,
        :projectKey,
      )
    end
end
