# Góc Phim — Epics & User Stories

> **Dựa trên:** [PRD](prd.md) | [Architecture](architecture.md)
> **Date:** 2026-08-04 | **Priority:** Must > Should > Could

---

## Sprint Order (Recommended)

```
Epic 1 (Foundation) → Epic 2 (Auth) → Epic 3 (Home) 
→ Epic 4 (Movie Detail) → Epic 5 (Search) 
→ Epic 6 (Watchlist) → Epic 7 (Reviews & Rec) → Epic 8 (Profile)
```

---

## EPIC 1 — Foundation & Setup

> Thiết lập nền tảng kỹ thuật trước khi implement features.

### Story 1.1 — Setup dự án Flutter + BLoC
**As a** developer,
**I want** project được cấu trúc Clean Architecture + BLoC,
**So that** code maintainable, testable, và scalable.

**Acceptance Criteria:**
- [x] Cập nhật `pubspec.yaml` với đầy đủ dependencies (flutter_bloc, get_it, injectable, go_router, dio, supabase_flutter, hive, dartz)
- [x] Cấu trúc thư mục theo spec trong Architecture doc
- [x] `flutter pub get` chạy thành công, không lỗi conflict
- [x] `build_runner` generate injection code thành công

**Story Points:** 3

---

### Story 1.2 — Network Layer (Dio + TMDB)
**As a** developer,
**I want** Dio client được cấu hình sẵn với TMDB API,
**So that** các feature có thể gọi API ngay mà không cần setup lại.

**Acceptance Criteria:**
- [x] `DioClient` singleton với base URL `https://api.themoviedb.org/3`
- [x] API key inject qua `--dart-define=TMDB_API_KEY=xxx` (không hardcode)
- [x] `ErrorInterceptor` parse lỗi 4xx/5xx → `ServerFailure`
- [x] Timeout 10 giây cho connect và receive
- [x] `ImageUrlHelper` build URL ảnh từ path (e.g. `/poster_path.jpg` → full URL)

**Story Points:** 3

---

### Story 1.3 — Supabase Setup
**As a** developer,
**I want** Supabase được init và sẵn sàng dùng,
**So that** Auth và Database feature hoạt động.

**Acceptance Criteria:**
- [x] `Supabase.initialize()` trong `main.dart` với env variables
- [x] Tạo 3 tables trên Supabase: `profiles`, `watchlist`, `reviews`
- [x] RLS policies đúng theo schema trong Architecture doc
- [x] Kết nối test thành công (có thể dùng `supabase.from('profiles').select()`)

**Story Points:** 3

---

### Story 1.4 — Navigation (GoRouter)
**As a** developer,
**I want** navigation được setup với GoRouter,
**So that** routing giữa các màn hình hoạt động đúng, có auth guard.

**Acceptance Criteria:**
- [ ] Tất cả routes định nghĩa trong `route_names.dart`
- [ ] Auth guard: chưa login → redirect về `/login`
- [ ] Đã login → không vào được `/login`, `/register`
- [ ] Named routes dùng được từ bất kỳ đâu
- [ ] Deep link `/movie/:id` hoạt động

**Story Points:** 3

---

### Story 1.5 — Theme & Design System
**As a** developer,
**I want** ThemeData dark/light và color palette được định nghĩa,
**So that** UI nhất quán toàn app.

**Acceptance Criteria:**
- [ ] Dark theme mặc định với màu chủ đạo (cinema-inspired: dark navy, gold accent)
- [ ] Light theme (secondary)
- [ ] Typography scale: Display, Headline, Body, Label
- [ ] Color tokens: primary, secondary, surface, error, onSurface...
- [ ] Theme toggle lưu vào SharedPreferences

**Story Points:** 2

---

### Story 1.6 — Dependency Injection Setup
**As a** developer,
**I want** get_it + injectable được cấu hình,
**So that** BLoCs và repositories được inject đúng cách.

**Acceptance Criteria:**
- [ ] `configureDependencies()` gọi trong `main.dart`
- [ ] Dio, SupabaseClient, DataSources, Repositories, UseCases, BLoCs đăng ký đủ
- [ ] BLoC inject được vào widget qua `BlocProvider` + `getIt<XxxBloc>()`
- [ ] Không có circular dependency

