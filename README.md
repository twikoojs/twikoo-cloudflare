# twikoo deployment on Cloudflare workers

This is the twikoo deployment on Cloudflare workers. Compared to other deployments like Vercel/Netlify + MongoDB, it greatly improved the cold start latency (6s -> <0.5s). The latency improvement largely comes from tremendous optimizations on Cloudflare workers as well as integrated environment between HTTP server and database (Cloudflare D1).

## Steps for the deployment

1. Install npm packages:
  ```shell
  npm install
  ```
2. Because the free tier of Cloudflare workers has a strict 1MiB limit on the bundle size, we need to manually delete some packages to keep the bundle within the limit. These packages can't be used anyway due to the Node.js compatibility issues of Cloudflare workers.
  ```shell
  rm -rf node_modules/tencentcloud-sdk-nodejs
  rm -rf rm -rf node_modules/jsdom
  ```
3. Login to your Cloudflare account:
  ```shell
  npx wrangler login
  ```
3. Create the Cloudflare D1 database and set up the schema:
  ```shell
  npx wrangler d1 create comment
  npx wrangler d1 execute d1 --remote --file=./schema.sql
  ```
4. Deploy the Cloudflare worker:
  ```shell
  npx wrangler deploy --minify
  ```
5. If everything works smoothly, you will see something like: `https://twikoo-cloudflare.<your user name>.workers.dev`, in the commandline. You can visit the address. If everything is set up perfectly, you're expected to see a line like that in your browser:
  ```
  {"code":100,"message":"Twikoo 云函数运行正常，请参考 https://twikoo.js.org/frontend.html 完成前端的配置","version":"1.6.33"}
  ```
6. When you set up the front set, the address in step 5 (including the `https://` prefix) should be used as the `envId` field in `twikoo.init`.

## Known limitations

Because Cloudflare workers are only [partially compatible](https://developers.cloudflare.com/workers/runtime-apis/nodejs/) with Node.js, there are certain functional limitations for the twikoo Cloudflare deployment due to compatibility issues:

1. Environment variables (`process.env.XXX`) can't be used for control the behavior of the app.
2. Tencent Cloud can't be integrated.
3. Can't find the location based on ip address (compatibility issue of the `@imaegoo/node-ip2region` package).
4. Can't send email notifications after comments are posted (compatibility issue of the `nodemailer` package).
5. Package `dompurify` can't be used to sanitize the comments due to compatibility issue of `jsdom`. Instead, we're using [`xss`](https://www.npmjs.com/package/xss) package for XSS sanitization.
6. In this deployment, we don't normalize URL path between `/some/path/` and `/some/path`. This is because it's not easy to write a Cloudflare D1 SQL query to unify these 2 kinds of paths. If your website can paths with and without the trailing `/` for the same page, you can explicitly set the `path` field in `twikoo.init`.

If you encounter any issues, or have any questions for this deployment, you can send an email to tao@vanjs.org.
