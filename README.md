# References
- **Cloudflare Docs:** https://developers.cloudflare.com/agents/guides/remote-mcp-server/

# Guide
## Setup
- Initialize **package.json**
    > `npm init -y`
- Start up container
    > `docker compose up -d`

## Create MCP Server
- Create using Cloudflare template
    > `npm create cloudflare@latest -- mcp-server-auth --template=cloudflare/ai/demos/remote-mcp-github-oauth`

### Setup Bindings
- **Durable Object** in `wrangler.jsonc`
    - A tiny “session keeper” for your MCP server’s OAuth process. Each object stores the ongoing login steps (like codes or counters) at the edge so no data gets lost while users authorize.
    > ```json
    > "durable_objects": {
    >     "bindings": [
    >         {
    >             "class_name": "MyMCP", // TS class from index.ts
    >             "name": "MCP_OBJECT"   // env binding
    >         }
    >     ]
    > },
    > ```

- **Worker AI** in `wrangler.jsonc`
    - An on‑edge “AI helper” named env.AI. During OAuth you can ask it to analyze requests, craft messages, or summarize user consent—using GPU‑powered AI right next to your auth code.
    > ```json
    > "ai": {
    >     "binding": "AI"
    > },
    > ```

- **KV Namspace** in `wrangler.jsonc`
    - A “shared token jar” called OAUTH_KV that every edge server can use. You put OAuth tokens or consent flags in it, and any server can later grab them.
    - **TO DO:** Must create KV Namespace & update ID below.
    > ```json
    > "kv_namespaces": [
    >     {
    >         "binding": "OAUTH_KV",
    >         "id": "<YOUR_KV_NAMESPACE_ID>"
    >     }
    > ],
    > ```

## MCP Inspector
- Run inspector
    > `npx @modelcontextprotocol/inspector`

## Deploy CF Worker (Part 1)
- Set CF account ID to **wrangler.jsonc**
    > `"account_id": "95437c835139b228336df1913750ad6e"`
- Set CF API key in env
    - API's permission template: `Edit Cloudflare Workers`
    - ENV: `CLOUDFLARE_API_TOKEN=<API-KEY-HERE>`
- Deploy worker to CF
    - `npm run deploy` OR `npx wrangler deploy`

# Create Github OAuth App
- Go to `Github` -> `Settings` -> `Developers Settings` -> `OAuth Apps`
- Create for `local`
    - **Application name:** `mcp-server-auth-dev`
    - **Homepage URL:** `http://localhost:8787`
    - **Authorization callback URL:** `http://localhost:8787/callback`
- Create for `production`
    - **TO DO:** Update CLOUDFLARE_WORKER_URL below
        - **Application name:** `mcp-server-auth-prod`
        - **Homepage URL:** `<CLOUDFLARE_WORKER_URL>`
        - **Authorization callback URL:** `<CLOUDFLARE_WORKER_URL>/callback`

## Run Local Dev Server
- Set secret variable
    - Create `.dev.vars` file
    - **TO DO:** Update GITLAB_OAUTH_CLIENT_ID & GITLAB_OAUTH_CLIENT_SECRET below
    > ```properties
    > GITHUB_CLIENT_ID="<GITLAB_OAUTH_CLIENT_ID>"
    > GITHUB_CLIENT_SECRET="<GITLAB_OAUTH_CLIENT_SECRET>"
    > COOKIE_ENCRYPTION_KEY="<RANDOM_STRING>"
    > ```
- Update to use `wrangler dev --ip 0.0.0.0 --port 8787` IP in **package.json**
- Port mapping `8787:8787` in **docker-compose.yml**
- `npm start` OR `wrangler dev --ip 0.0.0.0 --port 8787`
- Ready to test via MCP Inspector

## Deploy CF Worker (Part 2)
- Set secret variable
    - **TO DO:** Update GITLAB_OAUTH_CLIENT_ID & GITLAB_OAUTH_CLIENT_SECRET below
    > ```
    > npx wrangler secret put GITHUB_CLIENT_ID
    > npx wrangler secret put GITHUB_CLIENT_SECRET
    > npx wrangler secret put COOKIE_ENCRYPTION_KEY
    > ```
- Ready to test via MCP Inspector