**Story Points:** 2

---

## EPIC 2 — Authentication

> FR-A01 đến FR-A06

### Story 2.1 — Màn hình Login
**As a** user,
**I want** đăng nhập bằng email + password,
**So that** tôi truy cập được tính năng cá nhân hóa.

**Acceptance Criteria:**
- [ ] UI: Logo, email field, password field (toggle hiện/ẩn), nút Login, link Register, link Forgot Password
- [ ] Validate: email format, password ≥ 6 ký tự
- [ ] Gọi `LoginUseCase` → Supabase Auth
- [ ] Loading state trong khi gọi API
- [ ] Error message rõ ràng khi sai credentials
- [ ] Sau login thành công → navigate về Home
- [ ] `FR-A02`

**Story Points:** 5

---

### Story 2.2 — Màn hình Register
**As a** new user,
**I want** đăng ký tài khoản mới,
**So that** tôi có thể dùng app.

**Acceptance Criteria:**
- [ ] UI: email, password, confirm password fields
- [ ] Validate: email hợp lệ, password khớp, ≥ 6 ký tự
- [ ] Gọi `RegisterUseCase` → Supabase Auth
- [ ] Sau đăng ký thành công → tạo profile record trong `profiles` table
- [ ] `FR-A01`

**Story Points:** 3

---

### Story 2.3 — Forgot Password
**As a** user,
**I want** reset password qua email,
**So that** tôi không mất tài khoản khi quên mật khẩu.

**Acceptance Criteria:**
- [ ] Input email → gửi reset link qua Supabase
- [ ] Thông báo "Check your email" sau khi gửi
- [ ] `FR-A04`

**Story Points:** 2

---

### Story 2.4 — Auto-Login & Splash
**As a** returning user,
**I want** app nhớ đăng nhập của tôi,
**So that** không phải login mỗi lần mở app.

**Acceptance Criteria:**
- [ ] `SplashPage` check Supabase session
- [ ] Có session → navigate Home
- [ ] Không có session → navigate Login
- [ ] Splash hiện logo + animation ≤ 2 giây
- [ ] `FR-A05`

**Story Points:** 2

---

## EPIC 3 — Home Screen

> FR-H01 đến FR-H07

### Story 3.1 — Banner Trending (Carousel)
**As a** user,
**I want** thấy phim trending ngay khi mở app,
**So that** tôi biết phim nào đang hot tuần này.

**Acceptance Criteria:**
- [ ] `CarouselSlider` auto-play với backdrop + title + rating
- [ ] Chấm indicator bên dưới
- [ ] Tap → navigate Movie Detail
- [ ] Dùng `GetTrendingMoviesUseCase` → TMDB `/trending/movie/week`
- [ ] Shimmer loading khi đang fetch
- [ ] `FR-H01`, `FR-H07`

**Story Points:** 5

---

### Story 3.2 — Section Now Playing & Popular
**As a** user,
**I want** xem danh sách phim đang chiếu và phổ biến,
**So that** tôi có nhiều lựa chọn để khám phá.

**Acceptance Criteria:**
- [ ] 2 sections ngang (horizontal scroll): "Đang Chiếu" và "Phổ Biến"
- [ ] Mỗi section: 10 phim (1 page), lazy load thêm khi scroll đến cuối
- [ ] `MovieCard` widget: poster, title, rating
- [ ] Tap card → Movie Detail
- [ ] `FR-H02`, `FR-H03`

**Story Points:** 5

---

### Story 3.3 — Pull-to-Refresh & Error State
**As a** user,
**I want** refresh Home và thấy thông báo lỗi rõ ràng,
**So that** tôi kiểm soát được nội dung.

**Acceptance Criteria:**
- [ ] `RefreshIndicator` bao toàn bộ Home scroll
- [ ] Khi mất mạng: empty state + nút Retry
- [ ] Refresh thành công: dữ liệu mới hiện ra
- [ ] `FR-H06`

**Story Points:** 2

---

### Story 3.4 — Bottom Navigation Bar
**As a** user,
**I want** điều hướng nhanh giữa các tab chính,
**So that** trải nghiệm liền mạch.

**Acceptance Criteria:**
- [ ] 4 tabs: Home, Search, Watchlist, Profile
- [ ] Icon + label rõ ràng
- [ ] Tab được highlight khi active
- [ ] State giữ nguyên khi switch tab (không reload)

