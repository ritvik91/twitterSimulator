defmodule Twitterproject.ClientSocket do
    @moduledoc false
    require Logger
    alias Phoenix.Channels.GenSocketClient
    @behaviour GenSocketClient
  
    def start_link(id, total_users) do
      GenSocketClient.start_link(
            __MODULE__,
            Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
            %{"url" => "ws://localhost:4000/socket/websocket", "id" => id, "total_users" => total_users}
          )
    end
  
    def init(initial_state) do
      {:connect, Map.get(initial_state, "url"), [], 
          %{first_join: true, ping_ref: 1, id: Map.get(initial_state, "id"), 
                total_users: Map.get(initial_state, "total_users"), engine_state: %{}}}
    end
  
    def handle_connected(transport, state) do
      IO.puts "User" <> state.id <> " connected"
      GenSocketClient.join(transport, "twitterengine", %{"id" => state.id})
      {:ok, state}
    end

    def handle_disconnected(reason, state) do
      Logger.error("disconnected: #{inspect reason}")
      Process.send_after(self(), :connect, :timer.seconds(1))
      {:ok, state}
    end

    def handle_info({:join, topic}, transport, state) do
      Logger.info("joining the topic #{topic}")
      case GenSocketClient.join(transport, topic) do
        {:error, reason} ->
          Logger.error("error joining the topic #{topic}: #{inspect reason}")
          Process.send_after(self(), {:join, topic}, :timer.seconds(1))
          {:ok, _ref} -> :ok
      end
  
      {:ok, state}
    end

    def handle_joined(topic, _payload, _transport, state) do
      #Logger.info("joined the topic #{topic}")

      # ------  Add follower -----
      :timer.send_after(:timer.seconds(1), self(), :add_random_followers)
      :timer.sleep(500)

      numoftweets = Enum.random(4..10)
      for n <- 1..numoftweets do
        :timer.send_after(:timer.seconds(1), self(), :do_tweet)
        :timer.sleep(200)
      end
      
      numofretweets = Enum.random(1..3)
      for n <- 1..numofretweets do
        :timer.send_after(:timer.seconds(1), self(), :do_retweet)
        :timer.sleep(200)
      end

      {:ok, state}
    end

    def handle_join_error(topic, payload, _transport, state) do
      Logger.error("join error on the topic #{topic}: #{inspect payload}")
      {:ok, state}
    end
  
    def handle_channel_closed(topic, payload, _transport, state) do
      Logger.error("disconnected from the topic #{topic}: #{inspect payload}")
      Process.send_after(self(), {:join, topic}, :timer.seconds(1))
      {:ok, state}
    end

    def handle_reply(topic, _ref, payload, _transport, state) do
      Logger.warn("reply on topic #{topic}: #{inspect payload}")
      {:ok, state}
    end
  
    def handle_reply("twitterengine", _ref, %{"status" => "ok"} = payload, _transport, state) do
      # IO.inspect self(), label: "In handle reply pid is "
      # Logger.info("server pong ##{payload["response"]["ping_ref"]}")
      {:ok, state}
    end

    def handle_info(:add_random_followers, transport, state) do
      total_users = state.total_users
      max_followers = trunc(:math.ceil(total_users * 0.2))
      total_followers = Enum.random(1..max_followers)
      users = Enum.map(1..total_users, fn x -> to_string(x) end)
      user = state.id
      others = List.delete(users, user)
      followers = Enum.take_random(others, total_followers)
      Enum.each(followers, fn follower -> GenSocketClient.push(transport, "twitterengine" , "follow_random", %{"id" => state.id}) end)
      {:ok, state}
    end    


    def handle_message(topic, event, payload, _transport, state) do

      if event == "usernames" do
        :ets.insert(:user_lookup, {"usernames_" <> state.id, payload})

 -
        :timer.send_after(:timer.seconds(1), self(), :send_tweet)
        :timer.sleep(1000)
      end

      if event == "tweets" do
        :ets.insert(:user_lookup, {"tweets_" <> state.id, payload})

        :timer.send_after(:timer.seconds(1), self(), :subscribe_to_tweet)
        :timer.sleep(1000)
      end
      {:ok, state}
    end
  

    def handle_info(:do_tweet, transport, state) do
      user = state.id
      tweetlist = ["#Skydiving is amazing, you should try it @user1", "I'll suggest #Harry potter book to @user5", "#Skubadiving and #Skydiving both are amazing sport @user3", "@user3 you should try that dish", "Best of luck @user1 for #worldcup", "#worldcup approaching, exciting! @user5"]
      tweettext = Enum.random(tweetlist)
      GenSocketClient.push(transport, "twitterengine" , "do_tweet", %{"id" => state.id, "tweet" => tweettext})
      {:ok, state}
    end    

    def handle_info(:do_retweet, transport, state) do
      total_users = state.total_users
      user = state.id
      GenSocketClient.push(transport, "twitterengine" , "do_retweet", %{"id" => state.id})
      {:ok, state}
    end  



  

end
