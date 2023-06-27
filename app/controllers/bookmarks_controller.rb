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
      @user = current_user
      @isbn = params[:isbn]
      @bookmarks = @user.bookmarks
      @bookmark = Bookmark.create(user_id:current_user.id, book_id:Book.find_by(isbn: params[:isbn]).id)
      @books = current_user.books
      render turbo_stream: turbo_stream.replace("favorite-button-#{@isbn}", partial: 'shared/favorite_button', locals: { isbn: @isbn, favorited: true })
    end
    
    def destroy
      @user = current_user
      @bookmark = Bookmark.where(book_id: Book.find_by(isbn: params[:isbn]).id, user_id: @user.id)
      @bookmark.first.destroy
      @books = current_user.books
      item = params[:item]
      @isbn = params[:isbn]
      @bookmarks = @user.bookmarks
      render turbo_stream: turbo_stream.replace("favorite-button-#{@isbn}", partial: 'shared/favorite_button', locals: { isbn: @isbn,favorited: false })
    end
end