**Story Points:** 2

---

## EPIC 4 — Movie Detail

> FR-D01 đến FR-D11

### Story 4.1 — Trang chi tiết cơ bản
**As a** user,
**I want** xem đầy đủ thông tin về một bộ phim,
**So that** tôi quyết định được có muốn xem không.

**Acceptance Criteria:**
- [ ] Backdrop ảnh lớn với gradient overlay
- [ ] Poster nhỏ + Title + Tagline + Genres + Runtime + Release Date
- [ ] TMDB rating (sao + điểm số + số votes)
- [ ] Overview text (expandable nếu dài)
- [ ] `FR-D01`, `FR-D02`, `FR-D03`, `FR-D04`

**Story Points:** 5

---

### Story 4.2 — Cast List
**As a** user,
**I want** xem diễn viên trong phim,
**So that** tôi biết ai diễn.

**Acceptance Criteria:**
- [ ] Horizontal scroll list avatar (tròn) + tên + vai diễn
- [ ] Fetch từ TMDB `/movie/{id}/credits`
- [ ] Hiển thị top 10 cast
- [ ] `FR-D05`

**Story Points:** 3

---

### Story 4.3 — Xem Trailer
**As a** user,
**I want** xem trailer phim ngay trong app,
**So that** không cần mở YouTube.

**Acceptance Criteria:**
- [ ] Nút "▶ Xem Trailer" hiện nổi bật
- [ ] Dùng `youtube_player_flutter` embed YouTube video
- [ ] Hỗ trợ fullscreen
- [ ] Fallback: "Không có trailer" nếu TMDB không trả về video
- [ ] `FR-D06`, `FR-T01`, `FR-T02`, `FR-T03`

**Story Points:** 5

---

### Story 4.4 — Thêm/Xoá Yêu Thích từ Detail
**As a** user,
**I want** bookmark phim ngay từ trang detail,
**So that** tôi lưu để xem sau.

**Acceptance Criteria:**
- [ ] Nút tim (♡ / ♥) toggle trạng thái yêu thích
- [ ] Trạng thái đồng bộ với WatchlistBloc
- [ ] Không cần đăng nhập để lưu offline (Hive)
- [ ] Nếu đã login → sync lên Supabase
- [ ] `FR-D08`, `FR-W01`

**Story Points:** 3

---

### Story 4.5 — Similar Movies
**As a** user,
**I want** xem phim tương tự,
**So that** tôi khám phá thêm phim liên quan.

**Acceptance Criteria:**
- [ ] Section "Phim Tương Tự" cuối trang
- [ ] Horizontal scroll MovieCards
- [ ] Fetch từ `/movie/{id}/similar`
- [ ] `FR-D07`, `FR-REC01`

**Story Points:** 2

---

## EPIC 5 — Search & Filter

> FR-S01 đến FR-S07

### Story 5.1 — Search Bar với Debounce
**As a** user,
**I want** tìm phim bằng tên,
**So that** tôi tìm được phim cụ thể.

**Acceptance Criteria:**
- [ ] Search bar chiếm đầu màn hình
- [ ] Debounce 500ms (không gọi API mỗi phím)
- [ ] Kết quả grid 2 cột khi có query
- [ ] Empty state khi không tìm thấy
- [ ] Clear button khi có text
- [ ] `FR-S01`, `FR-S02`

**Story Points:** 5

---

### Story 5.2 — Filter & Sort
**As a** user,
**I want** lọc phim theo thể loại, năm, và điểm,
**So that** tôi tìm đúng loại phim mình muốn.

**Acceptance Criteria:**
- [ ] Filter bottom sheet với: Genre chips, Year range slider (1980–năm hiện tại), Min rating slider
- [ ] Sort: Popularity / Rating / Release Date (Newest/Oldest)
- [ ] Kết hợp search + filter cùng lúc
- [ ] Badge hiện số filter đang active
- [ ] `FR-S03`, `FR-S04`, `FR-S05`, `FR-S06`

**Story Points:** 5

---

## EPIC 6 — Watchlist / Yêu Thích

> FR-W01 đến FR-W05

