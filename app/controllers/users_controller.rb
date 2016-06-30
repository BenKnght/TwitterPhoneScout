class UsersController < ApplicationController

	def new 
		@user = User.new
	end

	def seek

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
          User.create(:name => "**FLAG**", :following => ("Tried " + @uname), :phone => "No match", :carry => "Vary search", :deviceType => "Thank you")
        end
        #This adds a flag user when rate limit is hit
        #Doesn't really tell you anything you don't know, though
        #User.create(:name => "**FLAG**", :following => ("Error " + @uname), :phone => "Rate or no user", :carry => "Limit 24000/hour", :deviceType => "Thank you")
        return redirect_to users_limit_path
      end

      data = (JSON.parse(response))

      data["users"].each do |u|

        bio = u["description"].to_s
        phoneNum = findPhoneNum(bio)
        if (phoneNum != "none")

          twil = $lookup_client.phone_numbers.get(phoneNum, type: "carrier")

          #Grab all Twilio data wanted
          #Could be modified to grab any properties
          begin 
            carrierName = twil.carrier["name"].to_s
            carrierType = twil.carrier["type"].to_s
            phoneNum = (twil.national_format).to_s
            User.create(:name => u["screen_name"].to_s, :following => @uname, :phone => phoneNum, :carry => carrierName, :deviceType => carrierType)
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
      User.create(:name => "**FLAG**", :following => ("Tried " + @uname), :phone => "No match", :carry => "Vary search", :deviceType => "Thank you")
    end

    return redirect_to users_all_path

  end

  def all
    @users = User.all
  end

  def clear
    User.destroy_all
    return redirect_to "/users/new"
  end

  def confirmclear
    #Everything in view
  end

  def single
    @dude = User.find(params[:id])
  end

  def killone
    User.destroy(params[:id])
    return redirect_to "/users/all"
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
