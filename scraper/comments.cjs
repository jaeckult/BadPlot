const axios = require("axios");
const fs = require("fs");

async function scrapeRedditWithComments() {
  // Step 1: Get top posts
  const subredditURL = "https://www.reddit.com/r/ExplainAFilmPlotBadly/top.json?t=all&limit=10";
  const { data } = await axios.get(subredditURL, { headers: { "User-Agent": "filmplot-scraper" } });

  const results = [];

  for (const post of data.data.children) {
    const postData = post.data;
    const postInfo = {
      title: postData.title,
      author: postData.author,
      upvotes: postData.ups,
      permalink: `https://reddit.com${postData.permalink}`,
      comments: []
    };

    // Step 2: Get comments
    const commentsURL = `https://www.reddit.com${postData.permalink}.json`;
    const { data: commentsData } = await axios.get(commentsURL, { headers: { "User-Agent": "filmplot-scraper" } });

    const commentsArray = commentsData[1].data.children;

    for (const c of commentsArray) {
      if (c.kind === "t1") { // t1 = comment
        postInfo.comments.push({
          author: c.data.author,
          body: c.data.body,
          upvotes: c.data.ups
        });
      }
    }

    results.push(postInfo);
  }

  // Step 3: Save JSON
  fs.writeFileSync("reddit_posts_comments.json", JSON.stringify(results, null, 2), "utf-8");
  console.log(`✅ Saved ${results.length} posts with comments`);
}

scrapeRedditWithComments();
