class BookmarksController < ApplicationController
  def new
  end

  def index
    @user = User.find(params[:user_id])
    @bookmarks = @user.bookmarks
    @books = []
    @user.books.each do |book|
      item = RakutenWebService::Books::Book.search(isbn: book.isbn)
      @books.push(item.first)
    end
  end

  def create
    if Book.find_by(isbn: params[:isbn]) == nil
      Book.create(isbn: params[:isbn])
    end
    Bookmark.create(user_id:current_user.id, book_id:Book.find_by(isbn: params[:isbn]).id)
    item = params[:item]
    r = params[:modoru]

    if r.match(/keysearch/)
     redirect_to items_keysearch_path(item: item)
    else
      redirect_to items_search_path(item: item)
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy
    item = params[:item]
    r = params[:modoru]

    if r.match(/keysearch/)
     redirect_to items_keysearch_path(item: item)
    else
      redirect_to items_search_path(item: item)
    end
  end
end
