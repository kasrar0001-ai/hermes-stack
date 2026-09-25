<div align="center">

# 🛰️ Hermes Stack — One-Click AI Server on Hugging Face

**Turn one free Hugging Face Space into a real personal AI server:**
[Hermes Agent](https://github.com/NousResearch/hermes-agent) + [9Router](https://github.com/decolua/9router) + [OmniRouter](https://github.com/Godde3s/omnirouter) — with a web dashboard, an OpenAI-compatible API, Telegram control, hourly backups and auto keep-alive.

[![Deploy](https://img.shields.io/badge/Deploy%20in%205%20min-Wizard_F5B301?style=for-the-badge&labelColor=201A14)](https://godde3s.github.io/hermes-stack/deploy.html)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/Godde3s/hermes-stack/deploy-to-hf.yml?style=flat-square&label=deploy)](https://github.com/Godde3s/hermes-stack/actions/workflows/deploy-to-hf.yml)
[![Keep-alive](https://img.shields.io/github/actions/workflow/status/Godde3s/hermes-stack/keepalive.yml?style=flat-square&label=keep-alive)](https://github.com/Godde3s/hermes-stack/actions/workflows/keepalive.yml)
[![License: MIT](https://img.shields.io/github/license/Godde3s/hermes-stack?style=flat-square)](LICENSE)
[![Use this template](https://img.shields.io/badge/Use_this_template-8B6B4F?style=flat-square)](https://github.com/Godde3s/hermes-stack/generate)

[🌐 **Open the Landing Page**](https://godde3s.github.io/hermes-stack/) · [🚀 **Launch Deploy Wizard**](https://godde3s.github.io/hermes-stack/deploy.html) · [📖 Manual deploy](docs/manual-deploy.md)

</div>

---

## What you get

One free Space (2 vCPU / 16 GB RAM, no credit card) running everything behind a single Caddy front proxy:

| URL | Service |
|---|---|
| `https://<user>-<space>.hf.space/` | 🌐 Router web dashboard (model & key management) |
| `https://<user>-<space>.hf.space/v1` | 🔌 OpenAI-compatible API (use in any client) |
| `https://<user>-<space>.hf.space/hermes/` | 🧠 Agent web dashboard (basic-auth protected) |
| `https://<user>-<space>.hf.space/hermes-api/v1` | 🤖 Agent as an OpenAI-compatible API |
| `https://<user>-<space>.hf.space/healthz` | 💓 Health endpoint for keep-alive |

Plus, built in:

- **Telegram gateway** — chat with your agent from anywhere (polling, outbound-only: works behind any firewall).
- **Hourly backups** — the whole agent state is tarballed to a **private** HF dataset; restored automatically on restart. Spaces have ephemeral disks — this is the part that makes it a *real* server.
- **Keep-alive GitHub Action** — pings `/healthz` every 10 min and wakes the Space if it sleeps (~48h limit on free tier). No external cron service needed.
- **Self-healing supervisor** — every service restarts on crash with exponential backoff (no CPU-hammering crash loops that get Spaces flagged).
- **Keyless models** — OmniRouter serves ~78 free web models (Qwen, Gemini guest, …) with zero API keys.
- **Server-style customization** — `EXTRA_PIP_PACKAGES`, `EXTRA_APT_PACKAGES`, `EXTRA_NPM_PACKAGES`, `STARTUP_SCRIPT` + a persistent `/opt/data/hfkit-boot.sh` that survives restarts and is replayed at every boot.
- **Rebuild-from-nothing** — if a Space is ever disabled, the backup dataset restores your full state into a fresh Space in minutes.

## 🚀 Deploy — 3 ways (pick one)

### Way 1 — Web Wizard (easiest, Railway-style) ⭐

1. Open **[the Deploy Wizard](https://godde3s.github.io/hermes-stack/deploy.html)**.
2. Paste your GitHub PAT, Hugging Face **write** token and Telegram bot token — the wizard validates all of them live, generates strong passwords for you, creates the repo secrets, and starts the deploy.
3. Watch the Action turn green → your Space is live. Done.

> The wizard is 100% client-side (static page). Your tokens never leave your browser except to the official GitHub / Hugging Face / Telegram APIs.

### Way 2 — GitHub only (no wizard)

1. Click **[Use this template](https://github.com/Godde3s/hermes-stack/generate)** → creates your own copy.
2. In your new repo: **Settings → Secrets and variables → Actions**, add:

   | Secret | Value |
   |---|---|
   | `HF_TOKEN` | Hugging Face **write** token ([create](https://huggingface.co/settings/tokens)) |
   | `HF_USERNAME` | Your HF username |
   | `HF_SPACE_NAME` | Name for your Space (letters/digits/`-`/`_`) |
   | `TELEGRAM_BOT_TOKEN` | From [@BotFather](https://t.me/BotFather) (optional) |
   | `TELEGRAM_ALLOWED_USERS` | Your numeric Telegram ID (ask [@userinfobot](https://t.me/userinfobot)) |

3. **Actions → Deploy to Hugging Face Space → Run workflow** (leave dry-run unchecked).
4. Wait ~15–25 min for the first build. Your URLs appear in the run summary.

### Way 3 — Manual (huggingface-cli)

Follow **[docs/manual-deploy.md](docs/manual-deploy.md)**: create the Space by hand, add secrets in the UI, push `space/` with `huggingface-cli upload`.

## 🔐 Configuration reference

**Secrets** (Settings → Variables and secrets → *Secrets*) — set only what you use, never leave optional ones empty:

| Secret | Required | Purpose |
|---|---|---|
| `HF_TOKEN` | ✅ (for backups) | HF write token — hourly state backup |
| `TELEGRAM_BOT_TOKEN` | ✅ (for TG) | Bot token from @BotFather |
| `TELEGRAM_ALLOWED_USERS` | ✅ (for TG) | Comma-separated numeric IDs — **always set this**, it locks the bot to you |
| `HERMES_API_KEY` | optional | Bearer key for `/hermes-api/v1` |
| `NINEROUTER_API_KEY` | optional | Key created inside the router dashboard |
| `OMNI_ROUTER_KEY` | optional | Key for the keyless-model router (`sk-omni-…`) |
| `OMNI_ADMIN_PASSWORD` | optional | Admin password of the built-in keyless router |
| `ROUTER_INITIAL_PASSWORD` | optional | First-login password of the router dashboard |
| `DASHBOARD_USERNAME` / `DASHBOARD_PASSWORD` | optional | Basic auth for `/hermes/` |

**Variables** (plain, non-secret):

| Variable | Default | Purpose |
|---|---|---|
| `HERMES_MODEL` | — | Default model id, e.g. `gemini-2.5-flash` via the keyless router |
| `BACKUP_REPO` | `<user>/<space>-backup` | Private dataset for backups (auto-created) |
| `HERMES_TIMEZONE` | `Asia/Tehran` | Agent timezone |
| `HERMES_WEB_BACKEND` | `tavily` | Web-search backend (`tavily` keyless works out of the box) |
| `OMNI_ENABLED` | `true` | Run the keyless-model router |
| `EXTRA_PIP_PACKAGES` / `EXTRA_APT_PACKAGES` / `EXTRA_NPM_PACKAGES` | — | Space-separated packages installed at every boot |
| `STARTUP_SCRIPT` | — | Bash snippet run at every boot |

## 🗺️ Architecture

```text
                        ┌──────────────────────────────────────────────────┐
 Telegram ◄─polling─────┤             ONE FREE HF SPACE (Docker)           │
                        │                                                  │
 Browser ──► Caddy :7860├──► /              Router dashboard (Next.js)      │
 Any client ► /v1  ─────┤──► /v1           OpenAI-compatible router API    │
                        │    /hermes/      → Agent dashboard  (basic auth) │
 API clients ► /hermes-api/v1             Agent as OpenAI-compatible API  │
                        │                                                  │
 Keep-alive ► /healthz  │  supervisor: restart-on-crash + backoff          │
 (GitHub Action)        │  backup loop: hourly tar → private dataset       │
                        │  restore: automatic on boot                      │
                        └──────────────────────────────────────────────────┘
```

## 💬 Example prompts (try right after deploy)

Once the Telegram bot answers `/start`, your agent is already wired to the router's models. Good first prompts:

- *"Search the web for the latest news about Hugging Face and summarize it."*
- *"Remember that my server's dashboard is at /hermes/ and requires basic auth."*
- *"Create a Python script in my workspace that pings /healthz and prints the latency."*
- *"Use the keyless Gemini model to translate this paragraph into German: …"*
- *"What packages are installed? Install yt-dlp for me."* (with `EXTRA_PIP_PACKAGES` you can make installs persistent)

## 🛡️ Staying safe on Hugging Face (read this)

This project is designed to be a **good tenant** of the free tier — that is what keeps accounts healthy:

- ✅ **Moderate resources** — CPU-basic only, no crypto mining, no abuse. Crash-looping and runaway CPU are what actually gets Spaces flagged; the supervisor's exponential backoff exists for this reason.
- ✅ **Private by default** — mark the Space **private** (wizard checkbox / `private_space` input) and keep the backup dataset private. Your keys stay yours.
- ✅ **Locked-down bots** — `TELEGRAM_ALLOWED_USERS` must contain only your ID. An open bot relayed through HF infrastructure will get reported.
- ✅ **Polite keep-alive** — one small ping every 10 minutes to your own Space. That is normal traffic for any hosted app.
- ⚠️ **Be honest with yourself** — running an AI agent is not against HF ToS (several public projects do it), but **free Spaces are not sold as always-on servers**. Use a neutral Space name/description, don't publicly share your Space URL with an open API, and don't host anything prohibited.
- 🔁 **Recovery, not evasion** — if a Space is ever disabled, the private backup dataset restores your full state into a new Space. This project will not help you circumvent active platform enforcement — it helps you build something that doesn't get flagged in the first place.

## 🧰 Troubleshooting

| Symptom | Cause & fix |
|---|---|
| Build fails at Caddy/OmniRouter download | Transient network error — **Factory rebuild** the Space (Settings) or just re-run the deploy workflow |
| Space builds but shows "Runtime error" | Open **Logs** on the Space page; usually a missing secret — check the table above |
| Bot silent in Telegram | 1) Token wrong? 2) `TELEGRAM_ALLOWED_USERS` missing your ID? 3) Restart the Space after adding secrets |
| Dashboard 401 loop | `DASHBOARD_USERNAME`/`DASHBOARD_PASSWORD` not both set — dashboard is disabled unless both exist |
| `/hermes-api/v1` returns 401 | Send `Authorization: Bearer <HERMES_API_KEY>` |
| State lost after restart | `HF_TOKEN`/`BACKUP_REPO` missing → backups silently disabled; set both + restart |
| Build takes forever | First build pulls large base images (10–25 min). Later rebuilds are cache-hits |
| Actions scheduled jobs stopped | GitHub disables schedules after 60 repo-idle days — push any commit or re-enable the workflow |

## 📚 Docs

- [Landing page](https://godde3s.github.io/hermes-stack/) — visual overview
- [Deploy wizard](https://godde3s.github.io/hermes-stack/deploy.html) — guided setup
- [Manual deploy (فارسی)](docs/manual-deploy.md)
- [Upstream docs](https://github.com/NousResearch/hermes-agent) · [9Router](https://github.com/decolua/9router) · [OmniRouter](https://github.com/Godde3s/omnirouter)

## 🙏 Credits

Built on the shoulders of: **[Hermes Agent](https://github.com/NousResearch/hermes-agent)** (Nous Research) · **[9Router](https://github.com/decolua/9router)** (decolua) · **[OmniRouter](https://github.com/Godde3s/omnirouter)** · **[Caddy](https://caddyserver.com)**. Inspired by the UX of Railway one-click templates and by HuggingMes / HermesFace (HF Hermes deployments).

## 📄 License

MIT — see [LICENSE](LICENSE). Upstream projects keep their own licenses.

---

<div dir="rtl">

## 🇮🇷 راهنمای فارسی (خلاصه)

**در ۵ دقیقه:** به [ویزارد استقرار](https://godde3s.github.io/hermes-stack/deploy.html) برو ← توکن GitHub، توکن Write هاگین‌فیس و توکن ربات تلگرام را وارد کن ← ویزارد همه Secrets را می‌سازد و دیپلوی را شروع می‌کند. بعد از سبز شدن اکشن، آدرس‌های سرویس‌ها در خلاصه‌ی ران هست.

**آدرس‌ها:** داشبورد روتر `/` · API روتر `/v1` · داشبورد ایجنت `/hermes/` · API ایجنت `/hermes-api/v1`

**نکته‌های مهم:** به ربات فقط `/start` بده (خودت با `TELEGRAM_ALLOWED_USERS` محدودش کرده‌ای) · پکیج دائمی بخواهی `EXTRA_PIP_PACKAGES` · اگر Space خوابید، اکشن Keep-alive خودش بیدارش می‌کند · برای امنیت ماندگاری، Space را **Private** بساز و Secretها را فقط همین‌جا نگه دار.

آموزش کامل فارسی: [docs/manual-deploy.md](docs/manual-deploy.md)

</div>
