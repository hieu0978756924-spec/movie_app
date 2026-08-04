---
title: "Góc Phim — Product Requirements Document"
status: draft
version: 1.0
created: 2026-08-04
updated: 2026-08-04
author: Nhu Hieu
platform: Android, iOS
---

# Góc Phim — Product Requirements Document

## 1. Product Overview

**Góc Phim** là ứng dụng di động (Android + iOS) giúp người dùng khám phá, theo dõi và chia sẻ trải nghiệm xem phim. App kết nối với TMDB API để lấy dữ liệu phim phong phú, và sử dụng Supabase làm backend cho auth, profile, yêu thích, và bình luận.

### 1.1 Vision

> "Một góc nhỏ dành riêng cho người yêu phim — nơi bạn không chỉ xem, mà còn cảm nhận và chia sẻ."

### 1.2 Target Users

- **Moviegoer** (người xem phổ thông): 18–35 tuổi, xem phim giải trí, muốn biết phim nào đang hot.
- **Film Enthusiast** (người yêu phim): muốn track watchlist, viết review, khám phá phim ẩn.

### 1.3 Problem Statement

Người dùng hiện phải dùng nhiều app (IMDB, YouTube, Google) để tìm thông tin phim, xem trailer, và quản lý danh sách xem. Góc Phim gom tất cả vào một trải nghiệm liền mạch.

---

## 2. Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart), BLoC pattern |
| State Management | flutter_bloc |
| Navigation | GoRouter |
| Backend/Auth | Supabase (Auth, Database, Storage) |
| Movie Data | TMDB API v3 |
| Local Storage | Hive (offline watchlist cache) |
| Video | YouTube Player Flutter (trailer) |
| DI | get_it + injectable |

---

## 3. User Journeys

### UJ-1: Khám phá phim mới (Moviegoer — Minh, 24 tuổi)
Minh mở app, thấy ngay banner phim trending tuần này. Anh swipe qua các section "Đang chiếu", "Phổ biến", "Phim theo thể loại". Click vào một phim, xem poster đẹp, đọc tóm tắt, xem trailer ngay trên app, rồi thêm vào Watchlist để xem sau.

### UJ-2: Tìm phim cụ thể (Film Enthusiast — Lan, 28 tuổi)
Lan nhớ tên một bộ phim không rõ, gõ vào search bar, dùng filter lọc theo năm 2020–2023 và thể loại Sci-Fi. Tìm được phim, vào detail, đọc cast, xem điểm IMDB, đọc review của người khác, rồi viết review của mình.

### UJ-3: Quản lý Watchlist (Film Enthusiast — Lan)
Lan vào tab Yêu thích, thấy danh sách phim đã lưu. Đánh dấu những phim đã xem, xoá những phim không muốn xem nữa. List này available offline.

---

## 4. Functional Requirements

### FR-A: Authentication (Supabase Auth)

| ID | Requirement | Priority |
|----|------------|---------|
| FR-A01 | User đăng ký bằng email + password | Must |
| FR-A02 | User đăng nhập bằng email + password | Must |
| FR-A03 | Đăng nhập bằng Google OAuth | Should |
| FR-A04 | Forgot password qua email | Must |
| FR-A05 | Auto-login (persist session với Supabase) | Must |
| FR-A06 | Đăng xuất xoá session local | Must |

### FR-H: Home Screen

| ID | Requirement | Priority |
|----|------------|---------|
| FR-H01 | Hiển thị banner carousel phim Trending tuần này (TMDB) | Must |
| FR-H02 | Section "Đang chiếu" (Now Playing) — horizontal scroll | Must |
| FR-H03 | Section "Phổ biến" (Popular) — horizontal scroll | Must |
| FR-H04 | Section "Top Rated" | Should |
| FR-H05 | Section phim theo thể loại (Genre tabs) | Should |
| FR-H06 | Pull-to-refresh | Must |
| FR-H07 | Shimmer loading placeholder | Must |

### FR-D: Movie Detail

| ID | Requirement | Priority |
|----|------------|---------|
| FR-D01 | Backdrop + Poster + Title + Tagline | Must |
| FR-D02 | Rating (TMDB score + số lượt vote) | Must |
| FR-D03 | Release date, runtime, genres | Must |
| FR-D04 | Overview (tóm tắt nội dung) | Must |
| FR-D05 | Danh sách Cast (avatar + tên + vai diễn) | Must |
| FR-D06 | Nút "Xem Trailer" → play YouTube | Must |
| FR-D07 | Section "Phim tương tự" (Similar Movies) | Should |
| FR-D08 | Nút thêm/xoá Yêu thích | Must |
| FR-D09 | Nút Share phim | Should |
| FR-D10 | Tab "Reviews" hiển thị review người dùng | Must |
| FR-D11 | Nút viết Review từ trang Detail | Must |

