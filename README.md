# 🛡️ PhishEye – AI-Based Phishing Detection Platform

A production-ready **Flutter** application for detecting phishing attacks in URLs and email/SMS messages. Built with clean architecture, Supabase backend, Riverpod state management, and a sleek cybersecurity dark theme.

---

## 📱 Features

| Feature | Description |
|---------|-------------|
| 🔐 Auth | Supabase email/password authentication |
| 🔗 URL Scanner | Heuristic analysis of URLs (10 risk checks) |
| 📧 Email Scanner | Phishing pattern detection in messages |
| 📊 Dashboard | Analytics with pie chart, stats, recent scans |
| 🗂️ History | Full scan history with delete support |
| 🔒 RLS | Row-level security – users see only their data |
| 🌑 Dark Theme | Cybersecurity aesthetic with neon accents |

---

## 🏗️ Architecture

```
lib/
├── core/
│   ├── constants/        # App-wide constants, phishing keywords
│   ├── router/           # GoRouter navigation
│   ├── theme/            # Dark cybersecurity theme
│   ├── utils/            # Failures, Supabase provider
│   └── widgets/          # Shared UI components, MainShell
└── features/
    ├── auth/
    │   ├── data/          # AuthRepositoryImpl (Supabase)
    │   ├── domain/        # UserEntity, AuthRepository interface
    │   └── presentation/  # Login, Register, Splash pages + AuthProvider
    ├── dashboard/
    │   └── presentation/  # DashboardPage with charts
    ├── url_scan/
    │   ├── domain/        # PhishingDetectionService
    │   └── presentation/  # UrlScanPage + UrlScanProvider
    ├── email_scan/
    │   └── presentation/  # EmailScanPage + EmailScanProvider
    └── history/
        ├── data/          # ScanModel, ScanRemoteDataSource, ScanRepositoryImpl
        ├── domain/        # ScanEntity, ScanResultEntity, ScanRepository
        └── presentation/  # HistoryPage + HistoryProvider
```

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK ≥ 3.22 (stable channel)
- Dart SDK ≥ 3.0
- A [Supabase](https://supabase.com) account (free tier works)
- Android Studio / VS Code with Flutter extension

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/phisheye.git
cd phisheye
```

### 2. Set Up Supabase

1. Go to [supabase.com](https://supabase.com) → New project
2. Open **SQL Editor** and run `supabase/schema.sql`
3. Copy your **Project URL** and **anon public key** from:
   - Settings → API → Project URL & API Keys

### 3. Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 4. Install Fonts

Download and place in `assets/fonts/`:
- [Space Mono](https://fonts.google.com/specimen/Space+Mono) – Regular, Bold
- [Rajdhani](https://fonts.google.com/specimen/Rajdhani) – Regular, Medium, SemiBold, Bold

### 5. Run the App

```bash
flutter pub get
flutter run
```

---

## ⚙️ CI/CD – GitHub Actions

The workflow at `.github/workflows/ci.yml` automatically:

1. Sets up Flutter 3.22.2 (stable)
2. Creates `.env` from GitHub Secrets
3. Runs `flutter pub get`
4. Runs `dart format` check
5. Runs `flutter analyze`
6. Runs `flutter test`
7. Builds debug APK
8. Uploads APK as artifact (14-day retention)
9. Builds release AAB on `main` branch pushes

### Add GitHub Secrets

Go to your repo → **Settings → Secrets and variables → Actions** → add:

| Secret | Value |
|--------|-------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_ANON_KEY` | Your Supabase anon key |

---

## 🧠 Phishing Detection Algorithm

### URL Analysis (10 checks)

| Check | Points | Description |
|-------|--------|-------------|
| HTTP instead of HTTPS | +15 | Insecure connection |
| Long URL (>100 chars) | +15 | Obfuscation |
| Raw IP address | +25 | No domain name |
| Suspicious TLD | +20 | .xyz, .tk, .ml, etc. |
| Brand impersonation | +20 | paypal, amazon in non-trusted domain |
| Suspicious keywords | +8–20 | login, verify, confirm, etc. |
| Excessive subdomains | +15 | >4 subdomain levels |
| Encoded characters | +15 | %xx or @ in URL |
| Hyphen abuse | +10 | 3+ hyphens in domain |
| Trusted whitelist | −10 | google.com, github.com, etc. |

### Email Analysis (8 checks)

| Check | Points | Description |
|-------|--------|-------------|
| Urgency language | +10–25 | "act now", "immediately" |
| Phishing phrases | +15–30 | "verify your account", etc. |
| Excessive URLs | +15 | >3 links |
| PII requests | +20 | SSN, credit card, PIN |
| Generic greeting | +10 | "dear customer" |
| Threats | +20 | "account will be closed" |
| Prize lures | +20 | "you have won" |
| Very short text | +5 | Limited analysis |

**Risk Score Interpretation:**
- 🟢 **0–29**: SAFE
- 🟡 **30–59**: SUSPICIOUS
- 🔴 **60–100**: DANGER

---

## 🗄️ Supabase Schema

```sql
scans (
  id          UUID PRIMARY KEY,
  user_id     UUID REFERENCES auth.users,
  input       TEXT,        -- URL or message content
  type        TEXT,        -- 'url' or 'email'
  risk_score  INTEGER,     -- 0–100
  result      TEXT,        -- JSON: verdict, flags, safePoints, summary
  created_at  TIMESTAMPTZ
)
```

**Row Level Security:** Each user can only SELECT, INSERT, DELETE their own rows.

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Auth + Database |
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `fl_chart` | Pie chart analytics |
| `flutter_animate` | Smooth animations |
| `flutter_dotenv` | Environment variables |
| `intl` | Date formatting |

---

## 📁 Zip & Push to GitHub

```bash
# Zip the project (excluding build artifacts)
cd ..
zip -r phisheye.zip phisheye \
  --exclude "*/build/*" \
  --exclude "*/.dart_tool/*" \
  --exclude "*/.pub-cache/*" \
  --exclude "*/node_modules/*"

# Push to GitHub
cd phisheye
git init
git add .
git commit -m "feat: initial PhishEye implementation"
git remote add origin https://github.com/your-username/phisheye.git
git push -u origin main
```

---

## 🔒 Security Notes

- Never commit `.env` (it's in `.gitignore`)
- Use GitHub Secrets for CI/CD credentials
- Supabase RLS ensures data isolation between users
- All API calls use HTTPS (enforced via `network_security_config.xml`)

---

## 📄 License

MIT License – See [LICENSE](LICENSE) for details.
