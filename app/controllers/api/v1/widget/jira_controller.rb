require 'httparty'
require 'jira-ruby'
require 'base64'

class Api::V1::Widget::JiraController < ApplicationController
  protect_from_forgery with: :null_session

  def get_project
    host_url = ENV.fetch('JIRA_HOST_URL', '')
    email = ENV.fetch('JIRA_USERNAME', '')
    token = ENV.fetch('JIRA_API_TOKEN', '')
    headers = {
      "Authorization" => 'Basic ' + Base64.encode64(email + ':' + token),
      "Accept" => 'application/json',
      "ContentType" => 'application/json',
    }

    data = {
      
    }

    response = HTTParty.get(host_url + '/rest/api/2/project', :query => data, :headers => headers)

    @res = response.body

    render json: @res
  end

  def send_ticket
    host_url = ENV['JIRA_HOST_URL']
    email = ENV['JIRA_USERNAME']
    token = ENV['JIRA_API_TOKEN']
    headers = {
      "Authorization" => 'Basic ' + Base64.encode64(email + ':' + token),
      "Content-Type" => 'application/json',
    }

    sender_email = params[:ticket][:email].to_s
    
    if sender_email.empty?
      sender_email = params[:ticket][:username].to_s
    end

    # getting a dialog history
    dialog = ""
    
    params[:ticket][:messages]["messages"].each do |msg|
      if msg["message_type"] == 0 || msg["message_type"] == 1
        sender = msg["sender"]["name"]
        dialog += sender + " | " + Time.at(msg["created_at"]).to_datetime.strftime("%b %d %r") + "\n" + msg["content"] + "\n"
      end
    end

    description = "Chatwoot ID - " + params[:ticket][:username].to_s + ";\n Email - " + sender_email + ";\n Браузер - " + \
    + params[:ticket][:browser].to_s + ";\n Сообщение - " + params[:ticket][:message].to_s + ";\n Начато в - " + \
    + params[:ticket][:first_appeal].to_s + ";\n Категория диалога - " + params[:ticket][:dialog_category].to_s + \
    + ";\n Начато из - " + params[:ticket][:begin_link].to_s + ";\n Диалог:\n " + dialog
    
    data = {
      :fields => {
        :project => {
          # Project key can be obtained via get_project controller action above
          :key => params[:ticket][:projectKey]
        },
        :summary => sender_email,
        :description => description,
        :issuetype => {
          # You need to create issue type on your Jira project, e.g. Task
          :name => "Bug"
        }
        # Custom fields (if created)
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

    response = HTTParty.post(host_url + '/rest/api/2/issue/', :body => data.to_json, :headers => headers)
    
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
        :messages,
        :first_appeal,
        :dialog_category,
        :begin_link,
        :projectKey,
      )
    end
end
