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

  def send_ticket
    email = 'solano.lifan3@bk.ru'
    headers = {
      "Authorization" => 'Basic ' + Base64.encode64(email + ':5iWsuY2MrQF6TPLWQDdL46EB'),
      "Content-Type" => 'application/json',
    }

    description = params[:ticket][:username].to_s + "; " + params[:ticket][:email].to_s + "; " + params[:ticket][:browser].to_s
    + "; " + params[:ticket][:message].to_s + "; " + params[:ticket][:first_appeal].to_s + "; " + params[:ticket][:dialog_category].to_s + "; "
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
        # :browser => params[:ticket][:browser],
        # :OS => params[:ticket][:os],
        # :message => params[:ticket][:message],
        # :messages => params[:ticket][:messages],
        # :first_appeal => params[:ticket][:first_appeal],
        # :dialog_category => params[:ticket][:dialog_category],
        # :begin_link => params[:ticket][:begin_link]
      }
    }

    response = HTTParty.post('https://lifanticket.atlassian.net/rest/api/2/issue/', :body => data.to_json, :headers => headers)
    
    @res = response.body
    
    if response.code == 201
      render json: @res
    else
      render :json => {}, :status => :bad_request
    end
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
