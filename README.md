# EmbeddedAssociations

Provides ActionController-level support for embedded associations in Rails. Use cases include:

* Being able to easily consume embedded records serialized from [Active Model Serializers](https://github.com/rails-api/active_model_serializers).
* Simplifying REST API implementations.

## Installation

Add this line to your application's Gemfile:

    gem 'embedded_associations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install embedded_associations

## Usage

Embedded Associations provides an `embedded_association` macro to ActionController:

```ruby
class PostsController < ApplicationController
  embedded_association :tags
  embedded_association :comments => :user
end
```

Inside of your controllers actions, the `handle_embedded_associations` method should be called:

```ruby
def create
  params = params.require(:post).permit(:title, tags: [:name], comments: [:title, user: [:username]])
  post = Post.new
  handle_embedded_associations(post, params)
  post.update_attributes(params)
  render json: post
end
```

Behind the scenes, this will make the controller parse out sub-params passed in and perform the necessary ActiveRecord model manipulation. E.g., consider the params hash below:

```ruby
{
  post: {
    tags: ['rest', 'ember-data'],
    comments: [
      {user: {name: 'Gordon'}}
    ]
  }
}
```

Based on the declared `embedded_association`s, the controller will manipulate the `tags` and `comments` association to reflect the passed in params (including deleting or creating child records).

### Controller and Model Pre-Requisites

When defining the relationships in the model, it is important to set the `autosave` and `dependent` options on the association:

```ruby
class Post < ActiveRecord::Base
  has_many :comments, autosave: true, dependent: :destroy
  has_many :tags, autosave: true, dependent: :destroy
end
```

### Strong Parameters

As might be expected, embedded associations must have their attributes permitted via the strong parameters api. For instance, a controller with the following embedded associates configuration:

```ruby
embedded_association :comments => {:user => :account}
embedded_association :user => [:account]
embedded_association [:tags]
embedded_association :category
```

The attributes of the embedded associations must be explicitly permitted:

```ruby
params.require(:post).permit(
  :title,
  comments: [:content, user: [:name, :email, account: [:note] ]],
  user: [:name, :email, account: [:note] ],
  tags: [:name],
  category: [:name]
)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
