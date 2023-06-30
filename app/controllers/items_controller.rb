class ItemsController < ApplicationController
  def index
      @item = RakutenWebService::Books::Book.search(booksGenreId: "001001001",title: "BLEACH")
    end
    def search
      if current_user.present?
        @redirect = "search"
        @bookmarks = Bookmark.where(user_id: current_user.id)
        @books = current_user.books
      end
      if params[:publisher].present? || params[:genre].present?
        genre_list = {
          "漫画全般" => "001001",
          "少年" => "001001001",
          "少女" => "001001002",
          "青年" => "001001003",
          "レディース" => "001001004",
          "文庫" => "001001005",
          "その他" => "001001006"
        }
        sort = ["standard","reviewAverage"].sample
        query = { booksGenreId: "001001", sort: sort,elements: "title,isbn,booksGenreId,reviewCount,publisherName"}
        query[:publisherName] = params[:publisher] if params[:publisher].present?
        query[:booksGenreId] = genre_list[params[:genre]] if params[:genre].present?
        @itemss = RakutenWebService::Books::Book.search(query)
        @hantei = []
        @item = []
        idx = 0
        if @itemss.page(100).response['Items'] != nil 
          a_max = 100
        elsif @itemss.page(50).response['Items'] != nil
          a_max = 50
        elsif @itemss.page(20).response['Items'] != nil
          a_max = 20
        elsif @itemss.page(5).response['Items'] != nil
          a_max = 5
        elsif @itemss.page(4).response['Items'] != nil
          a_max = 4
        elsif @itemss.page(3).response['Items'] != nil
          a_max = 3
        elsif @itemss.page(2).response['Items'] != nil
          a_max = 2
        else
          a_max = 1
        end
        while @item.count < 3 && idx <= 50
          a = rand(1..a_max)
          items = @itemss.page(a)
          break if items.response['Items'].blank?
          @flag = 3
          item = items.to_a.sample
          next if item.blank?
          p item.title
          janl(item)
          aitem = nil
          trial(item)
          if @flag == 1
            p "削除"
            next
          elsif @flag == 3
            p "ノイズ"
            next
          else
            p "通し"
          end
    
          @item << item
          idx += 1
        end
        @resultitems = []
        @item.map!{|v|  v = v.isbn} 
        @item.each do |itemb|
          url = "https://api.openbd.jp/v1/get?isbn=%20#{itemb}"
          uri = URI(url)
          response = Net::HTTP.get(uri)
          data = JSON.parse(response)
          if data[0] == nil
            p "openbd済まぬ"
            item = RakutenWebService::Books::Book.search(isbn: itemb)
            @resultitems.push(item.first.isbn)
            @resultitems.push(item.first.title)
            @resultitems.push(item.first.author)
            @resultitems.push(item.first.large_image_url)
            @resultitems.push(item.first.publisher_name)
          else
            @resultitems.push(data[0].values_at("summary")[0].values_at("isbn")[0])
            @resultitems.push(data[0].values_at("summary")[0].values_at("title")[0])
            @resultitems.push(data[0].values_at("summary")[0].values_at("author")[0])
            @resultitems.push(data[0].values_at("summary")[0].values_at("cover")[0])
            @resultitems.push(data[0].values_at("summary")[0].values_at("publisher")[0])
          end
        end 
      end
    end #def
  
    def keysearch
      if current_user.present?
        @redirect = "keysearch"
        @bookmarks = Bookmark.where(user_id: current_user.id)
        @books = current_user.books
      end
      @item_reborn = params[:item]
      if params[:keyword] && params[:keyword].size != 0
        @itema = []
        genre_list = {"少年" => "001001001","少女" => "001001002", "青年" => "001001003", "レディース" => "001001004","文庫" => "001001005", "その他" => "001001006"}
        if params[:genre] == nil
          genre = "001001"
        else
          genre = genre_list[params[:genre]]
        end
        #flag = 0
        #while flag == 0 do
        @hantei = []
        @item = []
        if params[:page].present?
          page = params[:page]
        else
          page = 1
        end
        @itemss = RakutenWebService::Books::Total.search(booksGenreId: genre,keyword: params[:keyword])
        if @itemss.page(1).count == 0
          p "ないです"
          redirect_to items_keysearch_path
        end
        idx = 1
        rejected = []
        selected = []
        while @itemss.page(idx).count > 0 do
        @idx_items = @itemss.page(idx).sort_by{|v| v.title}
        if rejected.count > 0
          rejected.each do |s|
            @idx_items.reject!{|v| /#{s}/ === v.title }
          end
        end
        @idx_items.each do |item|
        p item.title
        @flag = 3
          #rejected.each do |s|
           # if /#{s}/ === i.title
             # flag = 1
            #end
            #if flag == 1
             # break
            #end
          #end
          janl(item)
          trial(item)
          if @flag == 1
            rejected.push(@book_series)
            @idx_items.reject!{|v| v.title.include?(@book_series) }
            p "削除"
          elsif @flag == 0
            selected.push(@book_series)
            @itema.concat(@idx_items.select{|v| /#{@book_series}/ === v.title})
            @idx_items.reject!{|v| v.title.include?(@book_series) }
            p "合格"
          else
            p "ノイズ"
          end  
        end 
        idx += 1
        #p rejected
        #p selected
        end # while 
        @resultitems = []
        @itema.map!{|v|  v = v.isbn} 
          @itema.each do |itemb|
            url = "https://api.openbd.jp/v1/get?isbn=%20#{itemb}"
            uri = URI(url)
            response = Net::HTTP.get(uri)
            data = JSON.parse(response)
            if data[0] == nil
              p "openbd済まぬ"
              item = RakutenWebService::Books::Book.search(isbn: itemb)
              @resultitems.push(item.first.isbn)
              @resultitems.push(item.first.title)
              @resultitems.push(item.first.author)
              @resultitems.push(item.first.large_image_url)
              @resultitems.push(item.first.publisher_name)
            else
              @resultitems.push(data[0].values_at("summary")[0].values_at("isbn")[0])
              @resultitems.push(data[0].values_at("summary")[0].values_at("title")[0])
              @resultitems.push(data[0].values_at("summary")[0].values_at("author")[0])
              @resultitems.push(data[0].values_at("summary")[0].values_at("cover")[0])
              @resultitems.push(data[0].values_at("summary")[0].values_at("publisher")[0])
            end
          end 
      end # if
      #if @itema.present?
       # @item_dummy = @itema.map do |i|
        #  [i.isbn]
        #end
      #end

    end
    private

    def trial(item)
      if /\d+$/ === item.title || /[\(\（]　*\d+[\)\）]$/ === item.title || /[\(\（]　*\d+[\)\）]/ === item.title
        aitem = RakutenWebService::Books::Total.search(keyword: $`, outOfStockFlag: 1, booksGenreId: "001001")
      end
      @book_series = $`
      if aitem.present?
        if aitem.page(2).count > 9
          @flag = 1
        elsif aitem.page(1).count > 9
          @flag = 0
        else
          @flag = 1
        end
        if @flag == 0 && aitem.detect { |i| i.review_count >= 50 }
          @flag = 1
        end
      end
    end
    
    def janl(i)
     if i.books_genre_id.index("/") != nil
      @books_genre_id = i.books_genre_id.slice(0...i.books_genre_id.index("/"))
     else
      @books_genre_id = i.books_genre_id
     end
    end
end