### Story 6.1 — Xem và Quản lý Watchlist
**As a** user,
**I want** xem và quản lý danh sách phim yêu thích,
**So that** tôi track được phim muốn xem và đã xem.

**Acceptance Criteria:**
- [ ] List phim đã lưu (poster + title + năm)
- [ ] Swipe để xoá
- [ ] Checkbox "Đã xem" per item
- [ ] Empty state khi chưa có phim nào
- [ ] Hoạt động offline (Hive)
- [ ] `FR-W01`, `FR-W02`, `FR-W04`

**Story Points:** 5

---

### Story 6.2 — Sync Watchlist lên Supabase
**As a** logged-in user,
**I want** watchlist đồng bộ giữa các thiết bị,
**So that** không mất dữ liệu khi đổi máy.

**Acceptance Criteria:**
- [ ] Khi login → merge local Hive list với Supabase
- [ ] Mỗi thay đổi → write cả local và remote
- [ ] Offline → chỉ write local, sync khi có mạng
- [ ] `FR-W03`

**Story Points:** 5

---

## EPIC 7 — Reviews & Recommendations

> FR-R01 đến FR-REC02

### Story 7.1 — Xem Reviews
**As a** user,
**I want** đọc review của người khác về một phim,
**So that** tôi có thêm góc nhìn trước khi xem.

**Acceptance Criteria:**
- [ ] Tab "Reviews" trong Movie Detail
- [ ] List card: avatar + tên user + rating + nội dung + ngày
- [ ] Phân trang (load more khi scroll)
- [ ] `FR-R01`

**Story Points:** 3

---

### Story 7.2 — Viết / Sửa / Xoá Review
**As a** logged-in user,
**I want** viết review và rating cho phim,
**So that** tôi chia sẻ cảm nhận với cộng đồng.

**Acceptance Criteria:**
- [ ] Bottom sheet: star rating (1-10) + text area
- [ ] Chỉ 1 review per user per phim (Supabase unique constraint)
- [ ] Nút Edit/Delete nếu là review của mình
- [ ] Cần đăng nhập → redirect login nếu chưa auth
- [ ] `FR-R02`, `FR-R03`, `FR-R05`

**Story Points:** 5

---

### Story 7.3 — Đề Xuất Phim
**As a** user,
**I want** xem phim được gợi ý dựa trên sở thích,
**So that** tôi khám phá phim mới phù hợp gu.

**Acceptance Criteria:**
- [ ] Section "Vì bạn đã thêm X" trong Home (dựa trên phim mới nhất trong Watchlist)
- [ ] Fetch similar movies từ TMDB `/movie/{id}/similar`
- [ ] Chỉ hiện nếu Watchlist không rỗng
- [ ] `FR-REC01`, `FR-REC02`

**Story Points:** 3

---

## EPIC 8 — Profile

> FR-P01 đến FR-P06

### Story 8.1 — Trang Profile
**As a** user,
**I want** xem và chỉnh sửa thông tin cá nhân,
**So that** tôi cá nhân hóa tài khoản.

**Acceptance Criteria:**
- [ ] Avatar (tròn) + Tên + Email
- [ ] Thống kê: X phim yêu thích, Y reviews đã viết
- [ ] Nút đổi avatar (pick từ gallery → upload Supabase Storage)
- [ ] Nút đổi display name (dialog)
- [ ] Toggle Dark/Light mode (lưu SharedPreferences)
- [ ] Nút Đăng xuất + confirm dialog
- [ ] `FR-P01` → `FR-P06`

**Story Points:** 8

---

## Story Point Summary

| Epic | Stories | Total Points |
|------|---------|-------------|
| Epic 1 — Foundation | 6 | 16 |
| Epic 2 — Auth | 4 | 12 |
| Epic 3 — Home | 4 | 14 |
| Epic 4 — Movie Detail | 5 | 18 |
| Epic 5 — Search | 2 | 10 |
| Epic 6 — Watchlist | 2 | 10 |
| Epic 7 — Reviews & Rec | 3 | 11 |
| Epic 8 — Profile | 1 | 8 |
| **TOTAL** | **27** | **99** |

---

## Next Step

> Khi approved, dùng lệnh `/bmad-create-story` để tạo file story chi tiết cho từng story và bắt đầu implement theo thứ tự.
