const puppeteer = require('puppeteer');
const MongoClient = require('mongodb').MongoClient;
const os = require('os');

const origin = process.env.ORIGIN || os.hostname();
const requestURL = process.env.REQUEST_URL || 'https://example.org';
const mongoURL = process.env.MONGO_URL;
const networkWait = 500;

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
  await Promise.all([
    page.goto(requestURL),
    waitForNetworkIdle(page, networkWait),
  ]);

  timing.start_ts = timing.start.getTime();
  timing.duration = new Date().getTime() - timing.start_ts - networkWait;
  timing.origin = origin;
  timing.request_url = requestURL;
  timing.metrics = await page.metrics();
  timing.entries = JSON.parse(await page.evaluate(() => JSON.stringify(performance.getEntries(), null, "  ")));
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

const waitForNetworkIdle = (page, timeout, maxInflightRequests = 0) => {
  page.on('request', onRequestStarted);
  page.on('requestfinished', onRequestFinished);
  page.on('requestfailed', onRequestFinished);

  let inflight = 0;
  let fulfill;
  let promise = new Promise(x => fulfill = x);
  let timeoutId = setTimeout(onTimeoutDone, timeout);
  return promise;

  function onTimeoutDone() {
    page.removeListener('request', onRequestStarted);
    page.removeListener('requestfinished', onRequestFinished);
    page.removeListener('requestfailed', onRequestFinished);
    fulfill();
  }

  function onRequestStarted() {
    ++inflight;
    if (inflight > maxInflightRequests)
      clearTimeout(timeoutId);
  }
  
  function onRequestFinished() {
    if (inflight === 0)
      return;
    --inflight;
    if (inflight === maxInflightRequests)
      timeoutId = setTimeout(onTimeoutDone, timeout);
  }
}