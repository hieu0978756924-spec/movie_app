# Góc Phim — Bộ Tài Liệu Thuyết Trình & Kịch Bản Live Demo

> **Dự án:** App Di Động "Góc Phim" (Flutter, BLoC, Supabase, TMDB API, Hive)  
> **Tác giả:** Nhu Hieu  
> **Thời lượng đề xuất:** 10 - 15 phút (Thuyết trình Slide: 5-7 phút | Live Demo App: 5-7 phút | Q&A: 3-5 phút)

---

## 📋 Mục Lục
1. [Phần 1: Dàn Bài Slide Thuyết Trình (10 Slide Deck)](#phan-1-dan-bai-slide-thuyet-trinh-10-slide-deck)
2. [Phần 2: Kịch Bản Live Demo App Chi Tiết (Step-by-Step Demo Script)](#phan-2-kich-ban-live-demo-app-chi-tiet)
3. [Phần 3: Bộ Câu Hỏi Phản Biện Q&A Thường Gặp (Q&A Prep)](#phan-3-bo-cau-hoi-phan-bien-qa-thuong-gap)

---

<a id="phan-1-dan-bai-slide-thuyet-trinh-10-slide-deck"></a>
## 🎨 Phần 1: Dàn Bài Slide Thuyết Trình (10 Slide Deck)

### Slide 1: Slide Tiêu Đề (Title & Introduction)
* **Bố cục Visual:** Màn hình Dark Mode sang trọng, logo **Góc Phim** ở trung tâm với icon cuộn phim neon, mockup smartphone hiển thị màn hình Home năng động.
* **Tiêu đề:** **GÓC PHIM — Mạng Xã Hội & Khám Phá Điện Ảnh Cho Người Việt**
* **Phụ đề:** Trải nghiệm xem, theo dõi và chia sẻ điện ảnh mượt mà trên iOS & Android.
* **Thông tin Presenter:** Người thực hiện & Trình bày: Nhu Hieu | Tech Stack: Flutter, Supabase, TMDB API, BLoC.
* **🎙️ Lời dẫn Presenter:** 
  > *"Kính chào quý thầy cô / anh chị và các bạn! Hôm nay em xin đại diện nhóm trình bày về dự án **Góc Phim** — một ứng dụng di động được xây dựng với mục tiêu nâng tầm trải nghiệm khám phá và quản lý phim điện ảnh cho cộng đồng người yêu phim tại Việt Nam."*

---

### Slide 2: Vấn Đề Của Người Dùng (Problem Statement)
* **Bố cục Visual:** Chia làm 3 cột chứa icon "Pain Points" đỏ/cam ấn tượng.
* **Nội dung:**
  1. 🌀 **Thông tin phân mảnh:** Phải mở IMDb để xem rating, YouTube để tìm Trailer, Google để đọc tóm tắt nội dung.
  2. 📝 **Khó quản lý phim muốn xem:** Dùng Note hoặc chụp màn hình, khi vào rạp không nhớ phim nào mình từng muốn xem.
  3. 💬 **Thiếu không gian chia sẻ thuần Việt:** Các nền tảng quốc tế thiếu review cảm nhận của cộng đồng người Việt.
* **🎙️ Lời dẫn Presenter:**
  > *"Khi muốn tìm một bộ phim hay cuối tuần, người dùng thường rơi vào vòng lặp: mở YouTube xem trailer, chuyển sang IMDb đọc điểm số, rồi lại quên mất danh sách phim bạn bè từng gợi ý. Góc Phim ra đời để giải quyết triệt để sự phân mảnh này trên một ứng dụng duy nhất."*

---

### Slide 3: Giải Pháp & Tầm Nhìn (Solution & Vision)
* **Bố cục Visual:** Banner câu khẩu hiệu hoành tráng, kèm 3 trụ cột giải pháp chính.
* **Khẩu hiệu (Vision):** *"Một góc nhỏ dành riêng cho người yêu phim — Nơi bạn không chỉ xem, mà còn cảm nhận và chia sẻ."*
* **3 Trụ cột Giải pháp:**
  * 🍿 **All-in-One Hub:** Tích hợp TMDB Data + Trailer YouTube chạy mượt trực tiếp trên app.
  * 📱 **Personal Watchlist Offline:** Lưu danh sách phim yêu thích xem được mọi lúc ngay cả khi mất kết nối mạng.
  * 🤝 **Cộng đồng Review:** Đánh giá, chấm điểm và thảo luận phim trực quan realtime với Supabase Backend.
* **🎙️ Lời dẫn Presenter:**
  > *"Góc Phim mang đến trải nghiệm All-in-One: Gom toàn bộ kho dữ liệu phim điện ảnh chuẩn quốc tế từ TMDB API, kết hợp với hạ tầng Supabase mạnh mẽ và công nghệ lưu trữ offline Hive để mang lại sự tiện lợi tuyệt đối."*

---

### Slide 4: Kiến Trúc Kỹ Thuật (Tech Stack & Architecture)
* **Bố cục Visual:** Sơ đồ khối **Clean Architecture** (Presentation - Domain - Data) sắc nét.
* **Các công nghệ cốt lõi:**
  * 💙 **Frontend:** Flutter & Dart — Đa nền tảng (iOS + Android), giao diện 60 FPS mượt mà.
  * 🧱 **State Management:** BLoC Pattern (`flutter_bloc`) — Chia tách logic và UI type-safe.
  * ⚡ **Backend & Database:** Supabase (Auth, Postgres DB, Row Level Security - RLS, Storage avatar).
  * 🎬 **Data Source:** TMDB API v3 (Trending, Now Playing, Search, Credits, Recommendations).
  * 💾 **Local Storage:** Hive (Cơ sở dữ liệu NoSQL siêu tốc để cache Watchlist offline).
  * 🔀 **Navigation & DI:** GoRouter + `get_it` / `injectable`.
* **🎙️ Lời dẫn Presenter:**
  > *"Về mặt kỹ thuật, dự án tuân thủ nghiêm ngặt mô hình Clean Architecture 3 tầng. Điều này giúp mã nguồn dễ bảo trì, dễ mở rộng tính năng mới và viết Unit Test độc lập. Chúng em dùng BLoC để quản lý luồng dữ liệu bất đồng bộ và Hive để đảm bảo app hoạt động hoàn hảo cả khi offline."*

---

### Slide 5: Tính Năng Nổi Bật (Core Features Highlight)
* **Bố cục Visual:** 4 mockup màn hình chụp ứng dụng thật (Home, Detail, Search, Review).
* **Nội dung 4 tính năng chính:**
  1. 🌟 **Home Carousel & Discovery:** Banner phim Trending tuần, danh sách Phổ biến, Đang chiếu, Top Rated với hiệu ứng Shimmer loading cao cấp.
  2. 🔍 **Search & Smart Filter:** Tìm kiếm Real-time với kỹ thuật Debounce 500ms, lọc phim theo Thể loại (Genre), Năm phát hành & Rating.
  3. 🎥 **Detail & YouTube Trailer:** Xem Poster high-res, danh sách diễn viên (Cast), bấm xem Trailer YouTube full-screen không cần thoát app.
  4. ⭐ **Review & Sync Watchlist:** Đăng nhập Supabase Auth, viết cảm nhận, chấm điểm 1-10 và đồng bộ danh sách phim yêu thích.
* **🎙️ Lời dẫn Presenter:**
  > *"Ứng dụng được thiết kế với 4 cụm tính năng chính: Khám phá phim thông minh, Tìm kiếm và lọc linh hoạt, Trình chiếu trailer tích hợp và Hệ thống quản lý cá nhân hóa."*

---

### Slide 6: Thiết Kế UI/UX & Trải Nghiệm Người Dùng
* **Bố cục Visual:** Bảng màu Theme (Dark Cinema Theme: Obsidian Black `#121212`, Crimson Red `#E50914`, Gold Accent `#FFD700`), Typography Inter/Roboto.
* **Điểm sáng UX:**
  * 🌙 **Dark Mode chuẩn Điện ảnh:** Giảm mỏi mắt, làm nổi bật poster phim.
  * ⚡ **Phản hồi tức thì:** Hiệu ứng Skeleton / Shimmer loading khi tải mạng chậm.
  * 🛡️ **Xử lý lỗi thân thiện (Graceful Error Handling):** Màn hình Empty state, Retry button, thông báo Toast mượt mà khi mất mạng.
* **🎙️ Lời dẫn Presenter:**
  > *"Tông màu chủ đạo của app mang phong cách rạp phim hiện đại với nền tối Obsidian giúp màu sắc poster phim bừng sáng. Mọi tương tác chuyển trang qua GoRouter đều có animation mượt mà."*

---

### Slide 7: Bảo Mật & Hiệu Năng (Security & Performance)
* **Bố cục Visual:** Bảng so sánh chỉ số Performance & Sơ đồ Security với Supabase RLS.
* **Chỉ số Hiệu năng:**
  * 🚀 Cold Start app < 2.5 giây.
  * 🖼️ Cached Network Image — Tải ảnh thông minh, lưu bộ nhớ đệm đĩa cứng.
  * ⚡ Scroll mượt mà 60 FPS nhờ Lazy-loading danh sách dài.
* **Tính Bảo mật:**
  * 🔒 **Supabase RLS (Row Level Security):** User chỉ có quyền chỉnh sửa/xóa review và watchlist của chính mình.
  * 🔑 **Bảo mật API Key:** TMDB API key được mã hóa cấu hình qua môi trường, không hardcode.
* **🎙️ Lời dẫn Presenter:**
  > *"Chúng em cực kỳ coi trọng tính bảo mật và hiệu năng. Nhờ Supabase Row Level Security, dữ liệu người dùng được bảo vệ ngay từ tầng Database. Bộ nhớ đệm Hive và Cached Network Image giúp app cuộn cực mượt mà không tốn dữ liệu di động."*

---

### Slide 8: Video / Live Demo Walkthrough (Chuyển tiếp qua Live Demo)
* **Bố cục Visual:** Chữ lớn: **LIVE DEMO APP** với màn hình chờ trình chiếu thiết bị Android/iOS.
* **Nội dung:** Giới thiệu ngắn về kịch bản demo sắp diễn ra trên thiết bị thật / giả lập.
* **🎙️ Lời dẫn Presenter:**
  > *"Sau đây, em xin phép chuyển sang phần quan trọng nhất: Trực tiếp thao tác và trải nghiệm các tính năng của ứng dụng Góc Phim trên thiết bị!"*

---

### Slide 9: Định Hướng Phát Triển (Future Roadmap)
* **Bố cục Visual:** Tiến trình Timeline với các mốc v1.0 (Hiện tại) -> v1.5 -> v2.0.
* **Kế hoạch tương lai:**
  * 🤖 **v1.5:** AI Movie Recommender (Gợi ý phim thông minh dựa trên lịch sử xem người dùng).
  * 🎟️ **v2.0:** Tích hợp Lịch chiếu rạp & Đặt vé xem phim qua cổng thanh toán VNPay / MoMo.
  * 🔔 **Push Notifications:** Thông báo khi phim yêu thích ra mắt hoặc có trailer mới.
* **🎙️ Lời dẫn Presenter:**
  > *"Trong các phiên bản tiếp theo, nhóm có định hướng tích hợp AI gợi ý phim cá nhân hóa và tính năng theo dõi lịch chiếu rạp tại Việt Nam."*

---

### Slide 10: Tổng Kết & Q&A (Conclusion & Q&A)
* **Bố cục Visual:** Lời cảm ơn chân thành, QR code tải app/source code (GitHub), thông tin liên hệ.
* **Nội dung:** 
  * Cảm ơn sự theo dõi của Ban Giám Khảo & Quý khán giả.
  * Mở hội trường cho phần Hỏi & Đáp (Q&A).
* **🎙️ Lời dẫn Presenter:**
  > *"Em xin chân thành cảm ơn quý thầy cô và các bạn đã lắng nghe. Nhóm rất mong nhận được những góp ý quý báu để hoàn thiện sản phẩm tốt hơn. Xin mời phần câu hỏi Q&A!"*

---

<a id="phan-2-kich-ban-live-demo-app-chi-tiet"></a>
## 🎬 Phần 2: Kịch Bản Live Demo App Chi Tiết (5 - 7 Phút)

> **Chuẩn bị trước khi Demo:**
> 1. Mở sẵn giả lập (Android Emulator / iOS Simulator) hoặc chiếu màn hình điện thoại thật lên máy chiếu bằng Scrcpy/AirPlay.
> 2. Đảm bảo kết nối Internet ổn định.
> 3. Chuẩn bị 2 tài khoản thử nghiệm trên Supabase: 1 tài khoản đã có sẵn dữ liệu review (`user1@gmail.com`) và 1 tài khoản mới.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        KỊCH BẢN THAO TÁC DEMO THEO THỜI GIAN                           │
├─────────┬───────────────────────────┬──────────────────────────────────────────────────┤
│ Thời gian│ Hành động trên App        │ Lời thoại MC / Presenter                         │
├─────────┼───────────────────────────┼──────────────────────────────────────────────────┤
│ 00:00 - │ Mở App từ màn hình chính  │ "Đầu tiên, khi mở app Góc Phim, ứng dụng khởi    │
│ 01:00   │ Splash Screen -> Home Page│ động cực nhanh dưới 2.5s. Màn hình Home hiện ra   │
│         │ Vuốt mượt Carousel Phim   │ với phong cách Dark Mode hiện đại, các bộ phim   │
│         │ Trending & Section Phổ Biến│ Trending hot nhất tuần được trình bày dạng slider│
│         │ Bấm thử Tab Thể Loại      │ mượt mà lấy trực tiếp từ TMDB API."             │
├─────────┼───────────────────────────┼──────────────────────────────────────────────────┤
│ 01:00 - │ Chuyển sang Tab Tìm Kiếm  │ "Tiếp theo là tính năng Tìm kiếm & Lọc. Nhờ kỹ  │
│ 02:15   │ Gõ "Avatar" vào SearchBar │ thuật Debounce, kết quả tìm kiếm hiện ra tức thì │
│         │ Thao tác chọn Filter:     │ khi gõ mà không gây quá tải API. Chúng ta cũng có│
│         │ Genre: Hành động (Action) │ thể lọc phim theo thể loại, năm phát hành một    │
│         │ Slider Rating: ≥ 8.0      │ cách cực kỳ linh hoạt."                          │
├─────────┼───────────────────────────┼──────────────────────────────────────────────────┤
│ 02:15 - │ Chọn 1 bộ phim bất kỳ     │ "Bây giờ em bấm vào bộ phim này để chuyển tới    │
│ 03:45   │ (VD: Oppenheimer)         │ trang Detail. Toàn bộ thông tin: điểm số, thời  │
│         │ Xem thông tin & Cast List │ lượng, tóm tắt nội dung và dàn diễn viên xuất hiện│
│         │ Bấm nút "Xem Trailer"     │ rực rỡ. Đặc biệt, khi bấm 'Xem Trailer', trình   │
│         │ -> YouTube Player bật lên │ phát YouTube phát ngay trên app chuẩn Full HD."  │
├─────────┼───────────────────────────┼──────────────────────────────────────────────────┤
│ 03:45 - │ Bấm nút Yêu Thích (Tim)   │ "Nếu chưa đăng nhập, app sẽ yêu cầu đăng nhập.   │
│ 05:00   │ Nhập Auth (Email/Pass)    │ Em thực hiện đăng nhập qua Supabase Auth. Ngay   │
│         │ Đã thích -> Hiện Icon Tim │ lập tức, nút Tim đổi màu và bộ phim được lưu vào │
│         │ Chuyển sang Tab Watchlist │ Watchlist cá nhân. Giờ em thử TẮT WI-FI/MẠNG...  │
│         │ Tắt Mạng (Offline Demo)   │ Mọi người có thể thấy: Watchlist vẫn xem mượt nhờ│
│         │ Mở Watchlist offline!     │ cơ sở dữ liệu Hive local caching!"              │
├─────────┼───────────────────────────┼──────────────────────────────────────────────────┤
│ 05:00 - │ Bật lại Mạng              │ "Cuối cùng là tính năng Đánh giá & Xã hội. Em có │
│ 06:30   │ Cuộn tới phần Reviews     │ thể xem review của cộng đồng, đồng thời tự chấm   │
│         │ Bấm "Viết Review"         │ 9/10 sao kèm bình luận 'Phim quá đỉnh!'. Dữ liệu │
│         │ Chấm 9/10 + Gõ bình luận │ này lập tức sync lên Supabase Database realtime!" │
│         │ Mở Tab Profile -> Chỉnh   │                                                  │
│         │ sửa Avatar / Toggle Theme │                                                  │
└─────────┴───────────────────────────┴──────────────────────────────────────────────────┘
```

---

<a id="phan-3-bo-cau-hoi-phan-bien-qa-thuong-gap"></a>
## ❓ Phần 3: Bộ Câu Hỏi Phản Biện Q&A Thường Gặp (Q&A Prep)

### ❓ Câu 1: Tại sao nhóm chọn BLoC làm State Management mà không dùng Provider hay Riverpod?
* **Trả lời:**
  > *"Dự án chọn **BLoC (Business Logic Component)** vì tính phân tách rõ ràng giữa UI và Business Logic theo Clean Architecture. BLoC dùng Stream/Event-State giúp kiểm soát luồng dữ liệu bất đồng bộ phức tạp (như việc kết hợp dữ liệu giữa TMDB API, Supabase DB và Hive local). BLoC cũng giúp dự án cực kỳ dễ viết Unit Test cho từng Event/State mà không bị phụ thuộc vào UI Flutter."*

### ❓ Câu 2: App xử lý như thế nào khi mất kết nối mạng (Offline behavior)?
* **Trả lời:**
  > *"Nhóm áp dụng cơ chế **Offline-First cho Watchlist** bằng thư viện **Hive**. Khi người dùng bấm thêm phim vào danh sách yêu thích, dữ liệu được ghi ngay vào Hive local database (cho tốc độ phản hồi 0ms). Khi có kết nối mạng, một background sync worker sẽ tự động đồng bộ danh sách này lên bảng `favorites` trên Supabase Backend."*

### ❓ Câu 3: Làm thế nào để bảo mật dữ liệu người dùng trên Supabase?
* **Trả lời:**
  > *"Nhóm thiết lập chính sách **Row Level Security (RLS)** trực tiếp trong PostgreSQL Database của Supabase. Cụ thể:  
  > 1. Bảng `profiles`: Mọi người dùng đều có thể xem public, nhưng chỉ chủ tài khoản (`auth.uid() = id`) mới có quyền UPDATE.  
  > 2. Bảng `reviews` & `favorites`: Người dùng chỉ có quyền chỉnh sửa hoặc xóa các bản ghi do chính họ tạo ra. Kể cả khi ai đó biết API Anon Key, họ cũng không thể sửa dữ liệu của người khác."*

### ❓ Câu 4: Ứng dụng xử lý bài toán giới hạn Rate Limit của TMDB API như thế nào?
* **Trả lời:**
  > *"TMDB API giới hạn số lượng request trong 1 khoảng thời gian. Để tối ưu:  
  > 1. Trên thanh tìm kiếm, nhóm dùng kỹ thuật **Debounce 500ms**, chỉ gửi request khi người dùng ngừng gõ 0.5s.  
  > 2. Dùng **Dio Cache Interceptor** để lưu tạm các kết quả API danh mục (Genres, Now Playing) trên RAM/Disk trong 1 giờ. Nếu người dùng chuyển qua lại các tab, app sẽ lấy từ cache thay vì gọi lại TMDB API."*

### ❓ Câu 5: Điểm khác biệt lớn nhất giữa Góc Phim và các app xem phim thông thường là gì?
* **Trả lời:**
  > *"Góc Phim không phải là app xem phim lậu hay app streaming, mà là một **Trợ lý Điện ảnh Cá nhân hóa & Mạng Xã Hội Phim**. Điểm khác biệt nằm ở trải nghiệm người dùng liền mạch: Xem trailer YouTube không quảng cáo độc hại, lưu watchlist xem offline siêu tốc, và tham gia cộng đồng đánh giá phim thuần Việt với giao diện đạt chuẩn Cinema Dark Mode."*

---

## 📌 Tóm Tắt Nhanh Cho Trình Bày (Checklist Đạt Điểm Cao)
- [x] **Nói to, rõ ràng, phong thái tự tin.**
- [x] **Nhấn mạnh vào Tech Stack mạnh mẽ (Clean Architecture + Flutter BLoC + Supabase + Hive).**
- [x] **Demo tính năng "Offline Watchlist" và "Xóa/Viết Review Realtime" để gây ấn tượng mạnh với Ban giám khảo.**
- [x] **Chuẩn bị sẵn câu trả lời Q&A về RLS và Offline Sync.**
