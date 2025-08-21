const axios = require("axios");
const fs = require("fs");

// Recursive function to flatten all nested comments into a single array
function flattenComments(commentsArray) {
  let flat = [];

  for (const c of commentsArray) {
    if (c.kind !== "t1") continue; // t1 = comment
    const data = c.data;
    flat.push({
      author: data.author,
      body: data.body,
      upvotes: data.ups
    });

    if (data.replies && data.replies.data) {
      flat = flat.concat(flattenComments(data.replies.data.children));
    }
  }

  return flat;
}

async function scrapeRedditBestComment(limit = 1000) {
  const url = `https://www.reddit.com/r/ExplainAFilmPlotBadly/top.json?t=all&limit=${limit}`;
  const { data } = await axios.get(url, { headers: { "User-Agent": "filmplot-scraper" } });

  const results = [];

  for (const post of data.data.children) {
    const postData = post.data;
    const postInfo = {
      title: postData.title,
      author: postData.author,
      upvotes: postData.ups,
      permalink: `https://reddit.com${postData.permalink}`,
      top_comment: null
    };

    // Fetch comments JSON
    const commentsURL = `https://www.reddit.com${postData.permalink}.json`;
    const { data: commentsData } = await axios.get(commentsURL, { headers: { "User-Agent": "filmplot-scraper" } });

    const allComments = flattenComments(commentsData[1].data.children);

    // Pick the comment with the highest upvotes
    if (allComments.length > 0) {
      allComments.sort((a, b) => b.upvotes - a.upvotes);
      postInfo.top_comment = allComments[0];
    }

    results.push(postInfo);
  }

  fs.writeFileSync("reddit_posts_top_comment.json", JSON.stringify(results, null, 2), "utf-8");
  console.log(`✅ Saved ${results.length} posts with their top comment`);
}

scrapeRedditBestComment(10);
