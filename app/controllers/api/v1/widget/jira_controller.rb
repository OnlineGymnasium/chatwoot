require 'httparty'
require 'jira-ruby'
require 'base64'

class Api::V1::Widget::JiraController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  # window.addEventListener('chatwoot:ready', function () {
  #   user = {
  #     email: 'test2@mail.com',
  #     name: 'testuser2',
  #     userLink: "http://link_to.com"
  #   }

  #   window.$chatwoot.setUser('',
  #   { email: user.email,  name: user.name });

  #   if (user.userLink && user.userLink.length !== 0) {
  #     window.$chatwoot.setCustomAttributes({
  #       userLink: user.userLink
  #     });
  #   };
  #  
  # let userHistory = localStorage.getItem('userHistory');

  # if (userHistory != undefined && userHistory != null && userHistory != '') {
  #   window.$chatwoot.setCustomAttributes({
  #     userHistory: userHistory
  #   });
  # }
  # });

  def get_project
    host_url = ENV.fetch('JIRA_ORGANIZATION_URL', '')
    email = ENV.fetch('JIRA_USERNAME', '')
    token = ENV.fetch('JIRA_API_TOKEN', '')
    headers = {
      "Authorization" => 'Basic ' + Base64.strict_encode64(email + ':' + token),
      "Accept" => 'application/json',
      "ContentType" => 'application/json',
    }

    data = {}

    response = HTTParty.get(host_url + '/rest/api/2/project', :query => data, :headers => headers)

    @res = response.body

    render json: @res
  end

  def send_ticket
    host_url = ENV['JIRA_ORGANIZATION_URL']
    email = ENV['JIRA_USERNAME']
    token = ENV['JIRA_API_TOKEN']
    headers = {
      "Authorization" => 'Basic ' + Base64.strict_encode64(email + ':' + token),
      "Content-Type" => 'application/json',
    }

    sender_email = params[:ticket][:email].to_s

    if sender_email.empty?
      sender_email = params[:ticket][:username].to_s
    end

    link_to_dialog = params[:ticket][:link_to_dialog]
    specialist = params[:ticket][:specialist]

    description = "Chatwoot ID - " + params[:ticket][:username].to_s + ";\n Email - " + sender_email + ";\n Browser - " + \
    + params[:ticket][:browser].to_s + ";\n Message - " + params[:ticket][:message].to_s + ";\n Initiated at - " + \
    + params[:ticket][:first_appeal].to_s + ";\n Dialog category - " + params[:ticket][:dialog_category].to_s + \
    + ";\n Initiated from - " + params[:ticket][:begin_link].to_s + ";\n Link to dialog - " + link_to_dialog + "\n\n Specialist - " + specialist

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
