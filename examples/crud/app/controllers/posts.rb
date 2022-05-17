class Posts < YesController
  def index
    posts = Post.select(:latest, limit: 30)

    view = PostsIndex.new
    view.posts = posts

    view
  end

  def show
    view = PostsShow.new
    view.post = post

    view
  end

  def new
    @post ||= Post.new

    view = PostsNew.new
    view.post = post

    view
  end

  def create
    @post = Post.insert(post_params)

    if @post.saved?
      redirect :Posts, :index
    else
      new
    end
  end

  def edit
    view = PostsEdit.new
    view.post = post

    view
  end

  def update
    if post.update(post_params)
      redirect :Posts, :show, post
    else
      edit
    end
  end

  def delete
    post.delete

    redirect :Posts, :index
  end

  private

  def post_params
    params.slice(:title, :body)
  end

  def post
    @post ||= Post.first(:by_pk, params[:post_id])
  end
end
