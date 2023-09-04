class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def index
    if params[:keyword].present?
      # @users = User.where(name: params[:keyword])
      keyword = params[:keyword].downcase
      @users = User.where("LOWER(name) LIKE ?", "%#{keyword}%")
    end
  end

  def show
    @user = User.find(params[:id])
    @books = current_user.books
    @bookmarks = @user.bookmarks
    @user_books = []
    @user.books.each do |book|
      url = "https://api.openbd.jp/v1/get?isbn=%20#{book.isbn}"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      if data[0].nil? || data[0].values_at('summary')[0].values_at('cover')[0].size == 0
        item = RakutenWebService::Books::Book.search(isbn: book.isbn)
        @user_books.push(item.first.isbn)
        @user_books.push(item.first.title)
        @user_books.push(item.first.author)
        @user_books.push(item.first.large_image_url)
        @user_books.push(item.first.publisher_name)
      else
        @user_books.push(data[0].values_at('summary')[0].values_at('isbn')[0])
        @user_books.push(data[0].values_at('summary')[0].values_at('title')[0])
        @user_books.push(data[0].values_at('summary')[0].values_at('author')[0])
        @user_books.push(data[0].values_at('summary')[0].values_at('cover')[0])
        @user_books.push(data[0].values_at('summary')[0].values_at('publisher')[0])
      end
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end
end
