# 🎬 KỊCH BẢN THUYẾT TRÌNH BẢO VỆ DỰ ÁN APP "GÓC PHIM" (MOVIE APP)
*(Phiên bản văn nói chi tiết, diễn giải dài & dễ hiểu dành cho buổi thuyết trình với Mentor)*

> **Định dạng:** Văn nói tự nhiên (đã mở rộng chi tiết), phân tích kĩ thuật từng màn hình, Widgets, Luồng dữ liệu và Ma trận Q&A phản biện.

---

## 📋 MỤC LỤC
1. [Phần 1: Mở Đầu & Giới Thiệu Tổng Quan Dự Án](#phần-1-mở-đầu--giới-thiệu-tổng-quan-dự-án)
2. [Phần 2: Phân Tích Chi Tiết Từng Màn Hình (Kịch Bản Văn Nói Dài)](#phần-2-phân-tích-chi-tiết-từng-màn-hình)
   - [1. Màn Hình Chờ (Splash Screen & Router Guard)](#1-màn-hình-chờ-splash-screen--router-guard)
   - [2.1. Màn Hình Đăng Nhập & Chế Độ Khách (Login & Guest Mode)](#21-màn-hình-đăng-nhập--chế-độ-khách-login--guest-mode)
   - [2.2. Màn Hình Đăng Ký Tài Khoản (Register View)](#22-màn-hình-đăng-ký-tài-khoản-register-view)
   - [3. Khung Điều Hướng Main Layout & Preservation State](#3-khung-điều-hướng-main-layout--preservation-state)
   - [4. Trang Chủ Phim (Home View & Shimmer Skeleton)](#4-trang-chủ-phim-home-view--shimmer-skeleton)
   - [5. Màn Hình Chi Tiết Phim (Movie Detail & Inline Trailer Player)](#5-màn-hình-chi-tiết-phim-movie-detail--inline-trailer-player)
   - [6. Màn Hình Tìm Kiếm & Bộ Lọc Đa Tiêu Chí (Search & Multi-Filter)](#6-màn-hình-tìm-kiếm--bộ-lọc-đa-tiêu-chí-search--multi-filter)
   - [7. Màn Hình Watchlist Xem Sau (Hive Storage & Swipe-to-Delete)](#7-màn-hình-watchlist-xem-sau-hive-storage--swipe-to-delete)
   - [8. Màn Hình Phim Yêu Thích (Favorites & Real-time Sync)](#8-màn-hình-phim-yêu-thích-favorites--real-time-sync)
   - [9. Trang Cá Nhân & Chuyển Đổi Dark/Light Theme (Profile & ThemeCubit)](#9-trang-cá-nhân--chuyển-đổi-darklight-theme-profile--themecubit)
3. [Phần 3: Bảng Tổng Hợp Kiến Thức Kỹ Thuật (Q&A Phản Biện Chi Tiết)](#phần-3-bảng-tổng-hợp-kiến-thức-kỹ-thuật-qa-phản-biện-chi-tiết)
4. [Phần 4: Lời Kết Thuyết Trình](#phần-4-lời-kết-thuyết-trình)

---

## 🎯 PHẦN 1: MỞ ĐẦU & GIỚI THIỆU TỔNG QUAN DỰ ÁN

### 🎙️ Kịch bản văn nói (Đọc trực tiếp):
> *"Em xin chào anh/thầy [Tên Mentor]! Em rất hân hạnh được trình bày với anh về dự án cá nhân mà em đã dành nhiều tâm huyết xây dựng — ứng dụng di động xem và quản lý thông tin điện ảnh mang tên **'Góc Phim'**.*
>
> *Ý tưởng xuất phát của dự án này bắt nguồn từ nhu cầu thực tế: Người yêu phim hiện nay không chỉ muốn xem một danh sách phim đơn thuần, mà họ cần một **trải nghiệm điện ảnh đích thực (Cinematic Experience)** ngay trên chiếc điện thoại. Họ cần giao diện mượt mà, màu sắc đậm chất cinema, tốc độ tải nhanh, xem trailer trực tiếp không bị chuyển ứng dụng và có thể lưu lại phim yêu thích ngay cả khi mất kết nối mạng.*
>
> *Về mặt kỹ thuật, để giải quyết bài toán này và đảm bảo mã nguồn có thể mở rộng sau này, em đã áp dụng kiến trúc **Clean Architecture** chia layer rõ ràng, kết hợp **BLoC Pattern** để quản lý State chuyên nghiệp. Phía Backend em tích hợp **Supabase** xử lý xác thực và dữ liệu đám mây, kết hợp với cơ sở dữ liệu NoSQL cục bộ là **Hive DB** để hỗ trợ tính năng Offline-first.*
>
> *Sau đây, em xin phép đi sâu vào từng màn hình, giải thích chi tiết kịch bản người dùng, cấu trúc Widgets, luồng chạy dữ liệu và các giải pháp kỹ thuật em đã áp dụng trong app!"*

---

## 📱 PHẦN 2: PHÂN TÍCH CHI TIẾT TỪNG MÀN HÌNH

---

### 1. Màn Hình Chờ (Splash Screen & Router Guard)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Đầu tiên, khi người dùng mở ứng dụng, màn hình đầu tiên họ tiếp xúc chính là **Splash Screen** (`SplashView`). Màn hình này không đơn thuần chỉ hiển thị Logo cho đẹp mắt, mà đóng vai trò là **'trạm trung chuyển kiểm tra an ninh'** của ứng dụng.*
>
> *Ngay khi ứng dụng khởi chạy, hệ thống sẽ thực hiện các tác vụ bất đồng bộ dưới nền: Khởi tạo cơ sở dữ liệu local Hive, cấu hình Dependency Injection qua GetIt và kiểm tra phiên đăng nhập hiện tại từ Supabase Auth Client. 
>
> *Điểm đặc biệt ở đây là em đã tích hợp **Router Guard** trực tiếp vào bộ điều hướng `GoRouter`. Nếu hệ thống phát hiện Token của người dùng vẫn còn hiệu lực, app sẽ lập tức chuyển thẳng người dùng vào Trang Chủ mà họ không cần thao tác gì thêm. Ngược lại, nếu chưa đăng nhập hoặc Token hết hạn, app sẽ điều hướng về màn hình Đăng Nhập một cách êm ái, hoàn toàn không bị giật hay nháy màn hình (flicker UI)."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`Scaffold`** với nền tối `AppColors.darkBackground`.
* **`Center` & `CircularProgressIndicator`**: Xoay tải nhẹ nhàng ở trung tâm.
* **`GoRouter.redirect`**: Hàm callback định tuyến động kiểm tra `isAuthenticated`.

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. `main()` thực thi $\rightarrow$ Chạy `WidgetsFlutterBinding.ensureInitialized()`, `Hive.initFlutter()`, `Supabase.initialize()`.
2. Router gọi `AppRouter.isAuthenticated`:
   * Trường hợp 1: Có Session valid $\rightarrow$ Redirect tự động tới `/home`.
   * Trường hợp 2: Chưa đăng nhập $\rightarrow$ Redirect tới `/login`.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* Tránh anti-pattern sử dụng `Navigator.pushReplacement` thủ công ở `initState`, giúp luồng phân quyền tập trung 100% tại Router config.

---

### 2.1. Màn Hình Đăng Nhập & Chế Độ Khách (Login & Guest Mode)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Tiếp theo là màn hình Đăng Nhập (`LoginView`). Về mặt thị giác, em đã thiết kế màn hình này theo phong cách **Glassmorphism (Kính mờ)** kết hợp với hình nền Poster phim điện ảnh và dải màu Gradient tối, tạo cảm giác sang trọng như khi bước vào rạp chiếu phim.*
>
> *Về mặt tính năng, em cung cấp đầy đủ các lựa chọn cho người dùng: Đăng nhập bằng Email/Password chuẩn mã hóa, Đăng ký tài khoản mới, Quên mật khẩu và Đăng nhập bằng Google.
>
> *Tuy nhiên, điểm tạo nên trải nghiệm mượt mà nhất chính là **Chế độ Trải nghiệm Khách (Guest Mode)**. Em nhận thấy rất nhiều người dùng ngại tạo tài khoản ngay lần đầu tải app. Vì vậy, khi bấm 'Trải nghiệm Giao diện (Khách)', em sử dụng một Singleton `UserSession` đánh dấu trạng thái Guest, cho phép họ vào Trang Chủ khám phá toàn bộ phim ngay lập tức.*
>
> *Khi người dùng khách cố gắng thực hiện các thao tác đòi hỏi định danh (như bấm Yêu thích phim, thêm Watchlist hay bình luận), ứng dụng mới bật một Dialog lịch sự thông báo: 'Bạn cần đăng nhập để thực hiện tính năng này' kèm nút chuyển hướng nhanh đến trang Đăng Nhập."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`Stack` & `Positioned.fill`**: Chồng nhiều lớp background: Ảnh Cinema $\rightarrow$ LinearGradient $\rightarrow$ RadialGradient.
* **`GlassCard`**: Custom Widget kết hợp `BackdropFilter` hiệu ứng mờ nhòe thủy tinh.
* **`Form` & `TextFormField`**: Kiểm tra dữ liệu nhập (Regex kiểm tra định dạng email và độ dài mật khẩu $\ge$ 6 ký tự).
* **`BlocConsumer<AuthBloc, AuthState>`**: Lắng nghe sự kiện Auth (Listen để bật SnackBar lỗi / Chuyển trang; Build để đổi trạng thái nút bấm sang Loading).

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. Người dùng gõ thông tin $\rightarrow$ Bấm nút "Đăng Nhập".
2. Validator kiểm tra hợp lệ $\rightarrow$ Dispatch `LoginSubmittedEvent(email, password)` vào `AuthBloc`.
3. `AuthBloc` gọi `AuthRepository` giao tiếp API Supabase Authentication.
4. Supabase trả về thành công $\rightarrow$ Emitted `AuthenticatedState`.
5. `BlocListener` bắt trạng thái $\rightarrow$ Gọi `UserProfileManager.updateProfile()` $\rightarrow$ Điều hướng `context.go('/home')`.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **Separation of Concerns**: UI chỉ chứa mã vẽ giao diện và trigger event. Logic xác thực và xử lý Exception được đẩy hoàn toàn về `AuthBloc` và `AuthRepository`.
* **Guest Authentication Shield**: Kiến trúc bảo vệ quyền truy cập mềm dẻo.

---

### 2.2. Màn Hình Đăng Ký Tài Khoản (Register View)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Bên cạnh màn hình Đăng Nhập, màn hình **Đăng Ký Tài Khoản** (`RegisterView`) được thiết kế đồng bộ theo ngôn ngữ thiết kế Kính mờ (Glassmorphism).*
>
> *Màn hình Đăng ký hỗ trợ thu thập và kiểm tra chặt chẽ 5 trường thông tin người dùng:*
> 1. **Họ và tên**: Bắt buộc nhập tối thiểu 2 ký tự.
> 2. **Ngày tháng năm sinh**: Nhấn vào ô nhập để mở ngay một `DatePickerDialog` chọn ngày sinh chuẩn Dark Theme, tự động format định dạng `DD/MM/YYYY`.
> 3. **Email**: Kiểm tra cấu hình chuẩn Regex (ví dụ: `name@domain.com`).
> 4. **Mật khẩu**: Yêu cầu độ bảo mật cao — phải từ 6 ký tự trở lên và phải chứa kết hợp cả chữ lẫn số.
> 5. **Xác nhận mật khẩu**: Đảm bảo chuỗi nhập lại trùng khớp 100% với mật khẩu đã tạo.
>
> *Khi người dùng bấm nút **'Tạo Tài Khoản'**, ứng dụng sẽ gửi yêu cầu đăng ký tới **Supabase Auth Client**. Đồng thời, thông tin Họ tên và Ngày sinh sẽ được lưu trực tiếp vào Profile Manager của hệ thống. 
>
> *Nếu đăng ký thành công, một `SnackBar` thông báo xanh lá ánh kim sẽ xuất hiện và ứng dụng sẽ tự động chuyển người dùng về màn hình Đăng Nhập để tiến hành truy cập."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`GlassCard`**: Khung chứa form mờ mịt sang trọng với đường viền mỏng `neonCoral`.
* **`TextFormField` với `readOnly: true` & `onTap`**: Tích hợp `showDatePicker` mượt mà cho trường chọn Ngày sinh.
* **`obscureText` & `IconButton`**: Nút bật/tắt ẩn hiện mật khẩu và mật khẩu xác nhận riêng biệt (`hidePassword` & `hideConfirmPassword`).
* **`BlocConsumer<AuthBloc, AuthState>`**: Phản hồi sự kiện Đăng ký (`RegisterSuccessState` $\rightarrow$ SnackBar thành công $\rightarrow$ `context.go('/login')`).

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. Người dùng điền đầy đủ form $\rightarrow$ Bấm nút "Tạo Tài Khoản".
2. Form trigger `_formKey.currentState.validate()`.
3. Kiểm tra logic mật khẩu: Độ dài $\ge 6$, chứa chữ & số, khớp mật khẩu xác nhận.
4. Hợp lệ $\rightarrow$ Dispatch `RegisterSubmittedEvent(email, password, name, dob)` tới `AuthBloc`.
5. Supabase Auth xử lý tạo user $\rightarrow$ Trả về `RegisterSuccessState` $\rightarrow$ Cập nhật `UserProfileManager` $\rightarrow$ SnackBar thông báo $\rightarrow$ Điều hướng về `/login`.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **Multi-field Strict Form Validation**: Xử lý validate chặt chẽ ở Client tránh gửi request rác lên Backend Server.
* **Custom Dark Theme DatePicker Integration**: Đồng bộ trải nghiệm thị giác nhất quán ngay cả ở các Dialog hệ thống.

---

### 3. Khung Điều Hướng Main Layout & Preservation State

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Để kết nối các tính năng chính của ứng dụng, em xây dựng khung điều hướng **Main Layout** (`MainLayoutView`) với thanh `BottomNavigationBar` gồm 4 tab: Trang Chủ, Watchlist, Phim Yêu Thích và Tài Khoản.*
>
> *Một bài toán rất phổ biến trong Flutter khi làm Bottom Navigation là: Làm sao khi người dùng đang cuộn dở danh sách phim ở Trang Chủ, chuyển sang tab Watchlist rồi quay lại Trang Chủ, thì trang chủ vẫn giữ nguyên vị trí cuộn cũ mà không bị tải lại (re-build) từ đầu?*
>
> *Để giải bài toán này, em sử dụng **`StatefulShellRoute.indexedStack`** của GoRouter. Kỹ thuật này duy trì một cây trạng thái song song cho từng tab dưới dạng `IndexedStack`. Mỗi tab hoạt động như một nhánh navigation độc lập, giúp tiết kiệm băng thông API và mang lại cảm giác mượt mà tuyệt đối."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`StatefulShellRoute.indexedStack`**: Quản lý nhiều tab nhánh (`branches`).
* **`StatefulNavigationShell`**: Controller điều khiển việc chuyển đổi nhánh qua `navigationShell.goBranch(index)`.
* **`BottomNavigationBar`**: Thanh icon điều hướng chuẩn thiết kế với màu hồng Neon `AppColors.primaryRed` làm điểm nhấn.

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. User chạm vào tab mới $\rightarrow$ Trigger `_onTap(index)`.
2. Controller kiểm tra: Nếu bấm vào chính tab hiện tại $\rightarrow$ Reset về đầu trang; Nếu bấm tab khác $\rightarrow$ Chuyển branch trong bộ nhớ mà không hủy (dispose) state của tab cũ.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **State Preservation**: Tối ưu hiệu năng bộ nhớ RAM và trải nghiệm cuộn liên tục.

---

### 4. Trang Chủ Phim (Home View & Shimmer Skeleton)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Và đây là **Trang Chủ** (`HomeView`) — màn hình quan trọng nhất của app. Trang chủ được chia thành 4 phần dữ liệu điện ảnh sinh động: Banner phim xu hướng nổi bật, Phim Đang Chiếu, Phim Phổ Biến và Phim Đánh Giá Cao.*
>
> *Khi mở trang chủ, trong khoảng thời gian ngắn chờ mạng tải dữ liệu từ API, thay vì để người dùng nhìn màn hình trắng hoặc icon xoay tròn đơn điệu, em đã xây dựng **`MovieSkeletonLoader`** sử dụng thư viện Shimmer. Các khung hình chữ nhật xám sẽ nhấp nháy ánh kim giả lập đúng bố cục thực tế của trang chủ.*
>
> *Sau khi dữ liệu tải xong, toàn bộ phim sẽ hiển thị dưới dạng Carousel lướt tay cực mượt và các dòng phim cuộn ngang. Em cũng tích hợp tính năng **Pull-to-Refresh** (Vuốt xuống để làm mới), giúp người dùng dễ dàng cập nhật danh sách phim mới nhất bất cứ lúc nào."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`BlocProvider<HomeBloc>`**: Khởi tạo BLoC và tự động phát sự kiện `FetchHomeMoviesEvent()`.
* **`TrendingCarouselWidget`**: Dùng `carousel_slider` tạo slide phim xu hướng hiển thị backdrop khổ lớn.
* **`MovieSectionWidget`**: Widget tái sử dụng gồm Tiêu đề section, nút "Xem tất cả" (chuyển sang `CategoryView`) và danh sách phim cuộn ngang `ListView.builder`.
* **`MovieSkeletonLoader`**: Kết hợp `Shimmer.fromColors` giả lập bộ khung UI.
* **`RefreshIndicator`**: Bọc ngoài `SingleChildScrollView` hỗ trợ vuốt để refresh.

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. `HomeView` build $\rightarrow$ Gửi `FetchHomeMoviesEvent` tới `HomeBloc`.
2. `HomeBloc` gọi `HomeRepository`. Tại đây em sử dụng `Future.wait()` trong Dart để thực thi đồng thời 4 lệnh API (Trending, Now Playing, Popular, Top Rated) cùng lúc nhằm giảm tổng thời gian chờ.
3. Khi nhận đủ dữ liệu $\rightarrow$ Emit `HomeLoadedState`. UI chuyển từ Skeleton sang giao diện chính.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **Concurrent HTTP Requests**: Sử dụng lập trình bất đồng bộ nâng cao `Future.wait` rút ngắn thời gian phản hồi API.
* **Modular UI Architecture**: Tách nhỏ các section thành Widget độc lập giúp code cực kỳ sạch sẽ và dễ bảo trì.

---

### 5. Màn Hình Chi Tiết Phim (Movie Detail & Inline Trailer Player)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Khi người dùng nhấn vào bất kỳ bộ phim nào, họ sẽ được chuyển đến **Màn hình Chi tiết Phim** (`MovieDetailView`). Đây là màn hình phức tạp và giàu tương tác nhất trong ứng dụng.*
>
> *Đầu tiên, phần Header sử dụng **`SliverAppBar`** kết hợp với **`YoutubePlayer`**. Khi người dùng bấm nút Play, đoạn Trailer điện ảnh chuẩn HD sẽ phát trực tiếp ngay trên khung giao diện của app mà không bị chuyển qua ứng dụng Youtube ngoài. Nếu video gặp lỗi mạng, app sẽ tự động hỗ trợ fallback mở link ngoài an toàn.*
>
> *Phía dưới là đầy đủ thông tin: Ảnh Poster, Điểm đánh giá (Rating star), Năm phát hành, Thời lượng, các Thẻ thể loại (Genre Chips) và Tóm tắt nội dung phim có nút Thu gọn / Xem thêm.
>
> *Hai nút bấm hành động quan trọng nhất là **'Thêm Watchlist'** và **'Xem Ngay'** được thiết kế nổi bật. Khi người dùng bấm thả tim Yêu thích hoặc lưu Watchlist, ứng dụng sẽ phản hồi tức thì bằng thanh `SnackBar` thông báo dưới đáy màn hình nhờ sử dụng **`MultiBlocListener`**."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`CustomScrollView` & `SliverAppBar`**: Tối ưu hiệu ứng cuộn, biến hình Header co giãn khi cuộn trang.
* **`YoutubePlayerController` & `YoutubePlayer`**: Nhúng trực tiếp trình phát video YouTube.
* **`MultiBlocListener`**: Lắng nghe đồng thời 2 luồng sự kiện thay đổi (Yêu thích & Watchlist) để kích hoạt SnackBar.
* **`Wrap` & `Chip`**: Tự động xuống dòng danh sách các thể loại phim.
* **`PipTrailerManager`**: Quản lý trình phát video cửa sổ thu nhỏ (Picture-in-Picture).

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. `MovieDetailView` nhận dữ liệu phim qua `GoRouter.extra`.
2. `MovieDetailBloc` khởi chạy `FetchMovieDetailEvent(movieId)` để lấy danh sách phim tương tự & key Trailer từ TMDB API.
3. User bấm "Thêm Watchlist" $\rightarrow$ Kiểm tra `UserSession` $\rightarrow$ Nếu Auth valid $\rightarrow$ Dispatch `ToggleWatchlistMovieEvent` $\rightarrow$ Cập nhật Hive DB $\rightarrow$ `BlocListener` bắt trạng thái và hiện SnackBar.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **Reactive UI via MultiBlocListener**: Xử lý phản hồi người dùng (Side-effects) hoàn toàn tách biệt với luồng render UI.
* **Hybrid Video Engine**: Tích hợp Youtube SDK mượt mà với cơ chế tự động xử lý ngoại lệ (Exception Handling).

---

### 6. Màn Hình Tìm Kiếm & Bộ Lọc Đa Tiêu Chí (Search & Multi-Filter)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Màn hình **Tìm kiếm** (`SearchView`) được em thiết kế để giải quyết nhu cầu tìm phim nhanh chóng và chính xác.*
>
> *Người dùng có thể gõ từ khóa tên phim hoặc tên diễn viên vào ô tìm kiếm. Ngay lập tức, kết quả sẽ hiển thị dưới dạng lưới 2 cột bắt mắt.
>
> *Tuy nhiên điểm mạnh nhất của màn hình này là **Bộ lọc đa tiêu chí (Filter Bottom Sheet)**. Khi bấm vào icon Bộ lọc góc phải, một Modal cuộn từ dưới lên cho phép người dùng kết hợp nhiều điều kiện cùng lúc: Lọc theo nhiều Thể loại (Hành động, Hài, Kinh dị...), lọc theo khoảng Năm phát hành (ví dụ từ 2020-2026), lọc theo Điểm đánh giá tối thiểu và Chọn cách Sắp xếp (Theo độ phổ biến, điểm số, hoặc ngày phát hành).*
>
> *Giao diện ứng dụng tự động hiển thị thanh tóm tắt các bộ lọc đang active kèm chấm đỏ đếm số lượng filter. Người dùng có thể xóa nhanh bộ lọc bằng 1 cú chạm."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`TextField`**: Khung nhập từ khóa có icon clear text nhanh.
* **`FilterBottomSheetWidget.show()`**: Custom BottomSheet hiển thị các RangeSlider, FilterChip và Dropdown chọn sắp xếp.
* **`GridView.builder`**: Dựng lưới phim 2 cột tỉ lệ 0.68 chuẩn kích thước poster phim.
* **Stack & Badge**: Hiển thị số bộ lọc đang chọn trên nút Filter.

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. Khởi tạo `SearchBloc` $\rightarrow$ Tải danh sách Thể loại (`FetchGenresEvent`).
2. Nhập từ khóa $\rightarrow$ Dispatch `SearchQueryChangedEvent(query)`.
3. Áp dụng bộ lọc $\rightarrow$ Dispatch `ApplyFilterEvent(movieFilter)`.
4. `SearchBloc` thực hiện lọc dữ liệu $\rightarrow$ Chuyển trạng thái giữa 5 State: `Initial`, `Loading`, `Loaded`, `Empty` (Không tìm thấy) và `Error`.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **State Matrix Design**: Quản lý chặt chẽ 5 trạng thái giao diện phân biệt, tránh hiện tượng màn hình trống hoặc app đứng im khi tìm kiếm không ra kết quả.
* **Complex Data Filtering Entity**: Xây dựng Class `MovieFilter` chứa toàn bộ tiêu chí lọc giúp mã nguồn sạch sẽ.

---

### 7. Màn Hình Watchlist Xem Sau (Hive Storage & Swipe-to-Delete)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Màn hình **Watchlist** (`WatchlistView`) giúp người dùng lưu lại những bộ phim họ dự định sẽ xem trong tương lai.*
>
> *Tại đây, em mang lại cho người dùng sự tự do tối đa trong trải nghiệm: Họ có thể bấm icon ở góc phải để **chuyển đổi linh hoạt giữa Dạng Danh Sách (List View) và Dạng Lưới (Grid View)** tùy sở thích. Họ cũng có thể sắp xếp danh sách theo Phim mới thêm, Điểm đánh giá cao nhất hoặc Tên A-Z.*
>
> *Đặc biệt, em đã cài đặt thao tác **Vuốt để xóa (Swipe-to-Delete)** với trải nghiệm cực kỳ an toàn. Khi người dùng vuốt một thẻ phim sang trái, nền đỏ icon thùng rác sẽ xuất hiện và phim được xóa khỏi danh sách. Ngay sau đó, thanh `SnackBar` sẽ hiện lên với nút **'Hoàn tác' (Undo)**. Nếu người dùng lỡ tay vuốt nhầm, chỉ cần bấm 'Hoàn tác', bộ phim sẽ lập tức quay trở lại danh sách như cũ!*
>
> *Toàn bộ dữ liệu Watchlist được lưu trữ trực tiếp dưới máy bằng **Hive Local Database**, cho phép người dùng xem lại danh sách xem sau của mình ngay cả khi đang trên máy bay hay không có mạng Internet."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`Dismissible`**: Widget xử lý vuốt trượt phần tử danh sách có `background` màu đỏ và `onDismissed` callback.
* **`PopupMenuButton`**: Dropdown chọn tiêu chí sắp xếp động.
* **`SliverList` & `SliverGrid`**: Kết hợp với `CustomScrollView` để render danh sách/lưới hiệu năng cao.
* **`SnackBarAction`**: Xử lý khôi phục dữ liệu (Undo action).

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. Mở màn hình $\rightarrow$ `WatchlistBloc` phát `LoadWatchlistEvent`.
2. `WatchlistRepositoryImpl` query danh sách `WatchlistItem` từ Hive Box local.
3. Vuốt xóa phần tử $\rightarrow$ Trigger `RemoveFromWatchlistEvent(id)` $\rightarrow$ Hive xóa record $\rightarrow$ Hiển thị SnackBar Undo.
4. Nếu bấm Undo $\rightarrow$ Trigger `AddItemToWatchlistEvent(item)` $\rightarrow$ Hive ghi lại record $\rightarrow$ BLoC reload lại UI.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **Offline-First Architecture**: Sử dụng Hive DB (NoSQL key-value store viết bằng Dart thuần cho tốc độ ghi/đọc siêu tốc).
* **Optimistic UI Updates with Undo Pattern**: Mang lại trải nghiệm người dùng tuyệt vời và an toàn với dữ liệu.

---

### 8. Màn Hình Phim Yêu Thích (Favorites & Real-time Sync)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Màn hình **Phim Yêu Thích** (`FavoritesView`) là nơi lưu giữ những tác phẩm điện ảnh mà người dùng yêu thích nhất.*
>
> *Giao diện màn hình hiển thị danh sách các thẻ phim bo góc mềm mại, hiển thị ảnh poster, tên phim, năm phát hành, thể loại và icon trái tim đỏ nổi bật.*
>
> *Điểm hay ở màn hình này là **sự đồng bộ dữ liệu thời gian thực (Real-time State Sync)**. Trạng thái thả tim được quản lý tập trung qua `HomeController` Singleton. Khi người dùng thả tim một bộ phim ở Trang Chủ hay màn hình Chi tiết Phim, bộ phim đó ngay lập tức xuất hiện tại màn hình Phim Yêu Thích. Ngược lại, nếu người dùng bỏ thả tim ở màn hình này, bộ phim sẽ tự động biến mất và icon trái tim ở các màn hình khác cũng tự động bỏ chọn theo."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`Card` & `InkWell`**: Thẻ phim chuẩn Material 3 với hiệu ứng gợn sóng (Ripple Effect) khi nhấn.
* **`IconButton`**: Icon trái tim màu đỏ `AppColors.primaryRed` cho phép hủy yêu thích nhanh.
* **`ListView.builder`**: Render danh sách các phim yêu thích mượt mà.

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. User bấm vào Icon trái tim $\rightarrow$ Gọi `HomeController.instance.doiTrangThaiYeuThich(movie)`.
2. Trạng thái boolean `yeuThich` được đảo ngược.
3. Cập nhật danh sách `danhSachYeuThich` $\rightarrow$ Trực tiếp refresh UI ở tất cả các view đăng ký lắng nghe.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **Global State Synchronization**: Đồng bộ trạng thái nhất quán trên toàn bộ ứng dụng mà không bị lệch dữ liệu giữa các màn hình.

---

### 9. Trang Cá Nhân & Chuyển Đổi Dark/Light Theme (Profile & ThemeCubit)

#### 🎙️ Kịch bản văn nói chi tiết (Bản nói dài):
> *"Cuối cùng, em xin giới thiệu màn hình **Trang Cá Nhân** (`ProfileView`). Màn hình này quản lý toàn bộ thông tin cá nhân và cài đặt ứng dụng của người dùng.*
>
> *Phía trên cùng là phần Avatar bo tròn có viền đỏ Neon nổi bật, Huy hiệu thành viên VIP, Tên người dùng và Email. Ngay bên dưới là **3 Thẻ Thống kê nhanh**: Tổng số Phim đã xem, Số phim trong Watchlist và Số lượt Đánh giá. người dùng có thể bấm vào thẻ 'Phim đã xem' để mở lịch sử xem video (`WatchedVideosView`) hoặc bấm 'Chỉnh sửa profile' để cập nhật thông tin (`PersonalInfoView`).*
>
> *Đặc biệt nhất tại màn hình này là nút gạt **'Chế độ Giao diện' (Dark/Light Theme)**. Ứng dụng của em hỗ trợ đầy đủ 2 bộ Theme: Dark Theme (chuẩn phong cách rạp phim tối) và Light Theme (giao diện sáng tươi tắn). Khi người dùng gạt nút switch, ứng dụng sử dụng **`ThemeCubit`** để thay đổi `ThemeMode` toàn cục ngay lập tức mà không cần khởi động lại ứng dụng."*

#### 🧩 Widget & Giao diện cốt lõi:
* **`CircleAvatar` & `Stack`**: Tạo Avatar cá nhân kèm nút chỉnh sửa góc dưới.
* **`ValueListenableBuilder`**: Lắng nghe `UserProfileManager` và `WatchHistoryManager` để tự động update số lượng phim đã xem mà không re-build toàn màn hình.
* **`Switch`**: Nút gạt đổi Dark/Light mode.
* **`ElevatedButton.icon`**: Nút 'Đăng Xuất' màu đỏ nổi bật xử lý xoá session Supabase.

#### 🔄 Luồng xử lý kỹ thuật (Execution Flow):
1. Người dùng gạt `Switch` $\rightarrow$ Trigger `getIt<ThemeCubit>().setThemeMode(...)`.
2. `ThemeCubit` phát ra State `ThemeMode.dark` hoặc `ThemeMode.light`.
3. `BlocBuilder<ThemeCubit>` bọc ngoài `MaterialApp.router` tại `main.dart` nhận State mới $\rightarrow$ Chuyển đổi toàn bộ màu sắc App theo `AppTheme.darkTheme` / `AppTheme.lightTheme`.

#### 💡 Điểm sáng kỹ thuật với Mentor:
* **Dynamic Global Theme Management**: Quản lý Theme tập trung bằng BLoC/Cubit, đảm bảo chuẩn tương thích truy cập mắt nhìn và tiết kiệm pin (OLED Dark Mode).
* **Lightweight Reactive State with ValueNotifier**: Tối ưu hiệu năng bộ nhớ cho các dữ liệu nhỏ lẻ.

---

## 🎯 PHẦN 3: BẢNG TỔNG HỢP KIẾN THỨC KỸ THUẬT (Q&A PHẢN BIỆN CHI TIẾT)

Khi Mentor đặt câu hỏi chất vấn về kỹ thuật, bạn chỉ cần dùng bảng tra cứu phản biện dưới đây:

### ❓ Câu 1: "Tại sao em chọn BLoC Pattern mà không dùng Provider hay GetX?"
> ** trả lời ghi điểm:** *"Dạ thưa anh/thầy, Provider rất tốt cho các app nhỏ, còn GetX thì nhanh nhưng dễ làm code bị phụ thuộc chặt (tight coupling) và khó viết Unit Test. Em chọn **BLoC (Business Logic Component)** vì nó tuân thủ triệt để nguyên lý **Separation of Concerns**. BLoC giúp tách biệt hoàn toàn giữa giao diện UI (phát Event) và Logic xử lý (trả về State). Điều này giúp mã nguồn vô cùng rõ ràng, dễ bảo trì khi dự án phát triển lớn và cực kỳ thuận tiện cho việc viết **Unit Test cho BLoC** bằng thư viện `bloc_test` ạ."*

---

### ❓ Câu 2: "Clean Architecture trong dự án của em được phân chia như thế nào?"
> ** trả lời ghi điểm:** *"Dạ, dự án của em phân chia thành 3 lớp rõ ràng theo đúng chuẩn Clean Architecture:*
> 1. **Presentation Layer**: Chứa UI Views, Custom Widgets và BLoCs/Cubits.
> 2. **Domain Layer**: Chứa Business Logic cốt lõi gồm Entities (Movie, WatchlistItem), Use Cases và Repositories Interfaces. Lớp này độc lập hoàn toàn, không phụ thuộc vào bất kỳ thư viện ngoài nào.
> 3. **Data Layer**: Chứa Data Sources (giao tiếp API Dio & Supabase, giao tiếp Local DB Hive), Data Models (Json Serializable) và Repositories Implementation."*

---

### ❓ Câu 3: "Em xử lý lưu trữ Offline và Caching dữ liệu như thế nào?"
> ** trả lời ghi điểm:** *"Dạ, em kết hợp giữa **Hive DB** và **CachedNetworkImage**:*
> * Dữ liệu danh sách phim xem sau (Watchlist) và lịch sử xem video được lưu vào **Hive Local Box** dưới dạng NoSQL key-value store. Hive được viết 100% bằng Dart nên tốc độ đọc/ghi siêu nhanh và không cần file mã hóa phức tạp như SQLite.
> * Về hình ảnh Poster/Backdrop, em dùng `cached_network_image` tự động lưu bản cache ảnh vào bộ nhớ tạm của thiết bị, giúp lần mở thứ 2 ảnh hiển thị tức thì mà không tốn dung lượng 4G/Wifi của người dùng."*

---

### ❓ Câu 4: "Ứng dụng của em tối ưu hiệu năng (Performance Optimization) ra sao?"
> ** trả lời ghi điểm:** *"Dạ em tối ưu hiệu năng ở 4 điểm chính:*
> 1. Sử dụng **`StatefulShellRoute.indexedStack`** để giữ nguyên trạng thái các tab mà không re-build lại UI.
> 2. Sử dụng **`Future.wait()`** để gọi song song các HTTP Request ở Trang Chủ thay vì gọi nối tiếp.
> 3. Thêm từ khóa **`const`** trước các Widget tĩnh để Flutter không cần tạo lại Widget Object trong cây RenderTree.
> 4. Áp dụng **Shimmer Skeleton Loading** để nâng cao trải nghiệm người dùng trong lúc chờ mạng."*

---

## 💬 PHẦN 4: LỜI KẾT THUYẾT TRÌNH

### 🎙️ Kịch bản văn nói (Đọc trực tiếp):
> *"Thưa anh/thầy [Tên Mentor], trên đây là toàn bộ phần trình bày của em về kiến trúc, tính năng và các giải pháp kỹ thuật em đã gửi gắm vào ứng dụng **'Góc Phim'**.*
>
> *Qua quá trình thực hiện dự án này, em không chỉ rèn luyện được tư duy thiết kế giao diện UI/UX chuẩn Cinema, mà quan trọng hơn là đã làm chủ được mô hình **Clean Architecture**, **BLoC State Management** và kỹ năng tích hợp các dịch vụ Cloud như **Supabase** cũng như CSDL Local **Hive**.*
>
> *Em rất mong nhận được những góp ý, định hướng từ anh/thầy để em có thể tiếp tục phát triển dự án này hoàn thiện hơn nữa trong tương lai. Em xin chân thành cảm ơn anh/thầy đã dành thời gian lắng nghe phần thuyết trình của em!"*
