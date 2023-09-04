class BookmarksController < ApplicationController
  def new; end

  def index
    @user = User.find(params[:user_id])
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
    if Book.find_by(isbn: params[:isbn]).nil?
      Book.create(isbn: params[:isbn])
    end
    @user = current_user
    @isbn = params[:isbn]
    @bookmarks = @user.bookmarks
    @bookmark = Bookmark.create(user_id: current_user.id, book_id: Book.find_by(isbn: params[:isbn]).id)
    @books = current_user.books
    render turbo_stream: turbo_stream.replace(
      "favorite-button-#{@isbn}",
      partial: 'shared/favorite_button',
      locals: { isbn: @isbn, favorited: true }
    )
  end

  def destroy
    @user = current_user
    @bookmark = Bookmark.where(book_id: Book.find_by(isbn: params[:isbn]).id, user_id: @user.id)
    @bookmark.first.destroy
    @books = current_user.books
    item = params[:item]
    @isbn = params[:isbn]
    @bookmarks = @user.bookmarks
    render turbo_stream: turbo_stream.replace(
      "favorite-button-#{@isbn}",
      partial: 'shared/favorite_button',
      locals: { isbn: @isbn, favorited: false }
    )
  end
end
