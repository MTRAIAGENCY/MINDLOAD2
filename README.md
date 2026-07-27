# مغز آرام (MindLoad)

سیستم مدیریت بار ذهنی — یک مغز خارجی آرام.

## 📱 ساخت APK به‌صورت کاملاً آنلاین (بدون نصب چیزی روی گوشی یا کامپیوتر)

این پروژه یک فایل GitHub Actions (`.github/workflows/build-apk.yml`) دارد که به‌صورت خودکار
در سرورهای گیت‌هاب، پروژه را کامپایل کرده و فایل APK می‌سازد. مراحل:

### ۱. ساخت اکانت و ریپازیتوری در گیت‌هاب
- اگر اکانت ندارید، در [github.com](https://github.com) ثبت‌نام کنید (رایگان).
- روی دکمه‌ی سبز **New** (یا `+` بالای صفحه → New repository) بزنید.
- یک اسم بدید (مثلاً `mindload`) و روی **Create repository** بزنید.
- ریپازیتوری را می‌توانید **Private** بگذارید (فقط خودتان ببینید).

### ۲. آپلود فایل‌های پروژه
- فایل زیپ این پروژه را روی کامپیوتر خودتان **Extract/استخراج** کنید (یک پوشه به اسم `mindload` می‌سازد).
- داخل صفحه‌ی ریپازیتوری خالی که ساختید، روی لینک **uploading an existing file** کلیک کنید.
- **همه‌ی فایل‌ها و پوشه‌های داخل پوشه‌ی `mindload`** (نه خودِ پوشه) را بکشید و رها کنید (drag & drop).
  - نکته: پوشه‌ی مخفی `.github` باید حتماً آپلود شود؛ اگر مرورگرتان پوشه‌های مخفی را نشان نداد،
    فایل `.github/workflows/build-apk.yml` را جداگانه در همان مسیر آپلود کنید.
- پایین صفحه دکمه‌ی **Commit changes** را بزنید.

### ۳. اجرای خودکار ساخت APK
- بعد از آپلود، خودش شروع به ساخت می‌کند. برای دیدن پیشرفت: تب **Actions** بالای صفحه‌ی ریپازیتوری را باز کنید.
- روی صفی که در حال اجراست (دایره‌ی زرد/چرخان) کلیک کنید و صبر کنید تا سبز شود (حدود ۵ تا ۱۰ دقیقه).
- اگر تب Actions چیزی نشان نداد، از همان تب روی **Run workflow** بزنید تا دستی اجرا شود.

### ۴. دانلود APK
- وقتی اجرا سبز (✅) شد، روی همان اجرا کلیک کنید.
- پایین صفحه، بخش **Artifacts** را ببینید؛ فایلی به اسم `mindload-apk` آنجاست — دانلودش کنید.
- فایل دانلودشده یک ZIP است که با باز کردنش فایل `app-release.apk` را می‌دهد.

### ۵. نصب روی گوشی اندروید
- فایل `app-release.apk` را به گوشی‌تان منتقل کنید (تلگرام به خودتان، ایمیل، یا کابل).
- روی فایل بزنید تا نصب شود. اگر پیام «از منابع ناشناس» آمد، اجازه‌ی نصب را از تنظیمات گوشی بدهید
  (این پیام فقط برای اپ‌های خارج از گوگل‌پلی است و طبیعی است).

---

## راه‌اندازی محلی (روش جایگزین، برای کسی که Flutter نصب دارد)

```bash
cd mindload
flutter create . --project-name mindload --org com.yourname
flutter pub get
flutter build apk --release
```

APK نهایی در مسیر `build/app/outputs/flutter-apk/app-release.apk` قرار می‌گیرد.

## دسترسی‌های لازم اندروید

بعد از `flutter create .`، این خطوط را به `android/app/src/main/AndroidManifest.xml`
(داخل تگ `<manifest>`، قبل از `<application>`) اضافه کنید:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
```

همچنین حداقل `minSdkVersion` را در `android/app/build.gradle` روی `21` یا بالاتر تنظیم کنید
(به دلیل استفاده از `flutter_secure_storage` و `record`).

## اجرا

```bash
flutter run
```

## تنظیم هوش مصنوعی

بعد از نصب اپ، از آیکون ⚙️ در صفحه‌ی خانه وارد «تنظیمات هوش مصنوعی» شوید و موارد زیر را وارد کنید:

- **Base URL**: آدرس API سازگار با OpenAI (مثلاً `https://api.openai.com/v1`)
- **API Key**: کلید شما
- **مدل چت**: پیش‌فرض `gpt-4o-mini`
- **مدل Whisper**: پیش‌فرض `whisper-1`

این اطلاعات فقط روی همان گوشی و به‌صورت رمزنگاری‌شده (Android Keystore) ذخیره می‌شوند و به هیچ سروری ارسال نمی‌شوند
جز مستقیماً به همان API که خودتان مشخص کرده‌اید.

## معماری

```
lib/
  core/theme/       رنگ‌ها، فونت (Vazirmatn)، ThemeData
  core/utils/        تبدیل و فرمت تاریخ شمسی
  models/            Loop, LoopType, LoopStatus, LifeArea
  database/          DatabaseHelper (SQLite)
  repositories/       LoopRepository, SettingsRepository
  services/           AiService, VoiceService, FileStorageService
  providers/          LoopProvider, ChatProvider, SettingsProvider
  screens/            صفحات اصلی اپ
  widgets/            کامپوننت‌های قابل استفاده مجدد
```

لایه‌ی Repository تنها بخشی است که مستقیماً با SQLite صحبت می‌کند؛
برای مهاجرت بعدی به PostgreSQL فقط کافی‌ست پیاده‌سازی داخل `LoopRepository`
تغییر کند — مدل‌ها، Providerها و UI بدون تغییر باقی می‌مانند.

## نکات مهم V1

- بدون لاگین، بدون کلاود‌سینک، فقط برای یک کاربر
- هرگز عدد کل موارد باز نمایش داده نمی‌شود (طبق فلسفه‌ی اپ)
- تشخیص «تنها اقدام بعدی» بر اساس نزدیک‌ترین موعد سررسید انجام می‌شود؛ در نبود AI،
  متن خام کاربر به‌عنوان یک Task ساده ذخیره می‌شود تا هیچ داده‌ای گم نشود
- OCR روی تصاویر و پردازش محتوای PDF در V1 پیاده‌سازی نشده (طبق اسپک، «بعداً»)
