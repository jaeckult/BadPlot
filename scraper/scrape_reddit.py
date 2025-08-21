import praw

# Create a Reddit app at https://www.reddit.com/prefs/apps
reddit = praw.Reddit(
    client_id="YOUR_CLIENT_ID",
    client_secret="YOUR_CLIENT_SECRET",
    user_agent="filmplot_scraper"
)

subreddit = reddit.subreddit("ExplainAFilmPlotBadly")

for post in subreddit.hot(limit=20):
    print(f"Title: {post.title}")
    print(f"Content: {post.selftext}")
    print("-" * 40)
