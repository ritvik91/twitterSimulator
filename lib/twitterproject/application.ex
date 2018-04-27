defmodule Twitterproject.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    :ets.new(:user_lookup, [:set, :public, :named_table])

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      #supervisor(Twitterproject.Repo, []),
      # Start the endpoint when the application starts
      supervisor(TwitterprojectWeb.Endpoint, []),

      worker(TwitterprojectWeb.Server, [%{}])

      # Start your own worker by calling: Twitterproject.Worker.start_link(arg1, arg2, arg3)
      # worker(Twitterproject.Worker, [arg1, arg2, arg3]),
    ]
    total_users = 100

    children = children ++ Enum.map(1..total_users, fn x ->
        worker(Twitterproject.ClientSocket, [to_string(x), total_users], id: x)
    end)
    
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Twitterproject.Supervisor]
    Supervisor.start_link(children, opts)


    #children = Supervisor.which_children(pid)
    #children = Enum.filter(children, fn(x) -> is_integer(elem(x, 0)) end)

    :timer.sleep(50000)

    mentionoptions = ["user1", "@user3", "user5"]
    mentiontosearch = Enum.random(mentionoptions)
    IO.puts "\n----------------------Tweets with mention " <> mentiontosearch
    tweetswithmention = TwitterprojectWeb.Server.search_tweets_with_mentions(mentiontosearch)
    IO.inspect tweetswithmention

    
    :timer.sleep(1000)

    hashtagoptions = ["Skydiving", "#Skubadiving", "worldcup", "Harry"]
    hashtagtosearch = Enum.random(hashtagoptions)
    IO.puts "\n---------------------Tweets with hashtag " <> hashtagtosearch
    tweetswithhashtag = TwitterprojectWeb.Server.search_tweets_with_hashtag(hashtagtosearch)
    IO.inspect tweetswithhashtag
    
    :timer.sleep(1000)

    totalcount = total_users
    pid = Enum.random(1..totalcount)
    profile_details = TwitterprojectWeb.Server.searchProfile(Integer.to_string(pid))
    IO.puts "\nFor user" <> Integer.to_string(pid)
    print_Profile(profile_details)

    :timer.sleep(1000)

    pid = Enum.random(1..totalcount)
    timeline_details = TwitterprojectWeb.Server.searchTimeline(Integer.to_string(pid))
    IO.puts "\nFor user" <> Integer.to_string(pid)
    print_Timeline(timeline_details)

    waitformsg()
  end


  def waitformsg() do
    receive do
      {msg} -> IO.inspect msg
    end
  end

  def print_Profile(follows_n_tweetslist) do
      
      IO.puts "----------------------- Profile ----------------------------------------"
      [followinglist, tweetslist] = follows_n_tweetslist
      IO.puts "This user is following : " 
      IO.inspect followinglist
      IO.puts "Tweets by user : "
      IO.inspect tweetslist
      IO.puts "\n"
  end 

  def print_Timeline(mylist_users_n_tweetslist) do
      
      [mylist, users, tweetslist] = mylist_users_n_tweetslist

      IO.puts "-------------------------- Timeline---------------------------------------"

      IO.puts "Own tweets: "
      IO.inspect mylist

      for n <- 0..length(users)-1 do      
        IO.puts "User it following :"
        IO.inspect Enum.at(users, n)
        IO.puts "Tweets of that user :"
        IO.inspect Enum.at(tweetslist, n)
      end
      IO.puts "\n"
  end 

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitterprojectWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
