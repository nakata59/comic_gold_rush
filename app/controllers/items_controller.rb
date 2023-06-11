class ItemsController < ApplicationController
    def index
        @item = RakutenWebService::Books::Book.search(booksGenreId: "001001001",title: "BLEACH")
      end
      def search
        @item_reborn = params[:item]
         if params[:publisher].present? || params[:genre].present?
          genre_list = {"漫画全般" => "001001","少年" => "001001001","少女" => "001001002", "青年" => "001001003", "レディース" => "001001004","文庫" => "001001005", "その他" => "001001006"}
           #flag = 0
          #while flag == 0 do
          sort = ["standard","+releaseDate","-releaseDate"].sample
          query = {:booksGenreId => "001001",sort: sort}
          if params[:publisher].present? && RakutenWebService::Books::Book.search(publisherName: params[:publisher],Hits: 5).count != 0
            query[:publisherName] = params[:publisher]
          end
          if params[:genre].present?
            query[:booksGenreId] = genre_list[params[:genre]]
          end
          @itemss = RakutenWebService::Books::Book.search(query)
          @hantei = []
          @item = []
          idx = 0 
          while @item.count < 3 do
          #3.times do
          r = (1..100)   
          flag = 3
          if @itemss.page(100).count >= 30
            a_max = 100
          elsif @itemss.page(50).count >= 30
            a_max = 50
          elsif @itemss.page(20).count >= 30
            a_max = 20
          elsif @itemss.page(5).count >= 30
            a_max = 5
          elsif @itemss.page(4).count >= 30
            a_max = 4
          elsif @itemss.page(3).count >= 30
            a_max = 3
          elsif @itemss.page(2).count >= 30
            a_max = 2
          else
            a_max = 1
          end
          a = rand(1..a_max)
          @items = @itemss.page(a).sort_by.sort_by {|v| v.title_kana }
          b_max = @items.count
          b = rand(1...b_max)
          @item.push(@items[b])
          p "#{@item[-1].title}"
          #@item.each_with_index do |n,i|
          #@n = n
          #@i = i
          if /\d+$/ === @item[-1].title
            janl(@item[-1])
           @aitem = RakutenWebService::Books::Book.search(title: "#{$`}",outOfStockFlag: 1,booksGenreId: @books_genre_id)
          if @aitem.page(2).count > 9
            #@hantei.push("40巻以上")
            flag = 1
          elsif @aitem.page(1).count > 9
            flag = 0
            #@ten = "10巻以上"
           @hantei.push("10巻以上")
           #flag = 1
          else
            @hantei.push("10巻以下")
            flag = 1
            #@ten = "10巻以下"
          end
            if flag == 0 && @aitem.detect{|i| i.review_count >= 50}
              #flag = 0
              flag = 1
              #@ten += "有名"
              #@hantei[i] = "有名"
            end
          end
          if /\（\d+\）$/ === @item[-1].title
            janl(@item[-1])
            @aitem = RakutenWebService::Books::Book.search(title: "#{$`}",outOfStockFlag: 1,booksGenreId: @books_genre_id)
            if @aitem.page(2).count > 9
              #@hantei.push("40巻以上")
              #@ten = "40巻以上"
              flag = 1
            elsif @aitem.page(1).count > 9
              #@hantei.push("10巻以上")
            #@ten = "10巻以上"
            #flag = 1
              flag = 0
            else
              @hantei.push("10巻以下")
              #@ten = "10巻以下"
              flag = 1
           end
           if flag == 0 && @aitem.detect{|i| i.review_count >= 50}
              #@hantei[i] = "有名"
              #@ten += "有名"
              #flag = 0
              flag = 1
          end
          end
          if /\（\d+\)/ === @item[-1].title
            janl(@item[-1])
            @aitem = RakutenWebService::Books::Book.search(title: "#{$`}",outOfStockFlag: 1,booksGenreId: @books_genre_id)
            janl(@item[-1])
            if @aitem.page(2).count > 9
              #@hantei.push("40巻以上")
              #@ten = "40巻以上"
              flag = 1
            elsif @aitem.page(1).count > 9
              #@hantei.push("10巻以上")
              #@ten = "10巻以上"
              #flag = 1
              flag = 0
            else
            #@ten = "10巻以下"
            #@hantei.push("10巻以下")
            flag = 1
            end
           if @aitem.detect{|i| i.review_count >= 50}
             #@hantei[i] = "有名"
              #@ten += "有名"
              #flag = 0
              flag = 1
           end
          end
      
          if flag == 1
            p "削除"
            @item.pop
          elsif flag == 3
            p "ノイズ"
            @item.pop
          else
            p "通し"
          end
          idx += 1
          if idx > 50
           break
          end
          end #while
       end #elsif
        #end
       if @item != nil
        @item_dummy = []
        @item.each do |i|
          @item_part = []
          @item_part.push(i.title)
          @item_part.push(i.isbn)
          @item_part.push(i.medium_image_url)
          @item_dummy.push(@item_part)
        end
       end #if @item != nil
      end #def
    
      def keysearch
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
          @trial = []
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
          @idx_items.each do |i|
          p i.title
            #rejected.each do |s|
             # if /#{s}/ === i.title
               # flag = 1
              #end
              #if flag = 1
               # break
              #end
            #end
            if flag = 0 && (/\d+$/ === i.title)
              janl(i)
             @aitem = RakutenWebService::Books::Book.search(title: "#{$`}",outOfStockFlag: 1,booksGenreId: @books_genre_id)
            if @aitem.page(2).count > 9
              #@hantei.push("40巻以上")
              flag = 1
            elsif @aitem.page(1).count > 9
              flag = 0
              #@ten = "10巻以上"
             #@hantei.push("10巻以上")
             #flag = 1
            else
              #@hantei.push("10巻以下")
              flag = 1
              #@ten = "10巻以下"
            end
              if flag == 0 && @aitem.detect{|i| i.review_count >= 50}
                #flag = 0
                flag = 1
                #@ten += "有名"
                #@hantei[i] = "有名"
              end
            end
            if /\（\d+\）$/ === i.title
              janl(i)
              @aitem = RakutenWebService::Books::Book.search(title: "#{$`}",outOfStockFlag: 1,booksGenreId: @books_genre_id)
              if @aitem.page(2).count > 9
                #@hantei.push("40巻以上")
                #@ten = "40巻以上"
                flag = 1
              elsif @aitem.page(1).count > 9
                #@hantei.push("10巻以上")
              #@ten = "10巻以上"
              #flag = 1
                flag = 0
              else
                #@hantei.push("10巻以下")
                #@ten = "10巻以下"
                flag = 1
             end
             if flag == 0 && @aitem.detect{|i| i.review_count >= 50}
                #@hantei[i] = "有名"
                #@ten += "有名"
                #flag = 0
                flag = 1
            end
            end
            if /\（\d+\)/ === i.title
              janl(i)
              @aitem = RakutenWebService::Books::Book.search(title: "#{$`}",outOfStockFlag: 1,booksGenreId: @books_genre_id)
              janl(i)
              if @aitem.page(2).count > 9
                #@hantei.push("40巻以上")
                #@ten = "40巻以上"
                flag = 1
              elsif @aitem.page(1).count > 9
                #@hantei.push("10巻以上")
                #@ten = "10巻以上"
                #flag = 1
                flag = 0
              else
              #@ten = "10巻以下"
              #@hantei.push("10巻以下")
              flag = 1
              end
             if @aitem.detect{|i| i.review_count >= 50}
               #@hantei[i] = "有名"
                #@ten += "有名"
                #flag = 0
                flag = 1
             end
            end
        
            if flag == 1
              @trial.push("selected")#本来はrejected
              rejected.push(i.title[0..(i.title.length - 4)])
              @idx_items.reject!{|v| v.title.include?(i.title[0..(i.title.length - 4)]) }
              p "削除"
            elsif flag == 0
              @trial.push("selected")
              selected.push(i.title[0..(i.title.length - 4)])
              @itema.concat(@idx_items.select{|v| /#{i.title[0..(i.title.length - 4)]}/ === v.title})
              @idx_items.reject!{|v| v.title.include?(i.title[0..(i.title.length - 4)]) }
              p "合格"
            else
              p "ノイズ"
            end  
          end 
          idx += 1
          p rejected
          p selected
          end # while  
        end # if
        if @itema != nil
          @item_dummy = []
          @itemss.each do |i|
            @item_part = []
            @item_part.push(i.title)
            @item_part.push(i.isbn)
            @item_part.push(i.medium_image_url)
            @item_dummy.push(@item_part)
          end
         end #if @item != nil
      end
      private
      
      def janl(i)
       if i.books_genre_id.index("/") != nil
        @books_genre_id = i.books_genre_id.slice(0...i.books_genre_id.index("/"))
       else
        @books_genre_id = i.books_genre_id
       end
      end
end
