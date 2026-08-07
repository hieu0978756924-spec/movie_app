# Góc Phim — UI/UX Design Specification & Design System

> **Version:** 2.0 | **Stitch Project:** `projects/10603022971935191806` (Góc Phim Movie App) | **Design Theme:** Cinematic Noir & Glowing Accents

---

## 1. Design System Tokens (Quy Chuẩn Thiết Kế)

### 1.1 Palette Màu Sắc (Color Palette)

| Loại (Token) | Mã Màu (Hex) | Vai Trò & Ứng Dụng Trong UI |
|---|---|---|
| **Background (Nền chính)** | `#0B0C10` / `#121317` | Deep Charcoal — Nền tối điện ảnh giảm mỏi mắt, giúp poster nổi bật. |
| **Surface / Glass** | `rgba(255, 255, 255, 0.08)` | Thẻ Glassmorphism mờ nhẹ với viền `1px solid rgba(255, 255, 255, 0.1)`. |
| **Primary Accent** | `#FF2A5F` (Neon Coral) | Nút CTA chính (Đăng nhập, Xem Trailer, Active Navigation), progress bar. |
| **Tertiary Accent** | `#FFB800` (Warm Gold) | Điểm số đánh giá (Rating Stars), Badge phim Hot, VIP status. |
| **Secondary Accent** | `#6C5CE7` (Deep Indigo) | Hiệu ứng Gradient mờ nền và thẻ phụ. |
| **Text Primary** | `#E3E2E8` / `#FFFFFF` | Tiêu đề chính, tên phim, nhãn nút bấm. |
| **Text Secondary** | `#AC888A` / `#9E9E9E` | Tóm tắt, thể loại, thông tin phụ, ngày phát hành. |

### 1.2 Typography & Hierarchy

- **Font Tiêu đề (Headlines):** Inter / Montserrat (Bold 700 - ExtraBold 800) với letter-spacing thu hẹp (-0.02em) tạo cảm giác điện ảnh sang trọng.
- **Font Nội dung (Body & Metadata):** Inter (Regular 400 & Medium 500) đảm bảo độ đọc cao trên nền tối.
- **Badge & Labels:** Caps Lock (Uppercase, Bold 700, 12px, letter-spacing 0.1em).

### 1.3 Shapes & Radius

- **Poster Cards:** `16px` (`rounded-lg`) bo góc mềm mại.
- **Buttons & Input Fields:** `24px` (`rounded-xl`) hoặc Full Pill shape.
- **Floating Bar / Glass Containers:** `20px` radius + `backdrop-filter: blur(30px)`.

---

## 2. Danh Sách Màn Hình UI (Stitch Screens Catalog)

Tất cả màn hình đã được khởi tạo và render chuẩn Mobile trên **Stitch Cloud**:

### 📱 1. Màn hình Auth / Login & Register (`01e048d25da84d7d84fb37a94a6eb561`)
- **Visual:** Backdrop rạp chiếu phim mờ ảo kết hợp gradient tối. Thẻ form đăng nhập hiệu ứng Glassmorphism nổi giữa màn hình.
- **Thành phần:**
  - Logo Góc Phim kết hợp icon cuộn phim mờ ảo.
  - Form Đăng nhập với ô nhập Email/Mật khẩu viền mờ glow khi focus.
  - Nút Đăng nhập phát sáng màu Neon Coral (`#FF2A5F`).
  - Đăng nhập bằng Google OAuth button và liên kết Đăng ký nhanh.

### 🏠 2. Màn hình Home Screen (`18db18a108614198a7ec8af4be75e49c`)
- **Visual:** Trải nghiệm xem phim di động tràn viền (Edge-to-edge content).
- **Thành phần:**
  - Header: Lời chào cá nhân hóa, nút tìm kiếm và thông báo.
  - Hero Trending Banner: Carousel phim hot tuần (ví dụ Dune: Part Two) với gradient fade tối, badge "🔥 Trending Tuần Này", nút "▶ Xem Trailer" và nút "+ Watchlist".
  - Genre Filter Horizontal Scroll: Danh mục thể loại dạng Pill ("Tất cả", "Hành động", "Sci-Fi", "Kinh dị",...).
  - Sections Phim Đang Chiếu & Phổ Biến: Thẻ phim tỷ lệ 2:3 với điểm đánh giá Warm Gold floating ở góc poster.
  - Bottom Navigation Bar kính mờ cố định bên dưới.

