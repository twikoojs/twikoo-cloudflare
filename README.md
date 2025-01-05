# Cloudflare deployment for twikoo comment system

This is the Cloudflare deployment for [twikoo](https://twikoo.js.org/en/intro.html) comment system. Compared to other deployments like Vercel/Netlify + MongoDB, it greatly improved the cold start latency (`6s` -> `<0.5s`). The latency improvement largely comes from tremendous optimizations on Cloudflare workers as well as integrated environment between HTTP server and database (Cloudflare D1).

## Steps for the deployment

1. Install npm packages:
  ```shell
  npm install
  ```
2. Because the free tier of Cloudflare workers has a strict 1MiB limit on the bundle size, we need to manually delete some packages to keep the bundle within the limit. These packages can't be used anyway due to the Node.js [compatibility issues](#known-limitations) of Cloudflare workers.
  ```shell
  echo "" > node_modules/jsdom/lib/api.js
  echo "" > node_modules/tencentcloud-sdk-nodejs/tencentcloud/index.js
  echo "" > node_modules/nodemailer/lib/nodemailer.js
  ```
3. Login to your Cloudflare account:
  ```shell
  npx wrangler login
  ```
3. Create the Cloudflare D1 database and set up the schema:
  ```shell
  npx wrangler d1 create twikoo
  ```
4. Copy 2 lines of `database_name` and `database_id` from the output of the previous step, and paste them into `wrangler.toml` file, replacing the original values.
5. Set up the Cloudflare D1 schema:
   ```shell
   npx wrangler d1 execute twikoo --remote --file=./schema.sql
   ```
6. Create the Cloudflare R2 Storage:
   ```shell
   npx wrangler r2 bucket create twikoo
   ```
7. Update the domain of R2 into `wrangler.toml` file, replacing the `R2_PUBLIC_URL` value.
8. Deploy the Cloudflare worker:
  ```shell
  npx wrangler deploy --minify
  ```
9. If everything works smoothly, you will see something like: `https://twikoo-cloudflare.<your user name>.workers.dev` in the commandline. You can visit the address. If everything is set up perfectly, you're expected to see a line like that in your browser:
  ```
  {"code":100,"message":"Twikoo 云函数运行正常，请参考 https://twikoo.js.org/frontend.html 完成前端的配置","version":"1.6.33"}
  ```
10. When you set up the front end, the address in step 6 (including the `https://` prefix) should be used as the `envId` field in `twikoo.init`.

> Auto deploy: [See the blog](https://blog.mingy.org/2024/12/hexo-add-twikoo/)

## Known limitations

Because Cloudflare workers are only [partially compatible](https://developers.cloudflare.com/workers/runtime-apis/nodejs/) with Node.js, there are certain functional limitations for the twikoo Cloudflare deployment due to compatibility issues:

1. Environment variables (`process.env.XXX`) can't be used to control the behavior of the app.
2. Tencent Cloud can't be integrated.
3. Can't find the location based on ip address (compatibility issue of the `@imaegoo/node-ip2region` package).
4. Package `dompurify` can't be used to sanitize the comments due to compatibility issue of `jsdom` package. Instead, we're using [`xss`](https://www.npmjs.com/package/xss) package for XSS sanitization.
5. In this deployment, we don't normalize URL path between `/some/path/` and `/some/path`. This is because it's not easy to write a Cloudflare D1 SQL query to unify these 2 kinds of paths. If your website can have paths with and without the trailing `/` for the same page, you can explicitly set the `path` field in `twikoo.init`.
6. Image uploading instead of using Cloudflare R2 Storage.
7. Since using [axios-cf-worker](https://github.com/wuzhengmao/axios-cf-worker), `pushoo.js` works well.

## Configure for email notifications

Because of the compatibility issues of `nodemailer` package, the email integration via SMTP for sending notifications won't work directly. Instead, in this worker, we support email notifications via SendGrid's HTTPS API. To enable the email integration via SendGrid, you can follow the steps below:
1. Ensure you have a usable SendGrid account (SendGrid offers a free-tier for sending up to 100 emails per day) or MailChannels account (free for 3000 emails per month), and create an API key.
2. Set the following fields in the config:
  * `SENDER_EMAIL`: The email address of the sender. Needs to verify it in SendGrid.
  * `SENDER_NAME`: The name shown as the sender.
  * `SMTP_SERVICE`: `SendGrid`.
  * `SMTP_USER`: Provide some non-empty value.
  * `SMTP_PASS`: The API key.
3. Optionally, you can set other config values to customize how the notification emails look like.
4. In the configuration page, click `Send test email` button to make sure the integration works well.
5. In your email provider, make sure the incoming emails aren't classified as spam.

---

If you encounter any issues, or have any questions for this deployment, you can send an email to tao@vanjs.org.
