#coding: utf-8
require 'spec_helper'

describe "Feed V1 API" do
  before(:all) do
    @users = {
      :fulano => FactoryGirl.create(:user),
      :mengano => FactoryGirl.create(:user)
    }
    @users.each do |index, user|
      user.confirmed_at = Time.now
      user.save!
      user.reset_authentication_token!
      user.reload
    end
    @groups = {
      :fisica => FactoryGirl.create(:group, :name => 'Física'),
      :calculo => FactoryGirl.create(:group, :name => 'Cálculo')
    }

    @groups[:fisica].members << @users[:fulano]
    @groups[:fisica].members << @users[:mengano]
    @groups[:calculo].members << @users[:fulano]

    3.times do
      FactoryGirl.create(:post, :group => @groups[:fisica])
      FactoryGirl.create(:book, :group => @groups[:fisica])
      FactoryGirl.create(:board_pic, :group => @groups[:fisica])
    end

    @headers = {'HTTP_ACCEPT' => 'application/json'}
  end

  describe "GET /api/v1/groups/:group_id/all" do

    describe "on success" do
      before(:all) do
        token = @users[:fulano].authentication_token
        url = "/api/v1/groups/#{@groups[:fisica].id}/all?auth_token=#{token}"
        get url, nil, @headers
        @status = response.status
        @data = JSON.parse(response.body)
      end
      it "returns status code 200 (OK)" do
        @status.should eq(200)
      end
      it "returns a JSON array with all of the group's objects (posts, board_pics, and books)" do
        @data.class.should eq(Array)
        @data.length.should eq(@groups[:fisica].content.count)
      end
      it "group's objects are ordered by creation date, with last created appearing first" do
        last_created_at = @data.first['data']['created_at']
        for object in @data
          object['data']['created_at'].should be <= last_created_at
          last_created_at = object['data']['created_at']
        end
      end
      it "every object in the array has a property 'type' which is either 'post', 'board_pic', or 'book'" do
        for object in @data
          object["type"].should be_true
          %w[post board_pic book].include?(object["type"]).should be_true
        end
      end
      it "every object in the array has a property 'data' which contains all data for the current object" do
        for object in @data
          object["data"].should be_true
          object["data"]["id"].should be_true
          object["data"]["created_at"].should be_true
          case object["type"]
          when "post"
            object["data"]["text"].should be_true
          when "board_pic"
            object["data"]["image"].should be_true
          when "book"
            object["data"]["title"].should be_true
          end
        end
      end
    end

    describe "when auth token is not valid or was not sent" do
      before(:all) do
        url = "/api/v1/groups/#{@groups[:fisica].id}/all?auth_token=wrong"
        get url, nil, @headers
        @status1 = response.status
        @data1 = JSON.parse(response.body)
        url = "/api/v1/groups/#{@groups[:fisica].id}/all"
        get url, nil, @headers
        @status2 = response.status
        @data2 = JSON.parse(response.body)
      end
      it "returns status code 401 (Unauthorized)" do
        @status1.should eq(401)
        @status2.should eq(401)
      end
      it "does not return the group's objects" do
        @data1.class.should_not eq(Array)
        @data2.class.should_not eq(Array)
      end
    end

    describe "when user is not member of the group" do
      before(:all) do
        group = @groups[:calculo]
        user = @users[:mengano]
        group.members.exists?(user).should be_false
        token = user.authentication_token
        url = "/api/v1/groups/#{group.id}/all?auth_token=#{token}"
        get url, nil, @headers
        @status = response.status
      end
      it "returns status code 403 (Forbidden)" do
        @status.should eq(403)
      end
      it "does not return the group's objects" do
        @data.class.should_not eq(Array)
      end
    end

    describe "when the group doesn't exist" do
      before(:all) do
        token = @users[:fulano].authentication_token
        url = "/api/v1/groups/unexistent/all?auth_token=#{token}"
        get url, nil, @headers
        @status = response.status
      end
      it "returns status code 404 (Not Found)" do
        @status.should eq(404)
      end
    end

    describe "when group has no objects" do
      before(:all) do
        group = @groups[:calculo]
        group.content.count.should eq(0)
        token = @users[:fulano].authentication_token
        url = "/api/v1/groups/#{group.id}/all?auth_token=#{token}"
        get url, nil, @headers
        @status = response.status
        @data = JSON.parse(response.body)
      end
      it "returns status code 200 (OK)" do
        @status.should eq(200)
      end
      it "returns a JSON empty array" do
        @data.should eq([])
      end
    end

    describe "when request format is not set to JSON" do
      before(:all) do
        headers = @headers.clone
        headers['HTTP_ACCEPT'] = 'text/html'
        token = @users[:fulano].authentication_token
        url = "/api/v1/groups/#{@groups[:fisica].id}/all?auth_token=#{token}"
        get url, nil, headers
        @status = response.status
      end
      it "returns status code 406 (Not Acceptable)" do
        @status.should eq(406)
      end
      it "does not return the group's objects" do
        @data.class.should_not eq(Array)
      end
    end
  end
end