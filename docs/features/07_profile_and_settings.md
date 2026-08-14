# 👤 PHÂN HỆ 7: TÀI KHOẢN & CÀI ĐẶT (PROFILE & SETTINGS)

Tài liệu chi tiết về hành động Giao diện (UI Action), luồng xử lý hệ thống (Execution Flow) và sơ đồ chức năng cho phân hệ Quản lý Trang cá nhân và Cài đặt ứng dụng.

---

## 1. Thành phần Giao diện & Thao tác UI (UI Actions)

* **Trang cá nhân ([profile_view.dart](file:///c:/Users/khoa/movie_app/lib/features/profile/views/profile_view.dart)):**
  * `[Header] Info User`: Ảnh đại diện, Tên hiển thị, Email tài khoản từ `UserProfileManager`.
  * `[Item] Thông tin cá nhân`: Mở màn hình chỉnh sửa hồ sơ `PersonalInfoView`.
  * `[Item] Lịch sử xem`: Mở màn hình quản lý lịch sử xem phim `WatchedVideosView`.
  * `[Switch] Chế độ Tối/Sáng`: Bật/Tắt chế độ tối (Dark Mode) hoặc sáng (Light Mode).
  * `[Item] Đăng xuất`: Đăng xuất tài khoản và quay về màn hình Login.

* **Chỉnh sửa Thông tin cá nhân ([personal_info_view.dart](file:///c:/Users/khoa/movie_app/lib/features/profile/views/personal_info_view.dart)):**
  * `[TextField] Họ tên & Avatar URL`: Chỉnh sửa tên hiển thị và liên kết ảnh đại diện.
  * `[Button] Lưu thay đổi`: Cập nhật thông tin lên Supabase User Metadata và bộ nhớ đệm `UserProfileManager`.

* **Lịch sử đã xem ([watched_videos_view.dart](file:///c:/Users/khoa/movie_app/lib/features/profile/views/watched_videos_view.dart)):**
  * `[List] Phim đã xem`: Danh sách các phim/trailer đã từng xem kèm thời gian.
  * `[Button] Xóa lịch sử`: Xóa sạch nhật ký xem phim trong `WatchHistoryManager`.

---

## 2. Ma trận Ánh xạ Luồng (UI Action -> Execution Flow)

| Thao tác UI (Action) | Component / Widget | Luồng xử lý Hệ thống (Execution Flow) |
| :--- | :--- | :--- |
| **Toggle Switch Theme** | `ProfileView` | `ThemeCubit.toggleTheme()` -> Emits `ThemeMode.dark` / `ThemeMode.light` -> Re-render app theme. |
| **Press "Lưu thay đổi"** | `PersonalInfoView` | `UserProfileManager.updateProfile()` -> Update Supabase Auth user metadata -> Refresh UI. |
| **Press "Xóa lịch sử"** | `WatchedVideosView` | `WatchHistoryManager.clearHistory()` -> Reset history log -> Render empty list. |
| **Press "Đăng xuất"** | `ProfileView` | Supabase `auth.signOut()` -> `UserSession.clear()` -> `context.go('/login')`. |

---

## 3. Sơ đồ Luồng Hoạt động (Mermaid Diagram)

```mermaid
flowchart TD
    ProfileView([Người dùng mở ProfileView]) --> ProfileAction{Hành động Chọn}
    
    ProfileAction -->|Toggle Switch Dark/Light| ThemeAction[ThemeCubit: toggleTheme]
    ThemeAction --> UpdateTheme[MaterialApp: Re-render Dark/Light Theme]
    
    ProfileAction -->|Click 'Thông tin cá nhân'| EditInfo[PersonalInfoView: Sửa Tên/Avatar]
    EditInfo --> SaveInfo[Press 'Lưu'] --> UpdateMetadata[Update Supabase User Metadata & UserProfileManager]
    
    ProfileAction -->|Click 'Lịch sử xem'| HistoryView[WatchedVideosView: Xem/Xóa nhật ký xem]
    HistoryView --> ClearHistory[Press 'Xóa lịch sử'] --> ResetLog[WatchHistoryManager: clearHistory]
    
    ProfileAction -->|Click 'Đăng xuất'| LogoutAction[Supabase auth.signOut]
    LogoutAction --> ClearSession[UserSession.clear] --> RedirectLogin[GoRouter: context.go('/login')]
```
