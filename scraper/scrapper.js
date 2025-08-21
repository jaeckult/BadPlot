const axios = require("axios");
const fs = require("fs");

// Flatten all nested comments into a single array
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

async function scrapeRedditTop1000() {
  let results = [];
  let after = null;
  const limitPerRequest = 100; // max allowed by Reddit
  const totalPosts = 1000;

  while (results.length < totalPosts) {
    let url = `https://www.reddit.com/r/ExplainAFilmPlotBadly/top.json?t=all&limit=${limitPerRequest}`;
    if (after) url += `&after=${after}`;

    const { data } = await axios.get(url, { headers: { "User-Agent": "filmplot-scraper" } });
    const posts = data.data.children;

    for (const post of posts) {
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

      // Pick top comment
      if (allComments.length > 0) {
        allComments.sort((a, b) => b.upvotes - a.upvotes);
        postInfo.top_comment = allComments[0];
      }

      results.push(postInfo);
      if (results.length >= totalPosts) break;
    }

    if (!data.data.after || results.length >= totalPosts) break;
    after = data.data.after;

    // Optional: small delay to avoid rate limits
    await new Promise(r => setTimeout(r, 1000));
  }

  fs.writeFileSync("reddit_1000_top_comments.json", JSON.stringify(results, null, 2), "utf-8");
  console.log(`✅ Saved ${results.length} posts with top comments`);
}

scrapeRedditTop1000();
