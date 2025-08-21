// redditScraper.js
const axios = require("axios");
const fs = require("fs");

async function scrapeReddit() {
  let url = "https://www.reddit.com/r/ExplainAFilmPlotBadly/top.json?t=all&limit=100";
  let results = [];

  while (url) {
    const { data } = await axios.get(url, { headers: { "User-Agent": "filmplot-scraper" } });
    const posts = data.data.children;
    results.push(...posts);

    if (data.data.after) {
      url = `https://www.reddit.com/r/ExplainAFilmPlotBadly/top.json?t=all&limit=100&after=${data.data.after}`;
    } else {
      url = null;
    }
  }

  // Save CSV
  let csv = "title,author,upvotes,permalink\n";
  results.forEach(p => {
    csv += `"${p.data.title.replace(/"/g, "'")}",${p.data.author},${p.data.ups},https://reddit.com${p.data.permalink}\n`;
  });

  fs.writeFileSync("reddit_plots.csv", csv, "utf-8");
  console.log(`✅ Saved ${results.length} Reddit posts to reddit_plots.csv`);
}

scrapeReddit();
