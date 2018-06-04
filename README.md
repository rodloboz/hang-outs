# hang-outs mock app

Rails app generated with [lewagon/rails-templates](https://github.com/lewagon/rails-templates), created by the [Le Wagon coding bootcamp](https://www.lewagon.com) team.

## Table of Contents

* [Getting started](#getting-started)
* [Following users](#following-users)
* [Mutual friendship](#mutual-friendship)


## Getting started

After cloning the app, create the db, run the migrations and seed.

```bash
$ rails db:create db:migrate db:seed
```

## Following users

We want to set up a system where users can follow other users, i.e., any user can be a follower and a followee.

We want to be able to call `@user.followers` to see the list of users who are following the `@user` and `@user.following` to see the list of users the `@user` is following.

Assuming we already have a User model, let's create the a Join Table conneting followers and followees.

```bash
$ rails g model Follow
````
Add this to the migration file

```ruby
class CreateFollows < ActiveRecord::Migration[5.2]
  def change
    create_table 'follows' do |t|
      t.integer 'following_id', null: false
      t.integer 'follower_id', null: false

      t.timestamps null: false
    end

    add_index :follows, :following_id
    add_index :follows, :follower_id
    add_index :follows, [:following_id, :follower_id], unique: true
  end
end
```
Run `rails db:migrate` and update your models with the following:

```ruby
class User < ApplicationRecord
  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following
end
```

And then add some custom methods to the User model to have a simpler way of following and unfollowing users and to check if a user is following another:

```ruby
  def follow(user_id)
    following_relationships.create(following_id: user_id)
  end

  def unfollow(user_id)
    following_relationships.find_by(following_id: user_id).destroy
  end

  def is_following?(user_id)
    relationship = Follow.find_by(follower_id: id, following_id: user_id)
    return true if relationship
  end
```

Let's add the routes for the actions in our UsersController:

```ruby
resources :users, only: [:index] do
    member do
      post :follow
      post :unfollow
    end
 end
 ```
 And the controller should look like this:

 ```ruby
 class UsersController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  before_action :set_user, only: [:follow, :unfollow]

  def index
    @users = User.all.where.not(id: current_user.id)
  end

  def follow
    if current_user.follow(@user.id)
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
    end
  end

  def unfollow
    if current_user.unfollow(@user.id)
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { render action: :follow }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
```

Finally, let's setup our views to render the list of users with the follow/unfollow button which is updated though AJAX:

```erb
<!-- users/_user.html.erb -->
<li data-user=<%= user.id %>>
  <%= user.full_name %>
  <% if current_user.is_following?(user.id) %>
    <%= link_to "Unfollow", unfollow_user_path(user.id), method: :post, remote: true %>
  <% else %>
    <%= link_to "Follow", follow_user_path(user.id), method: :post, remote: true %>
  <% end %>
</li>
```
And lastly set up the JS response for the follow/unfollow actions:

```javascript
// users/follow.js.erb
function renderUser(userHTML) {
  const user = document.querySelector("[data-user='<%= @user.id %>']");
  user.outerHTML = userHTML;
}

renderUser('<%= j render @user %>');
```

## Mutual friendship

We want to create a system that allows a user to send a friend request to another user. The latter user can either accept or reject the request. If they accept, a mutual friendship is created.

First, we’ll create FriendRequest model.

```bash
$ rails g model FriendRequest user:references friend:references
```
And update the migration file accordingly:
```ruby
class CreateFriendRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :friend_requests do |t|
      t.references :user, foreign_key: true
      t.integer :friend_id, null: false

      t.timestamps
    end

    add_index :friend_requests, :friend_id
    add_index :friend_requests, [:user_id, :friend_id], unique: true
  end
end
```
Then we add the `has_many :through` association between users:
```ruby
# app/models/user.rb:
class User < ActiveRecord::Base
  has_many :friend_requests, dependent: :destroy
  has_many :pending_friends, through: :friend_requests, source: :friend
end
```
Because the FriendRequest model has self-referential association, we have to specify the class name:
```ruby
class FriendRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User'
end
```
Now let's setup the FriendRequestsController:
```ruby
# app/controllers/friend_requests_controller.rb
class FriendRequestsController < ApplicationController
  before_action :set_friend_request, except: [:index, :create]
  before_action :set_user, except: [:index]

  def index
    @incoming = FriendRequest.where(friend: current_user)
    @outgoing = current_user.friend_requests
  end

  def create
    friend = User.find(params[:friend_id])
    @friend_request = current_user.friend_requests.new(friend: friend)

    if @friend_request.save
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
    end
  end

  def destroy
    @friend_request.destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js { render action: :create }
    end
  end

  private

  def set_friend_request
    @friend_request = FriendRequest.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id] || params[:friend_id])
  end
end
```
Add the following to `routes.rb`
```ruby
resources :friend_requests, only: [:index, :create, :destroy]
```
And setup our Users index to Send/Cancel friend requests with AJAX requests:
```erb
<!-- users/_user.html.erb -->
<li data-user=<%= user.id %>>
  <%= user.full_name %>
  <% if request = current_user.find_friend_request(user.id) %>
    <%= link_to "Cancel Friend Request", friend_request_path(request, user_id: user.id), method: :delete, remote: true %>
  <% else %>
    <%= link_to "Send Friend Request", friend_requests_path(friend_id: user.id), method: :post, remote: true %>
  <% end %>
</li>
```
And also setup our JS response:
```javascript
// friend_requests/create.js.erb
function renderUser(userHTML) {
  const user = document.querySelector("[data-user='<%= @user.id %>']");
  user.outerHTML = userHTML;
}

renderUser('<%= j render @user %>');
```
Now let’s move on to another join model: Friendship. We’ll be using this association to get and destroy friends.
```bash
$ rails g model Friendship user:references friend:references
```
Update the migration
```ruby
def change
    create_table :friendships do |t|
      t.references :user, index: true, foreign_key: true
      t.references :friend, index: true

      t.timestamps
    end

    add_foreign_key :friendships, :users, column: :friend_id
    add_index :friendships, [:user_id, :friend_id], unique: true
  end
```
Update the User model:
```ruby
class User < ApplicationRecord
  # [...]
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
 end
 ```
 And the Friendships model should look like this:
 ```ruby
 class Friendship < ApplicationRecord
  after_create :create_inverse_relationship, unless: :has_inverse_relationship?
  after_destroy :destroy_inverse_relationship

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  private

  def create_inverse_relationship
    friend.friendships.create(friend: user)
  end

  def destroy_inverse_relationship
    friendship = friend.friendships.find_by(friend: user)
    friendship.destroy if friendship
  end

  def has_inverse_relationship?
    self.class.exists?(inverse_friendship_options)
  end

  def inverse_friendship_options
    { friend_id: user_id, user_id: friend_id }
  end
end
```
You can find a more comprehensive implementation [here](https://dankim.io/mutual-friendship-rails/).
