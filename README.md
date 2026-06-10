# Task Manager App

Ứng dụng quản lý và nhắc nhở công việc cá nhân, xây dựng bằng Flutter. Hỗ trợ đa nền tảng Android, iOS, Web, Windows, macOS và Linux.

## Tính năng

### Quản lý công việc
- Tạo, chỉnh sửa, xóa công việc với tiêu đề, mô tả, ngày hết hạn
- Phân loại theo danh mục: Công việc, Học tập, Cá nhân, Sức khỏe, Khác
- Mức độ ưu tiên: Thấp / Trung bình / Cao
- Công việc lặp lại: hàng ngày, hàng tuần, hàng tháng, hàng năm
- Subtasks (công việc con) bên trong mỗi task
- Gắn tag tùy chỉnh (màu sắc tự chọn) cho từng task
- Tìm kiếm và lọc công việc theo trạng thái, danh mục, ưu tiên
- Vuốt để hoàn thành hoặc xóa nhanh

### Nhắc nhở & Thông báo
- Đặt thông báo nhắc nhở cho từng công việc
- Hỗ trợ quyền thông báo trên Android và iOS

### Lịch
- Xem công việc theo dạng lịch tháng
- Highlight ngày có công việc cần làm

### Mục tiêu
- Tạo mục tiêu dài hạn và liên kết các task với mục tiêu đó
- Theo dõi tiến độ hoàn thành mục tiêu

### Pomodoro Timer
- Đồng hồ đếm ngược theo kỹ thuật Pomodoro (làm việc / nghỉ ngắn / nghỉ dài)
- Liên kết phiên Pomodoro với task cụ thể
- Đếm số Pomodoro đã hoàn thành cho mỗi task

### Báo cáo & Thống kê
- Biểu đồ thống kê công việc hoàn thành theo tuần/tháng
- Phân tích theo danh mục và mức độ ưu tiên

### Thành tựu & Streak
- Theo dõi chuỗi ngày hoàn thành công việc liên tiếp
- Huy hiệu thành tựu theo số task hoàn thành và số Pomodoro

### Giao diện & Cài đặt
- Hỗ trợ Dark Mode / Light Mode / Theo hệ thống
- Thiết kế Material Design 3
- Quick Actions: nhấn giữ icon app để nhanh chóng thêm task, mở Pomodoro, xem lịch hoặc báo cáo

## Công nghệ sử dụng

| Thành phần | Thư viện |
|---|---|
| State management | `provider` |
| Database local | `sqflite` |
| Thông báo | `flutter_local_notifications`, `timezone` |
| Biểu đồ | `fl_chart` |
| Lịch | `table_calendar` |
| Chọn màu | `flutter_colorpicker` |
| Quick Actions | `quick_actions` |
| UI helpers | `flutter_slidable`, `intl` |

## Cài đặt & Chạy

**Yêu cầu:** Flutter SDK >= 3.0.0

```bash
# Clone repo
git clone https://github.com/hnguyeennn/taskmanagerapp.git
cd taskmanagerapp

# Cài dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

## Cấu trúc thư mục

```
lib/
├── main.dart
├── models/          # Task, Goal, Tag, Subtask, PomodoroSession...
├── screens/         # Các màn hình: Home, Calendar, Goals, Pomodoro, Reports...
├── services/        # Provider, Database, Notification, Streak, Report...
├── widgets/         # TaskCard, GoalCard, StreakCard, SubtasksEditor...
└── utils/           # Màu sắc, hàm tiện ích
```

## Nền tảng hỗ trợ

- Android
- iOS
- Web
- Windows
- macOS
- Linux
