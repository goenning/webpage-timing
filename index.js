const puppeteer = require('puppeteer');
const MongoClient = require('mongodb').MongoClient;

const requestURL = process.env.REQUEST_URL || 'https://example.org';
const mongoURL = process.env.MONGO_URL;

(async () => {
  const timing = {};
  const browser = await puppeteer.launch({
    args: [
      "--no-sandbox",
      "--disable-dev-shm-usage",
    ],
    headless: true,
    ignoreHTTPSErrors: true
  });
  const page = await browser.newPage();
  timing.start = new Date();
  await page.goto(requestURL, { waitUntil: 'networkidle0' });
  timing.end = new Date();
  timing.metrics = await page.metrics();
  timing.entries = JSON.parse(await page.evaluate(() => JSON.stringify(performance.getEntries(), null, "  ")));
  timing.start_ts = timing.start.getTime();
  timing.end_ts = timing.end.getTime();
  timing.duration = timing.end_ts - timing.start_ts;
  await browser.close();

  if (mongoURL) {
    await store(timing);
  } else {
    console.log(timing);
  }
})();

const store = async (timing) => {
  try {
    const client = new MongoClient(mongoURL, { useNewUrlParser: true });
    await client.connect();
    await client.db('webtiming').collection('timings').insertOne(timing);
    client.close();
  } catch (err) {
    console.log(err.stack);
  }
}