defmodule TwitterprojectWeb.EngineChannel do
  use TwitterprojectWeb, :channel
  alias TwitterprojectWeb.Server

    def join("twitterengine", payload, socket) do
        id = Map.get(payload, "id")
        Server.register_user(id, "user"<> id, socket)
        {:ok, socket}
    end

    def handle_in("follow_random", payload, socket) do
        id = Map.get(payload, "id")
        Server.follow_random(id)
        :timer.sleep(1000)
        {:reply, {:ok, payload}, socket}
    end

    def handle_in("do_tweet", payload, socket) do
        userid = Map.get(payload, "id")
        tweet = Map.get(payload, "tweet")
        Server.do_tweet(userid, tweet)
        :timer.sleep(1000)
        {:reply, {:ok, payload}, socket}
    end

    def handle_in("do_retweet", payload, socket) do
        userid = Map.get(payload, "id")
        Server.do_retweet(userid)
        :timer.sleep(1000)
        {:reply, {:ok, payload}, socket}
    end

end  