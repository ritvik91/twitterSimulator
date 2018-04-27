defmodule TwitterprojectWeb.Server do
    use GenServer
    use TwitterprojectWeb, :channel

    def start_link(initial_state) do
        GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
    end


    def init(_) do
        #list = initial_data
        {:ok, [[],[],[],[],[],[],[],[]]}
    end

    #--------------------------    Registration --------------------------------------

    def register_user(user_id, user_name, socket) do
        GenServer.cast(__MODULE__, {:register_user, user_id, user_name, socket})
    end


    def handle_cast({:register_user, user_id, user_name, socket}, state) do
        :ets.insert(:user_lookup, {user_id, socket})
        
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state
    
        clientlist = clientlist ++ [user_id]
        clientDetails = clientNames ++ [user_name]
        clientPassswds = clientPassswds ++ []
        follows = follows ++ [[]]
        followsNames = followsNames ++ [[]]
        tweets = tweets = tweets ++ [[]]
        tweetsid = tweetsid ++ [[]]

        #IO.puts "Client Registered with Twitter Engine"

        state = [clientlist, clientDetails, clientPassswds, follows, followsNames, tweets, tweetsid, alltweets]
        {:noreply, state}
    end


    #--------------------------------  Follow ---------------------------------------------------

    def follow_random(pid) do
        GenServer.cast(__MODULE__, {:follow_random, pid})
    end

    def handle_cast({:follow_random, pid}, state) do
    
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state

        optionstofollow = clientlist -- [pid]
        indexofpid = Enum.find_index(clientlist, fn(x) -> x == pid end)
        followersalready = Enum.at(follows, indexofpid)
        followsalreadynames = Enum.at(followsNames, indexofpid)

        optionstofollow = optionstofollow -- followersalready

        newfollow = Enum.random(optionstofollow)

        followindex = Enum.find_index(clientlist, fn(x) -> x==newfollow end)
        followname = Enum.at(clientNames, followindex)

        newfollowlist = followersalready ++ [newfollow]
        newfollownamelist = followsalreadynames ++ [followname]

        follows = List.replace_at(follows, indexofpid, newfollowlist)
        followsNames = List.replace_at(followsNames, indexofpid, newfollownamelist) 

        username = Enum.at(clientNames, indexofpid)

        IO.puts "Follower added " <> followname

        state = [clientlist, clientNames, clientPassswds, follows, followsNames, tweets, tweetsid, alltweets]
        {:noreply, state}
    end


    #--------------------------    Tweet ------------------------------------------------

    def do_tweet(pid, tweettext) do
        GenServer.cast(__MODULE__, {:add_tweet, pid, tweettext})
    end

    def handle_cast({:add_tweet, pid, tweettext}, state) do
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state

        indexofpid = Enum.find_index(clientlist, fn(x) -> x == pid end)

        tweetsofuser = Enum.at(tweets, indexofpid)
    
        tweetsofuser = tweetsofuser ++ [tweettext]

        tweetsidlistofuser = Enum.at(tweetsid, indexofpid)

        maxid = 0
        if length(tweetsidlistofuser) != 0 do
            maxid = Enum.max(tweetsidlistofuser)
        end

        tweetsidlistofuser = tweetsidlistofuser ++ [maxid+1]

        tweets = List.replace_at(tweets, indexofpid, tweetsofuser)
        tweetsid = List.replace_at(tweetsid, indexofpid, tweetsidlistofuser)
    
        username = Enum.at(clientNames, indexofpid)
    
        IO.puts "User tweeted " <> username <> " with tweet " <> tweettext <> " tweetid: " <> Integer.to_string(maxid+1)

        alltweets = alltweets ++ [tweettext]

        state = [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets]
        {:noreply, state}
    end


    #-------------------------------------- ReTweet --------------------------------------------------------

    def do_retweet(pid) do
       GenServer.cast(__MODULE__, {:ReTweet, pid}) 
    end

    def handle_cast({:ReTweet, pid}, state) do
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state

        indexofpid = Enum.find_index(clientlist, fn(x) -> x == pid end)


        if length(follows) !=0 do
      
            followsoptions = Enum.at(follows,indexofpid)

            followid = Enum.random(followsoptions)

            followidindex = Enum.find_index(clientlist, fn(x) -> x == followid end)

            followhandle = Enum.at(clientNames, followidindex)
            tweetlist_follow = Enum.at(tweets, followidindex)     
      
            if length(tweetlist_follow) != 0 do
                tweetselect = Enum.random(tweetlist_follow)

                tweetsplit = String.split(tweetselect)

                if !(Enum.at(tweetsplit,0) == "re:") do
                    tweetselect = "re: " <> followhandle <> ": " <> tweetselect
                end  

                #IO.puts "tweetselect: "
                #IO.inspect tweetselect        
        
                tweetsidlistofuser = Enum.at(tweetsid, indexofpid)

                maxid = 0
                if length(tweetsidlistofuser) != 0 do
                    maxid = Enum.max(tweetsidlistofuser)
                end

                tweetsidlistofuser = tweetsidlistofuser ++ [maxid+1]

                tweetsofuser = Enum.at(tweets, indexofpid)
                tweetsofuser = tweetsofuser ++ [tweetselect]

                tweets = List.replace_at(tweets, indexofpid, tweetsofuser)
                tweetsid = List.replace_at(tweetsid, indexofpid, tweetsidlistofuser)

                alltweets = alltweets ++ [tweetselect]

                username = Enum.at(clientNames, indexofpid)

                IO.puts "User Retweeted: " <> username <> " tweet retweeted: " <> tweetselect <> " tweetid: " <> Integer.to_string(maxid+1)

            end


        end

        state = [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets]
        {:noreply, state}
    end


    #----------------------------------- Tweets with mention -------------------------------------------

    def search_tweets_with_mentions(name) do
         GenServer.call(__MODULE__, {:search_tweets_with_mentions, name})    
    end

    def handle_call({:search_tweets_with_mentions, name}, from, state) do
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state

        if !(name=~"@") do
            name = "@" <> name
        end

        tweetslistwith_mention_and_nil = Enum.map((alltweets), fn(x)-> if x=~ name do x end end)
        tweetswithmention = Enum.filter(tweetslistwith_mention_and_nil, & !is_nil(&1))

        #Tclient.sendtoClient(pid, tweetswithmention)

        {:reply, tweetswithmention, state}
    end


    #------------------------------------ Search tweets with hashtag ---------------------------------------

    def search_tweets_with_hashtag(hashTag) do
        GenServer.call(__MODULE__,{:search_tweets_with_hashtag, hashTag})     
    end

    def handle_call({:search_tweets_with_hashtag, hashTag}, from, state) do
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state

        if !(hashTag=~"#") do
            hashTag = "#" <> hashTag
        end

        tweetslistwith_hashtag_and_nil = Enum.map((alltweets), fn(x)-> if x=~ hashTag do x end end)
        tweetswithhashtag = Enum.filter(tweetslistwith_hashtag_and_nil, & !is_nil(&1))

        #Tclient.sendtoClienthashtaglist(pid, tweetswithhashtag)

        {:reply, tweetswithhashtag, state}
    end


    #-------------------------------------- Search the profile ----------------------------------------------------

    def searchProfile(pid) do
        GenServer.call(__MODULE__, {:show_my_following_n_tweets_list, pid})
    end


    def handle_call({:show_my_following_n_tweets_list, pid}, from, state) do
    
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state

        indexofpid = Enum.find_index(clientlist, fn(x) -> x == pid end)

        followlist = Enum.at(followsNames, indexofpid)

        tweetslist = Enum.at(tweets, indexofpid)

        follows_n_tweetslist = [followlist, tweetslist]

        #Tclient.showProfileAtClient(pid, follows_n_tweetslist)
  
        {:reply, follows_n_tweetslist, state}
    end


    #------------------------------------ Search the TimeLine ------------------------------------------------------

    def searchTimeline(pid) do
      GenServer.call(__MODULE__,{:get_following_tweets, pid})  
    end

    def handle_call({:get_following_tweets, pid}, from, state) do
        [clientlist, clientNames, clientPassswds, follows , followsNames, tweets, tweetsid, alltweets] = state

        indexofpid = Enum.find_index(clientlist, fn(x) -> x == pid end)

        mytweets = Enum.at(tweets, indexofpid)

        followslist = Enum.at(follows, indexofpid)

        indexlist = []
        userlist = []
        followstweetlist = []

        if length(followslist) != 0 do
            indexlist = Enum.map((followslist), fn(x) -> indexofpid = Enum.find_index(clientlist, fn(x1) -> x1 == x end) end)
            userlist = Enum.map(indexlist, fn(x) -> Enum.at(clientNames, x) end)  
            followstweetlist = Enum.map(indexlist, fn(x) -> Enum.at(tweets, x) end)
        end
    
        mylist_users_n_tweetslist = [ mytweets ,userlist, followstweetlist]

        #Tclient.showTimelineAtClient(pid, mylist_users_n_tweetslist)

        {:reply, mylist_users_n_tweetslist, state}
    end

end
