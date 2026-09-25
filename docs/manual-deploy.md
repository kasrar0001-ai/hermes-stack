# 🛠 استقرار دستی — بدون ویزارد

> اگر به هر دلیلی نمی‌خواهی از [ویزارد وب](https://godde3s.github.io/hermes-stack/deploy.html) استفاده کنی، همین راهنما کل مسیر را قدم‌به‌قدم پوشش می‌دهد. نتیجه‌ی نهایی هر دو راه یکسان است.

## ۰) پیش‌نیازها

- اکانت رایگان [Hugging Face](https://huggingface.co/join)
- اکانت گیت‌هاب (همین ریپو را fork می‌کنی یا فایل‌ها را آپلود می‌کنی)
- ربات تلگرام: در [@BotFather](https://t.me/BotFather) با `/newbot` بساز و توکن را نگه دار
- آیدی عددی خودت در تلگرام (از [@userinfobot](https://t.me/userinfobot))
- یک توکن **Write** از [تنظیمات HF](https://huggingface.co/settings/tokens)

## ۱) ساخت Space

1. در هاگینگ‌فیس: **New Space** → نام دلخواه (مثلاً `hermes-stack`)
2. SDK را روی **Docker** بگذار → **Blank** template → Public
3. در تب **Files** همین سه چیز را از پوشه‌ی [`space/`](../space/) این ریپو آپلود کن:
   - `README.md` (متادیتای `sdk: docker` و `app_port: 7860` را دارد — دست نزن)
   - `Dockerfile`
   - `Caddyfile`
   - پوشه‌ی `hfkit/` با تمام محتویاتش
4. Build خودکار شروع می‌شود؛ چون دو ایمیج بزرگ دانلود می‌کند **۱۰ تا ۲۵ دقیقه** صبر کن.

## ۲) Secrets و Variables

در **Settings → Variables and secrets** این‌ها را بساز (نوع سمت چپ):

| نام | نوع | مقدار |
|---|---|---|
| `TELEGRAM_BOT_TOKEN` | Secret | توکن BotFather |
| `TELEGRAM_ALLOWED_USERS` | Secret | آیدی‌های عددی مجاز، با کاما |
| `NINEROUTER_API_KEY` | Secret | هر رشته‌ی قوی — بعداً در داشبورد ۹روتر همان را می‌سازی |
| `HERMES_API_KEY` | Secret | کلید دلخواه برای API عامل (مثل `hs-…`) |
| `DASHBOARD_USERNAME` / `DASHBOARD_PASSWORD` | Secret | ورود به داشبورد وب هرمس |
| `ROUTER_INITIAL_PASSWORD` | Secret | رمز اولین ورود داشبورد ۹روتر |
| `OMNI_ROUTER_KEY` | Secret | کلید دلخواه OmniRouter (مثل `sk-omni-…`) |
| `OMNI_ADMIN_PASSWORD` | Secret | رمز ادمین OmniRouter |
| `HF_TOKEN` | Secret | همان توکن Write (برای بکاپ/ریستور) |
| `BACKUP_REPO` | Variable | `نام‌کاربری/نام-دیتاست` — دیتاست **خصوصی** بساز |
| `HERMES_MODEL` | Variable | آیدی مدل از تب Models داشبورد ۹روتر (مثل `kiro-claude-sonnet-4.5`) |
| `HERMES_TIMEZONE` | Variable | `Asia/Tehran` |
| `OMNI_ENABLED` | Variable | `true` (برای غیرفعال‌کردن OmniRouter: `false`) |
| `HERMES_WEB_BACKEND` | Variable | `tavily` — بدون کلید کار می‌کند |

بعد از ست‌کردن‌ها یک بار **Restart Space** بزن تا همه‌شان خوانده شوند.

## ۳) راه alternative با GitHub Actions

به‌جای آپلود دستی فایل‌ها می‌توانی از اتوماسیون همین ریپو استفاده کنی:

1. این ریپو را **fork** کن (یا از قالب بساز)
2. در تب **Settings → Secrets and variables → Actions** این سه را بساز: `HF_TOKEN`، `HF_USERNAME`، `HF_SPACE_NAME` + جدول سکرت‌های بالا
3. تب **Actions** → «🚀 Deploy to Hugging Face Space» → **Run workflow**

ورک‌فلو خودش Space و دیتاست بکاپ را می‌سازد، سکرت‌ها را داخل Space ست می‌کند، فایل‌ها را آپلود می‌کند و تا سبز شدن صبر می‌کند.

## ۴) اولین استفاده

| سرویس | آدرس | ورود |
|---|---|---|
| داشبورد ۹روتر | `https://USER-SPACE.hf.space/` | هر یوزر + `ROUTER_INITIAL_PASSWORD` |
| API مدل‌های ۹روتر | `…/v1` | با `NINEROUTER_API_KEY` |
| داشبورد وب هرمس | `…/hermes/` | `DASHBOARD_USERNAME` / `DASHBOARD_PASSWORD` |
| API عامل هرمس | `…/hermes-api/v1` | با `HERMES_API_KEY` |

1. در تلگرام به ربات `/start` بده — باید جواب بدهد
2. در داشبورد ۹روتر یک API key با همان مقدار `NINEROUTER_API_KEY` بساز و اکانت‌های رایگان را وصل کن
3. مطمئن شو `HERMES_MODEL` دقیقاً با یکی از آیدی‌های تب Models یکی است
4. برای روشن‌ماندن Space: در [cron-job.org](https://cron-job.org) یک Cron هر ۵ دقیقه به آدرس Space بساز

## ۵) نکته‌های مهم

- تغییر هر Secret/Variable → فقط **Restart Space** (Factory reboot نزن؛ اگر زدی بکاپ خودش برمی‌گرداند)
- بکاپ هر ساعت + ۵ دقیقه بعد از بوت: `latest.tar.gz` + نگهداری ۷۲ ساعت نسخه‌ی ساعتی
- لاگ‌های هر سرویس: `/opt/data/logs/` داخل کانتینر (از لاگ‌های خود HF هم دیدنی است)
- اولین پیام بعد از ری‌استارت ممکن است چند دقیقه طول بکشد (restore + اتصال سرویس‌ها)

## ۶) عیب‌یابی سریع

| مشکل | راه‌حل |
|---|---|
| Build می‌افتد | لاگ Build در تب Logs ببین؛ معمولاً قطعی موقت CDN است — دوباره Factory rebuild |
| ربات جواب نمی‌دهد | توکن را چک کن؛ `TELEGRAM_ALLOWED_USERS` باید آیدی عددی خودت باشد؛ Restart |
| هرمس مدلی پیدا نمی‌کند | `HERMES_MODEL` باید با آیدی تب Models داشبورد ۹روتر **دقیقاً** یکی باشد |
| داشبورد هرمس لاگین نمی‌شود | `DASHBOARD_USERNAME`/`PASSWORD` هر دو باید ست باشند؛ سپس Restart |
| Space خوابیده | یک GET به آدرس Space بزن یا Cron داشته باش؛ بکاپ ۵ دقیقه بعد از بوت برمی‌گردد |
| بکاپ آپلود نمی‌شود | `HF_TOKEN` باید نقش Write داشته باشد و `BACKUP_REPO` با فرمت `user/dataset` |