### 🎬 3. Màn hình Movie Detail Screen (`projects/10603022971935191806`)
- **Visual:** Đổi mới giao diện thông tin chi tiết phim theo chuẩn IMAX/Netflix mobile.
- **Thành phần:**
  - Hero Backdrop full-bleed kết hợp poster đè nhẹ bên góc trái.
  - Nhóm nút thao tác nhanh: Xem Trailer (Neon Coral glow), Thêm vào Watchlist, Nút Yêu thích (Heart icon).
  - Khối thông tin: Tiêu đề, Tagline, Năm phát hành, Thời lượng, Nhãn phân loại độ tuổi.
  - Danh sách Cast & Crew: Avatar tròn của diễn viên kèm tên thật & tên nhân vật.
  - Trình phát Trailer nhúng trực tiếp & Section Đánh giá từ cộng đồng kèm nút "✍️ Viết Đánh Giá Của Bạn".

### 🔍 4. Màn hình Search & Filter Screen (`projects/10603022971935191806`)
- **Visual:** Tra cứu realtime mượt mà với bộ lọc nâng cao.
- **Thành phần:**
  - Thanh tìm kiếm thông minh tích hợp debounce 500ms.
  - Lưới kết quả 2 cột thẻ poster tỷ lệ 2:3.
  - Drawer bộ lọc: Lọc theo thể loại, khoảng năm phát hành (2000–2026), điểm đánh giá tối thiểu (★ 7.0+), sắp xếp theo độ phổ biến / điểm số.

### 📌 5. Màn hình Watchlist / Yêu Thích (`projects/10603022971935191806`)
- **Visual:** Quản lý danh sách xem phim linh hoạt và hỗ trợ xem offline (Hive cache).
- **Thành phần:**
  - Badge trạng thái: "⚡ Sẵn sàng offline".
  - Segmented Tab Bar: "Muốn Xem" vs "Đã Xem".
  - Thao tác nhanh trên danh sách: Đánh dấu đã xem (Checkmark), Xoá khỏi danh sách (Trash icon), Sắp xếp theo ngày thêm.

### 👤 6. Màn hình User Profile & Settings (`projects/10603022971935191806`)
- **Visual:** Hồ sơ cá nhân dạng thẻ VIP Cinephile chuyên nghiệp.
- **Thành phần:**
  - Avatar người dùng bo tròn kèm Badge "Cinephile VIP" màu vàng kim.
  - 3 Thẻ Thống kê Glassmorphism: Số phim đã xem, Số phim trong Watchlist, Số bài review.
  - Danh sách Cài đặt: Đổi thông tin, Toggle chuyển đổi Giao diện Tối/Sáng, Cài đặt thông báo, Đăng xuất.

---

## 3. Hướng Dẫn Áp Dụng Vào Codebase Flutter

1. **Theme Data (`lib/core/theme/app_theme.dart`):**
   Cập nhật `ThemeData.dark()` sử dụng `scaffoldBackgroundColor: Color(0xFF0B0C10)` và `primaryColor: Color(0xFFFF2A5F)`.

2. **Custom Glassmorphism Widget (`lib/core/widgets/glass_card.dart`):**
   Sử dụng `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` kết hợp `Container` có `color: Colors.white.withOpacity(0.08)` và viền `Border.all(color: Colors.white.withOpacity(0.1))`.

3. **Movie Poster Card (`lib/features/home/presentation/widgets/movie_card.dart`):**
   Dùng `ClipRRect(borderRadius: BorderRadius.circular(16))` kết hợp `CachedNetworkImage` và `LinearGradient` từ đen trong suốt lên mờ ở chân poster để chứa tên phim & rating.
