<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

## News App (Laravel API + Flutter)

This repository contains the **Laravel 12 JSON API** (categories, posts, image uploads to `storage/app/public`) and the **Flutter** admin/user client in `news_app/`.

### Why images broke (and what fixes it)

- Post rows store a relative path such as `posts/abc.jpg`.
- Laravel serves files from **`public/storage`** → symlink to **`storage/app/public`**. Without the link, `/storage/posts/...` returns 404.
- The API now also returns **`image_url`** (full URL built from `APP_URL`) so clients can load images reliably.
- The Flutter app **must use the same API host** for JSON and for `image_url` (no more hard-coded Railway URLs in screens).

### Localhost — backend

1. Copy `.env.example` to `.env` and run `php artisan key:generate`.
2. Set **`APP_URL=http://127.0.0.1:8000`** (include the port you use with `php artisan serve`).
3. Run migrations: `php artisan migrate`.
4. **Create the storage symlink:** `php artisan storage:link` (also runs from `composer run-script setup` and `start.sh` on Railway).
5. Seed admin (if you use the included seeder): `php artisan db:seed`.
6. Start API: `php artisan serve` → API base `http://127.0.0.1:8000/api`.

### Localhost — Flutter (`news_app`)

Default API base is **`http://127.0.0.1:8000/api`** (see `lib/services/api_service.dart`).

- **Chrome / desktop:**  
  `flutter run --dart-define=BASE_URL=http://127.0.0.1:8000/api`
- **Android emulator** (host machine loopback):  
  `flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api`  
  and set **`.env` `APP_URL=http://10.0.2.2:8000`** so `image_url` matches what the emulator can reach.  
  *Alternative:* keep `APP_URL` as `127.0.0.1` and run `adb reverse tcp:8000 tcp:8000`, then use `http://127.0.0.1:8000/api` in Flutter.
- **Physical device on same Wi‑Fi:** use your PC’s LAN IP, e.g.  
  `flutter run --dart-define=BASE_URL=http://192.168.1.50:8000/api`  
  and **`APP_URL=http://192.168.1.50:8000`**.

Cleartext HTTP for dev is allowed via `android/app/src/main/res/xml/network_security_config.xml` and iOS `NSAllowsLocalNetworking` in `ios/Runner/Info.plist`.

### Production (Railway)

1. Set **`APP_URL`** to your public HTTPS origin (no trailing slash), e.g. `https://your-service.up.railway.app`.
2. Ensure **`php artisan storage:link`** runs on deploy (`Procfile` / `start.sh` already include it).
3. Build Flutter with:  
   `flutter build apk --release --dart-define=BASE_URL=https://your-service.up.railway.app/api`

Protected routes: **`POST /api/categories`**, **`POST /api/posts`**, **`DELETE /api/posts/{id}`** require a Sanctum **Bearer** token for an **admin** user.

---

<p align="center">
<a href="https://github.com/laravel/framework/actions"><img src="https://github.com/laravel/framework/workflows/tests/badge.svg" alt="Build Status"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/dt/laravel/framework" alt="Total Downloads"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/v/laravel/framework" alt="Latest Stable Version"></a>
<a href="https://packagist.org/packages/laravel/framework"><img src="https://img.shields.io/packagist/l/laravel/framework" alt="License"></a>
</p>

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects, such as:

- [Simple, fast routing engine](https://laravel.com/docs/routing).
- [Powerful dependency injection container](https://laravel.com/docs/container).
- Multiple back-ends for [session](https://laravel.com/docs/session) and [cache](https://laravel.com/docs/cache) storage.
- Expressive, intuitive [database ORM](https://laravel.com/docs/eloquent).
- Database agnostic [schema migrations](https://laravel.com/docs/migrations).
- [Robust background job processing](https://laravel.com/docs/queues).
- [Real-time event broadcasting](https://laravel.com/docs/broadcasting).

Laravel is accessible, powerful, and provides tools required for large, robust applications.

## Learning Laravel

Laravel has the most extensive and thorough [documentation](https://laravel.com/docs) and video tutorial library of all modern web application frameworks, making it a breeze to get started with the framework. You can also check out [Laravel Learn](https://laravel.com/learn), where you will be guided through building a modern Laravel application.

If you don't feel like reading, [Laracasts](https://laracasts.com) can help. Laracasts contains thousands of video tutorials on a range of topics including Laravel, modern PHP, unit testing, and JavaScript. Boost your skills by digging into our comprehensive video library.

## Laravel Sponsors

We would like to extend our thanks to the following sponsors for funding Laravel development. If you are interested in becoming a sponsor, please visit the [Laravel Partners program](https://partners.laravel.com).

### Premium Partners

- **[Vehikl](https://vehikl.com)**
- **[Tighten Co.](https://tighten.co)**
- **[Kirschbaum Development Group](https://kirschbaumdevelopment.com)**
- **[64 Robots](https://64robots.com)**
- **[Curotec](https://www.curotec.com/services/technologies/laravel)**
- **[DevSquad](https://devsquad.com/hire-laravel-developers)**
- **[Redberry](https://redberry.international/laravel-development)**
- **[Active Logic](https://activelogic.com)**

## Contributing

Thank you for considering contributing to the Laravel framework! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
