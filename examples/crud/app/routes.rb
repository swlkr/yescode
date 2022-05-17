class Routes < YesRoutes
  resource "/posts", :Posts
  resource "/posts/:post_id/comments", :Comments
  get "/", :Posts, :index
end
