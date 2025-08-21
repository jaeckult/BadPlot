// twitterScraper.js
const { exec } = require("child_process");
const fs = require("fs");

function scrapeTwitter(query, limit = 50) {
  exec(`snscrape --max-results ${limit} twitter-search "${query}"`, (error, stdout, stderr) => {
    if (error) {
      console.error("Error:", error.message);
      return;
    }
    if (stderr) {
      console.error("Stderr:", stderr);
      return;
    }

    const tweets = stdout.split("\n").filter(line => line.trim() !== "");
    fs.writeFileSync("twitter_plots.txt", tweets.join("\n"), "utf-8");
    console.log(`✅ Saved ${tweets.length} tweets to twitter_plots.txt`);
  });
}

scrapeTwitter("#ExplainAFilmPlotBadly", 50);