### FR-S: Search & Filter

| ID | Requirement | Priority |
|----|------------|---------|
| FR-S01 | Search bar với debounce 500ms | Must |
| FR-S02 | Kết quả realtime khi gõ | Must |
| FR-S03 | Filter theo thể loại (Genre) | Must |
| FR-S04 | Filter theo năm phát hành (range slider) | Should |
| FR-S05 | Filter theo điểm đánh giá (min rating) | Should |
| FR-S06 | Sort: Popularity / Rating / Release Date | Should |
| FR-S07 | Recent searches (lưu local) | Could |

### FR-W: Watchlist / Yêu Thích

| ID | Requirement | Priority |
|----|------------|---------|
| FR-W01 | Thêm/xoá phim vào Watchlist | Must |
| FR-W02 | Lưu Watchlist offline (Hive) | Must |
| FR-W03 | Sync Watchlist lên Supabase khi có mạng | Should |
| FR-W04 | Đánh dấu phim đã xem (Watched status) | Should |
| FR-W05 | Sắp xếp Watchlist (ngày thêm, tên, rating) | Could |

### FR-T: Trailer Playback

| ID | Requirement | Priority |
|----|------------|---------|
| FR-T01 | Embed YouTube player trong app | Must |
| FR-T02 | Fullscreen playback | Must |
| FR-T03 | Fallback khi không có trailer: thông báo | Must |

### FR-R: Review & Bình Luận

| ID | Requirement | Priority |
|----|------------|---------|
| FR-R01 | Xem danh sách review cho một phim | Must |
| FR-R02 | Viết review (rating 1-10 + text) — cần đăng nhập | Must |
| FR-R03 | Sửa/xoá review của chính mình | Must |
| FR-R04 | Like review của người khác | Could |
| FR-R05 | Review lưu trên Supabase | Must |

### FR-REC: Đề Xuất Phim (Recommendation)

| ID | Requirement | Priority |
|----|------------|---------|
| FR-REC01 | "Vì bạn đã xem X" — similar movies từ TMDB | Must |
| FR-REC02 | "Được đề xuất cho bạn" dựa trên genre yêu thích | Should |
| FR-REC03 | "Trending trong cộng đồng" dựa trên lượt yêu thích Supabase | Could |

### FR-P: Profile

| ID | Requirement | Priority |
|----|------------|---------|
| FR-P01 | Xem thông tin profile (avatar, tên, email) | Must |
| FR-P02 | Đổi avatar (upload lên Supabase Storage) | Should |
| FR-P03 | Đổi display name | Should |
| FR-P04 | Thống kê: số phim yêu thích, số review | Should |
| FR-P05 | Toggle Dark/Light mode | Must |
| FR-P06 | Đăng xuất | Must |

---

## 5. Non-Functional Requirements

### 5.1 Performance
- Cold start < 3 giây
- API response cached, scroll 60fps
- Image lazy load + disk cache (cached_network_image)

### 5.2 Offline
- Watchlist khả dụng offline (Hive)
- Home screen hiển thị cache 1 giờ khi mất mạng

### 5.3 Security
- Supabase RLS (Row Level Security): user chỉ sửa được data của mình
- TMDB API key không hardcode trong code (env/config)
- Tokens không lưu plain text

### 5.4 Accessibility
- Contrast ratio ≥ 4.5:1
- Semantic labels trên icon buttons
- Support font scaling

### 5.5 Error Handling
- Mọi API call có error state UI (empty state / retry button)
- Network error → friendly message, không crash

---

## 6. Out of Scope (v1.0)

- Streaming phim thực tế
- Download offline
- Subscription / paywall
- Chat / messaging giữa users
- Web platform

---

## 7. Success Metrics

| Metric | Target (3 tháng) |
|--------|----------------|
| DAU (Daily Active Users) | ≥ 500 |
| Session duration | ≥ 5 phút |
| Watchlist items per user | ≥ 10 |
| Review submissions | ≥ 200 |
| Crash rate | < 0.5% |
| App Store rating | ≥ 4.2 ⭐ |

---

## 8. Open Questions

1. Supabase project URL và anon key — cần config trước khi implement auth.
2. TMDB API key — cần đăng ký tại themoviedb.org.
3. YouTube Player: dùng `youtube_player_flutter` package hay WebView embed?
4. Review moderation: có cần admin panel không?
5. Ngôn ngữ UI: Tiếng Việt hay bilingual (VI/EN)?
