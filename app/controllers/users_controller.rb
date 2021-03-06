class UsersController < ApplicationController

	def new 
    #This only reads in a name string
    #It doesn't need to be a full user because this user is never saved
    #This was easier to write than jsut getting a string
		@base = User.new
	end

	def seek

    #Create empty guest object to assign if guest doesn't sign in
    unless Guest.exists?(:guestname => '*Anonymous*')
      Guest.create(:provider => "twitter", :uid => "*none*", :guestname => "*Anonymous*", :token => "*none*", :secret => "*none")
    end

    if current_guest
      @cur = Guest.find_by_id(session[:guest_id]) 
      logged_in = 1
    else 
      #Exactly one of these should always exist
      @cur = ( Guest.where(:guestname => '*Anonymous*').take(1) )[0]
      logged_in = 0
    end

    @seek_users = []

    @uname = params["name"]

    reqPar = {}
    reqPar['Authorization'] = "Bearer #{$bearTok}"
    cursor = "-1"
    ind = 0
    validFound = 0


    while (cursor != 0) && (ind <= 10)
      
      reqUrl = "https://api.twitter.com/1.1/followers/list.json?cursor=" + cursor + "&screen_name=" + @uname + "&count=200&skip_status=true&include_user_entities=false"
      
      #Catch Twitter reference error
      begin 
        response = RestClient.get(reqUrl, reqPar)
      rescue
        if (validFound == 0)
          temp = User.create(:name => "*FLAG*", 
            :following => ("*" + @uname + "*"), 
            :phone => "*No match*", 
            :carry => "*Vary search*", 
            :deviceType => "*Thanks*", 
            :searchedguest => @cur.guestname,
            :followercount => "*Null*",
            :profilelink => "*Null*",
            :bio => "*Null*",
            :website => "*Null*"
          )
          @cur.users << temp
          @seek_users << temp
        end
        #This adds a flag user when rate limit is hit
        #Doesn't really tell you anything you don't know, though
        #User.create(:name => "**FLAG**", :following => ("Error " + @uname), :phone => "Rate or no user", :carry => "Limit 24000/hour", :deviceType => "Thank you")
        return redirect_to users_limit_path
      end

      data = (JSON.parse(response))

      data["users"].each do |u|

        bio = u["description"].to_s
        fcount = u["followers_count"].to_s
        username = u["screen_name"].to_s
        plink = "https://twitter.com/" + username
        wsite = u["url"].to_s

        phoneNum = findPhoneNum(bio)
        if (phoneNum != "none")

          twil = $lookup_client.phone_numbers.get(phoneNum, type: "carrier")

          #Grab all Twilio data wanted
          #Could be modified to grab any properties
          begin 
            carrierName = twil.carrier["name"].to_s
            carrierType = twil.carrier["type"].to_s
            phoneNum = (twil.national_format).to_s
            temp = User.create(
              :name => username, 
              :following => @uname, 
              :phone => phoneNum, 
              :carry => carrierName, 
              :deviceType => carrierType, 
              :searchedguest => @cur.guestname,
              :followercount => fcount,
              :profilelink => plink,
              :bio => bio,
              :website => wsite
            )
            @cur.users << temp
            @seek_users << temp
            validFound = 1
          rescue
            #If no or invalid phone, do nothing
          end

        end

      end

      cursor = data["next_cursor"].to_s
      ind = ind+1

    end

    #Creates a flag user to let you know that no results were found
    if (validFound == 0)
      temp = User.create(:name => "*FLAG*", 
        :following => ("*" + @uname + "*"), 
        :phone => "*No match*", 
        :carry => "*Vary search*", 
        :deviceType => "*Thanks*", 
        :searchedguest => @cur.guestname,
        :followercount => "*Null*",
        :profilelink => "*Null*",
        :bio => "*Null*",
        :website => "*Null*"
      )      
      @cur.users << temp
      @seek_users << temp
    end

    #return redirect_to users_all_path

  end

  def all
    @global_users = User.all
  end

  def local
    temp = Guest.find_by_id(session[:guest_id])
    @local_users = User.where(:searchedguest => temp.guestname)
  end

  def clear
    temp = Guest.find_by_id(session[:guest_id])
    User.where(:searchedguest => temp.guestname).destroy_all
    return redirect_to "/users/new"
  end

  def confirmclear
    #Everything in view
  end

  def single
    @dude = User.find(params[:id])
  end

  def singleglobal
    @global_dude = User.find(params[:id])
  end

  def killone
    User.destroy(params[:id])
    return redirect_to "/users/local"
  end

  def getstats
    @carriers = {}
    @types = {}
    all = User.all

    all.each do |u|
      c = (u.carry).to_sym
      d = (u.deviceType).to_sym

      if @carriers.key?(c)
        @carriers[c] += 1
      else
        @carriers[c] = 1
      end

      if @types.key?(d)
        @types[d] += 1
      else
        @types[d] = 1
      end

    end

  end

  def getlocalstats
    @local_carriers = {}
    @local_types = {}
    temp = Guest.find_by_id(session[:guest_id])
    all = User.where(:searchedguest => temp.guestname)

    all.each do |u|
      c = (u.carry).to_sym
      d = (u.deviceType).to_sym

      if @local_carriers.key?(c)
        @local_carriers[c] += 1
      else
        @local_carriers[c] = 1
      end

      if @local_types.key?(d)
        @local_types[d] += 1
      else
        @local_types[d] = 1
      end

    end

  end

  #
  #PRIVATE METHODS
  #

	private 
  
  def findPhoneNum(doc)

    nums = 0
    ind = -1
    c = 0
    phone = "none"
    final = ""

    while (c<(doc.length)) && (phone == "none")
      if isDigit(doc[c])
        #if nums == 0
          #ind = c
        #end
        nums = nums+1
        final = final + doc[c]
      end
      if isAlpha(doc[c])
        if (nums==10) || (nums==11)
          #phone = doc[ind..(c-1)] 
          phone = final 
        else 
          nums = 0
          final = ""
        end
      end
      c = c+1
    end
    
    #Handles phone number at end of document
    if (phone=="none") && ((nums==10) || (nums==11))
      #phone = doc[ind..-1]
      phone = final
    end

    #Scanner doesnt pick up symbols
    #This adds a plus so that Twilio can recognize a US number with an international code
    if (phone!="none") && (phone.length==11)
      phone = "+" + phone
    end 

    return phone
  end

  def isAlpha(c)
    x = (c =~ /\A[[:alpha:]]+\z/)
    if x==0
      return true
    else 
      return false
    end
  end

  def isDigit(c)

    x = (c =~ /\A[[:digit:]]+\z/)
    if x==0
      return true
    else 
      return false
    end

  end

end
