require 'spec_helper'

describe PostsController, type: :controller do
  include SerializationHelpers

  describe "embedded has_many" do

    context "creating" do

      it "should create child records" do
        json = post :create, post: {
          title: 'ma post',
          tags: [{},{}]
        }

        expect(Post.count).to eq(1)
        expect(Tag.count).to eq(2)

        Tag.all.each{ |t| expect(t.post).to_not be_nil }
      end

    end

    context "updating" do

      let(:tags) {[Tag.create, Tag.create]}
      let(:resource) { Post.create(tags: tags) }
      let(:hash) { serialize(resource) }

      it "should create new child records" do
        hash[:tags] += [{},{}]
        json = post :update, :id => resource.id, post: hash

        expect(Post.count).to eq(1)
        expect(Tag.count).to eq(4)

        Tag.all.each{ |t| expect(t.post).to_not be_nil }
      end

      it "should destroy missing child records" do
        hash[:tags] = hash[:tags].take(1)
        json = post :update, :id => resource.id, post: hash

        expect(Post.count).to eq(1)
        expect(Tag.count).to eq(1)

        Tag.all.each{ |t| expect(t.post).to_not be_nil }
      end
      
      it "should not destory if entire field missing" do
        hash.delete(:tags)
        json = post :update, :id => resource.id, post: hash

        expect(Post.count).to eq(1)
        expect(Tag.count).to eq(2)

        Tag.all.each{ |t| expect(t.post).to_not be_nil }
      end

      it "should update modified child records" do
        hash[:tags].first[:name] = 'modified'
        json = post :update, :id => resource.id, post: hash

        expect(Post.count).to eq(1)
        expect(Tag.count).to eq(2)

        expect(Tag.first.name).to eq('modified')

        Tag.all.each{ |t| expect(t.post).to_not be_nil }
      end

      it "should ignore missing child records" do
        hash[:tags].first[:name] = "modified"
        hash[:tags] += [{ id: 0, name: "foo" }]
        json = post :update, :id => resource.id, post: hash

        expect(json.response_code).to eq(200)
        expect(Post.count).to eq(1)
        expect(Tag.count).to eq(2)

        expect(Tag.first.name).to eq("modified")
      end
    end
  end

  describe "embedded belongs_to" do

    context "creating" do

      it "should create child record" do
        json = post :create, post: {
          title: 'ma post',
          category: {name: 'ember-data'}
        }

        expect(Post.count).to eq(1)
        expect(Category.count).to eq(1)

        resource = Post.first

        expect(resource.category).to_not be_nil
      end

    end

    context "updating" do

      let(:resource) { Post.create }
      let(:hash) { serialize(resource) }

      it "should create new child record" do
        hash[:category] = {name: 'ember'}
        json = post :update, :id => resource.id, post: hash

        expect(Post.count).to eq(1)
        expect(Category.count).to eq(1)

        resource.reload

        expect(resource.category).to_not be_nil
      end

      context do

        let(:resource) { Post.create(category: Category.create(name: 'ember')) }

        it "should destroy blank child record" do
          hash[:category] = ''
          json = post :update, :id => resource.id, post: hash

          expect(Post.count).to eq(1)
          expect(Category.count).to eq(0)

          resource.reload

          expect(resource.category).to be_nil
        end
        
        it "should not destroy missing child field" do
          hash.delete(:category)
          json = post :update, :id => resource.id, post: hash

          expect(Post.count).to eq(1)
          expect(Category.count).to eq(1)
        end

        it "should update modified child records" do
          hash[:category][:name] = 'ember-data'
          json = post :update, :id => resource.id, post: hash

          resource.reload

          expect(resource.category.name).to eq('ember-data')
        end

      end
    end

  end

  describe "embedded belongs_to -> has_one" do

    context "creating" do

      it "should create hierarchy" do
        json = post :create, post: {
          title: 'ma post',
          user: {name: 'G$', account: {}}
        }

        expect(Post.count).to eq(1)
        expect(User.count).to eq(1)
        expect(Account.count).to eq(1)

        resource = Post.first

        expect(resource.user).to_not be_nil
        expect(resource.user.account).to_not be_nil
      end

    end
    
    context "creating with sti belongs_to" do

      it "should create hierarchy" do
        json = post :create, post: {
          title: 'ma post',
          user: {type: 'Admin', name: 'G$', account: {}}
        }
        
        parsed_body = JSON.parse(response.body)
        expect(parsed_body['post']['user']['type']).to eq('Admin')

        expect(Post.count).to eq(1)
        expect(User.count).to eq(1)
        expect(Account.count).to eq(1)

        resource = Post.first

        expect(resource.user).to_not be_nil
        expect(resource.user.account).to_not be_nil
      end

    end

    context "updating" do

      let(:resource) { Post.create }
      let(:hash) { serialize(resource) }

      it "should create new hierarchy" do
        hash[:user] = {name: 'G$', account: {}}
        json = post :update, :id => resource.id, post: hash

        expect(User.count).to eq(1)
        expect(Account.count).to eq(1)

        resource.reload

        expect(resource.user).to_not be_nil
        expect(resource.user.account)
      end

      context do

        let(:resource) { Post.create({user: User.create({name: 'G$', account: Account.create})}) }

        it "should destroy blank child hierarchy" do
          hash[:user] = ''
          json = post :update, :id => resource.id, post: hash

          expect(Post.count).to eq(1)
          expect(User.count).to eq(0)
          expect(Account.count).to eq(0)

          resource.reload

          expect(resource.user).to be_nil
        end

        it "should destroy blank grand-child" do
          hash[:user] = {name: 'G$', account: ''}
          json = post :update, :id => resource.id, post: hash

          expect(Post.count).to eq(1)
          expect(User.count).to eq(1)
          expect(Account.count).to eq(0)

          resource.reload

          expect(resource.user.account).to be_nil
        end
        
        it "should not destroy missing grand-child" do
          hash[:user] = {name: 'G$'}
          json = post :update, :id => resource.id, post: hash

          expect(Post.count).to eq(1)
          expect(User.count).to eq(1)
          expect(Account.count).to eq(1)
        end


        it "should update modified child records" do
          hash[:user][:name] = 'wes'
          hash[:user][:account][:note] = 'test'
          json = post :update, :id => resource.id, post: hash

          resource.reload

          expect(resource.user.name).to eq('wes')
          expect(resource.user.account.note).to eq('test')
        end

        it "should update modified grand-child" do
          hash[:user][:account][:note] = 'test'
          json = post :update, :id => resource.id, post: hash

          resource.reload

          expect(resource.user.account.note).to eq('test')
        end

      end

    end

  end

  describe "embedded has_many -> belongs_to -> has_one" do

    context "creating" do

      it "should create hierarchy" do
        json = post :create, post: {
          title: 'ma post',
          comments: [{user: {name: 'G$', account: {}}}]
        }

        expect(Post.count).to eq(1)
        expect(Comment.count).to eq(1)
        expect(User.count).to eq(1)
        expect(Account.count).to eq(1)

        resource = Post.first

        expect(resource.comments).to_not be_empty
        expect(resource.comments.first.user).to_not be_nil
        expect(resource.comments.first.user.account).to_not be_nil
      end

    end

    context "updating" do

      let(:resource) { Post.create }
      let(:hash) { serialize(resource) }

      it "should create new hierarchy" do
        hash[:comments] = [{user: {name: 'G$', account: {}}}]
        json = post :update, :id => resource.id, post: hash

        expect(Comment.count).to eq(1)
        expect(User.count).to eq(1)
        expect(Account.count).to eq(1)

        resource.reload

        expect(resource.comments).to_not be_empty
        expect(resource.comments.first.user).to_not be_nil
        expect(resource.comments.first.user.account).to_not be_nil
      end

      context do

        let(:resource) {
          p = Post.create
          c = p.comments.create
          u = c.create_user({account: Account.create})
          c.save
          p
        }

        it "should destroy blank child hierarchy" do
          hash[:comments] = []
          hash[:user] = ''
          json = post :update, :id => resource.id, post: hash

          expect(Post.count).to eq(1)
          expect(Comment.count).to eq(0)
          expect(User.count).to eq(0)
          expect(Account.count).to eq(0)

          resource.reload

          expect(resource.comments).to be_empty
        end

        it "should destroy blank grand-child hierarchy" do
          hash[:comments].first[:user] = ''
          json = post :update, :id => resource.id, post: hash

          expect(Post.count).to eq(1)
          expect(Comment.count).to eq(1)
          expect(User.count).to eq(0)
          expect(Account.count).to eq(0)

          resource.reload

          expect(resource.comments.first.user).to be_nil
        end

        it "should update modified child records" do
          hash[:comments].first[:user][:name] = 'wes'
          hash[:comments].first[:user][:account][:note] = 'test'
          json = post :update, :id => resource.id, post: hash

          resource.reload

          expect(resource.comments.first.user.name).to eq('wes')
          expect(resource.comments.first.user.account.note).to eq('test')
        end

      end

    end

  end

end
