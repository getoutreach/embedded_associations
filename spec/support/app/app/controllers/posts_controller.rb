class PostsController < ApplicationController
  prepend_before_filter :load_resource

  embedded_association :comments => {:user => :account}
  embedded_association :user => [:account]
  embedded_association [:tags]
  embedded_association :category

  attr_accessor :resource

  def create
    params = post_params
    handle_embedded_associations(resource, params)
    if resource.update_attributes(params)
      render json: resource
    else
      render json: {}, status: 422
    end
  end

  def update
    params = post_params
    handle_embedded_associations(resource, params)
    if resource.update_attributes(params)
      render json: resource
    else
      render json: {}, status: 422
    end
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

  def post_params
    params.require(:post).permit(
      :title,
      comments: [:content, user: [:name, :email, account: [:note] ]],
      user: [:type, :name, :email, account: [:note] ],
      tags: [:id, :name],
      category: [:name]
    )
  end

end
