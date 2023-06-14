class BookmarksController < ApplicationController
    def new
    end
  
    def index
      @redirect = "bookmarks"
      @user = User.find(params[:user_id])
      @books = current_user.books
      @bookmarks = @user.bookmarks
      @user_books = []
      @user.books.each do |book|
        item = RakutenWebService::Books::Book.search(isbn: book.isbn)
        @user_books.push(item.first)
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
      elsif r.match(/search/)
        redirect_to items_search_path(item: item)
      else
        redirect_to user_bookmarks_url(user_id: params[:user])
      end
    end
  
    def destroy
      @bookmark = Bookmark.find(params[:id])
      @bookmark.destroy
      item = params[:item]
      r = params[:modoru]

      if r.match(/keysearch/)
       redirect_to items_keysearch_path(item: item)
      elsif r.match(/search/)
        redirect_to items_search_path(item: item)
      else
        redirect_to user_bookmarks_url(user_id: params[:user])
      end
    end
end
