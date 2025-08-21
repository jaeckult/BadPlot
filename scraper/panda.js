// genericScraper.js
const fetch = require("node-fetch");
const cheerio = require("cheerio");
const fs = require("fs");

async function scrapeBoredPanda() {
  const url = "https://www.boredpanda.com/explain-a-film-plot-badly-funny-tweets/";
  const res = await fetch(url);
  const html = await res.text();
  const $ = cheerio.load(html);

  let results = [];
  $("h2").each((i, el) => {
    const text = $(el).text().trim();
    if (text) results.push(text);
  });

  fs.writeFileSync("boredpanda_plots.txt", results.join("\n"), "utf-8");
  console.log(`✅ Saved ${results.length} plots from BoredPanda`);
}

scrapeBoredPanda();
