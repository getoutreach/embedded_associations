class PostsController < ApplicationController
  prepend_before_filter :load_resource

  embedded_association :comments => {:user => :account}
  embedded_association :user => [:account]
  embedded_association [:tags]
  embedded_association :category

  attr_accessor :resource

  def create
    resource.update_attributes(params[:post])
    render json: resource
  end

  def update
    resource.update_attributes(params[:post])
    render json: resource
  end

  def destroy
    resource.destroy
    render nothing: true
  end

  protected

  def load_resource
    self.resource = @post = if params['action'] == 'create'
      Post.new
    else
      Post.find(params[:id])
    end
  end

  def resource_name
    'post'
  end

end
