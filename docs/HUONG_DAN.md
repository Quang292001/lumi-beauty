# Hướng dẫn: cài đặt, chạy, hiểu code & chuẩn bị phỏng vấn

> File này dành cho bạn đọc riêng. Có thể xoá khỏi repo trước khi push nếu không muốn công khai.

---

## 1. Cài Flutter trên Windows (≈ 30–45 phút)

1. Tải Flutter SDK (Windows, bản **stable**): https://docs.flutter.dev/get-started/install/windows/mobile
2. Giải nén vào `C:\src\flutter` (**không** để trong `Program Files` hay thư mục có dấu cách).
3. Thêm `C:\src\flutter\bin` vào biến môi trường **Path** (Start → "Edit environment variables for your account" → Path → New).
4. Mở terminal mới, chạy:
   ```bash
   flutter doctor
   ```
5. Máy bạn đã có thư mục `.android` nên có thể đã cài Android Studio. Nếu chưa:
   - Cài **Android Studio** → mở **SDK Manager** → cài *Android SDK Command-line Tools*.
   - Chạy `flutter doctor --android-licenses` và bấm `y` hết.
   - Mở **Device Manager** → tạo máy ảo (Pixel 7, API 34+).
6. VS Code: cài extension **Flutter** (tự cài kèm Dart).

`flutter doctor` báo lỗi Visual Studio / Chrome thì bỏ qua được, vì mình chỉ chạy Android.

## 2. Chạy project

Project chỉ có code Dart (`lib/`, `test/`), chưa có thư mục `android/`, `ios/`. Bạn tạo chúng bằng một lệnh:

```bash
cd C:\Users\User\Projects\lumi_beauty
flutter create --org com.quang --project-name lumi_beauty --platforms android,ios .
flutter pub get
flutter test        # 4 file test phải PASS hết
flutter run         # bật máy ảo trước
```

`flutter create .` chỉ thêm file còn thiếu, **không ghi đè** code trong `lib/` và `test/`.

**Quan trọng – quyền Internet cho bản release (APK):** mở `android/app/src/main/AndroidManifest.xml`, thêm dòng này ngay trên thẻ `<application`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Build APK để gửi nhà tuyển dụng hoặc đính kèm GitHub Release:

```bash
flutter build apk --release
# file: build/app/outputs/flutter-apk/app-release.apk
```

> Lưu ý: app dùng `sqflite` nên **không chạy trên Web/Chrome** hay Windows desktop. Chạy bằng máy ảo Android hoặc điện thoại thật (bật USB debugging).

### Đưa lên GitHub

```bash
git init
git add .
git commit -m "feat: Lumi Beauty - Flutter cosmetics shopping app"
git branch -M main
git remote add origin https://github.com/Quang292001/lumi-beauty-flutter.git
git push -u origin main
```

Chụp 3–4 màn hình (Home, Detail, Cart, Login), bỏ vào `screenshots/` rồi sửa bảng ảnh trong README. Nhà tuyển dụng thường chỉ lướt README, nên ảnh rất quan trọng.

---

## 3. Đọc code theo thứ tự này

| Bước | File | Bạn cần hiểu |
|---|---|---|
| 1 | `main.dart`, `app.dart` | `runApp`, `MultiProvider`, `AuthGate` chọn màn hình theo trạng thái đăng nhập |
| 2 | `models/product.dart` | `factory fromJson`, `toJson`, getter tính giá, null-safety (`??`, `?.`) |
| 3 | `core/api_client.dart` | `async/await`, `Future`, `try/on`, `jsonDecode`, header Bearer token |
| 4 | `services/product_service.dart` | Gọi endpoint, query param `skip/limit`, parse thành model |
| 5 | `providers/cart_provider.dart` | `ChangeNotifier`, `notifyListeners()`, business logic giỏ hàng |
| 6 | `data/cart_repository.dart` | `abstract class` + `implements`, SQLite query/insert/update/delete |
| 7 | `providers/paged_products_provider.dart` | Phân trang, chống race condition bằng `_generation` |
| 8 | `widgets/paged_product_grid.dart` | `context.watch`, `CustomScrollView`, `SliverGrid`, infinite scroll |
| 9 | `screens/*` | `StatelessWidget` vs `StatefulWidget`, `setState`, `Navigator.push`, `Form` |
| 10 | `test/*` | Viết test với repository giả |

Mẹo: đặt breakpoint trong `ApiClient._send` rồi chạy debug để xem request/response thật.

### So sánh nhanh với React (bạn đã biết)

| React | Flutter |
|---|---|
| Component | Widget |
| `props` | tham số constructor (`final` field) |
| `useState` + re-render | `StatefulWidget` + `setState()` |
| Context / Redux / Zustand | `Provider` + `ChangeNotifier` |
| `useContext(X)` | `context.watch<X>()` (lắng nghe) / `context.read<X>()` (không lắng nghe) |
| `useEffect(() => {...}, [])` | `initState()` |
| cleanup của useEffect | `dispose()` |
| `fetch` / axios + Promise | `http` + `Future` / `async-await` |
| `.map()` render list | `ListView.builder` / `GridView.builder` |
| flexbox | `Row`, `Column`, `Expanded`, `Flexible` |
| React Router | `Navigator.push` / `pop` |
| localStorage | `shared_preferences` |
| Jest + RTL | `flutter_test` (`test`, `testWidgets`) |

---

## 4. Kế hoạch 5 ngày (hạn nộp 18/11)

| Ngày | Việc |
|---|---|
| 13–14/11 | Cài Flutter, chạy app + test, push GitHub, cập nhật CV và **nộp đơn sớm** |
| 14/11 | Học Dart cơ bản: biến, null safety, class, `async/await` (https://dart.dev/language) |
| 15/11 | Đọc code bước 1–6 ở bảng trên, tự giải thích lại bằng lời |
| 16/11 | Tự thêm 1 tính năng nhỏ (gợi ý bên dưới) và commit, để có thể nói "chính em làm phần này" |
| 17/11 | Luyện câu hỏi phỏng vấn ở mục 5, nói to lên |

**Tính năng nhỏ để tự làm:**
- Sắp xếp theo giá trong tab danh mục (API hỗ trợ `?sortBy=price&order=asc`).
- Lọc chỉ sản phẩm đang giảm giá.
- Màn hình "Lịch sử đơn hàng": lưu đơn vào bảng SQLite `orders` khi checkout (dùng thêm SQL, JD ghi là lợi thế).
- Dark mode.

---

## 5. Câu hỏi phỏng vấn thường gặp (kèm gợi ý trả lời theo project)

**Dart / Flutter cơ bản**

1. *StatelessWidget vs StatefulWidget?* Stateless không có state nội bộ, chỉ dựa vào tham số. Stateful có `State` và `setState()` để build lại. VD: `ProductCard` là stateless, `ProductDetailScreen` là stateful vì giữ `_quantity`.
2. *Vòng đời StatefulWidget?* `createState` → `initState` → `didChangeDependencies` → `build` → (`didUpdateWidget`) → `dispose`. Em tạo provider trong `initState` và giải phóng trong `dispose` (`_CategoryTab`), và dispose `TextEditingController` ở login/search.
3. *`const` constructor có tác dụng gì?* Widget được tạo một lần lúc compile và tái sử dụng, Flutter bỏ qua việc rebuild nên nhanh hơn.
4. *Null safety?* `String?` là kiểu có thể null; dùng `??` (giá trị mặc định), `?.` và `!`. Trong `Product.fromJson`, mọi trường đều có giá trị mặc định nên API thiếu field cũng không crash (có test riêng).
5. *`Future` và `async/await`?* `Future` là giá trị sẽ có trong tương lai, giống Promise. `await` chờ mà không chặn UI vì Dart chạy single-thread với event loop.
6. *`final` vs `const`?* `final` gán một lần lúc chạy, `const` là hằng số lúc compile.
7. *Widget tree, Element tree, RenderObject?* Widget là bản mô tả (immutable). Element giữ vị trí trong cây và state. RenderObject lo layout/paint. `setState` đánh dấu element là dirty để build lại.
8. *`BuildContext` là gì?* Vị trí của widget trong cây, dùng để tìm Provider/Theme/Navigator ở phía trên.

**State management**

9. *Tại sao chọn Provider?* Nhẹ, được Flutter team khuyến nghị cho người mới, đủ cho app quy mô vừa. Em biết các lựa chọn khác như Riverpod, Bloc.
10. *`watch` vs `read` vs `select`?* `watch` build lại khi có thay đổi. `read` chỉ lấy object, dùng trong callback. `select` chỉ build lại khi một giá trị cụ thể đổi: `ProductCard` dùng `select` để chỉ card đó build lại khi bấm tim, badge giỏ hàng chỉ nghe `totalQuantity`.
11. *Optimistic update?* `CartProvider.add` cập nhật UI ngay rồi mới ghi SQLite, để người dùng không phải chờ.

**API / dữ liệu**

12. *Tích hợp REST API thế nào?* Có lớp `ApiClient` chung (base URL, header, Bearer token, timeout, chuyển lỗi HTTP/mạng thành `ApiException` tiếng Việt). Các service gọi endpoint và map JSON sang model qua `fromJson`.
13. *Phân trang?* Dùng `skip/limit`. Khi cuộn gần cuối (còn dưới 400px) thì gọi `loadMore`. `hasMore = skip + số item < total`. Có cờ `_isLoading` để không gọi trùng.
14. *Race condition khi search?* Có debounce 400ms. Mỗi lần tải lại thì tăng `_generation`; response cũ về muộn sẽ bị bỏ qua (có unit test).
15. *Lưu token ở đâu, có an toàn không?* Hiện lưu bằng `shared_preferences`. Trên production nên dùng `flutter_secure_storage` (Keychain/Keystore) và có cơ chế refresh token.
16. *Tại sao dùng SQLite cho giỏ hàng?* Giỏ hàng vẫn còn khi tắt app. Có khoá chính `product_id`, `CHECK (quantity > 0)`. Repository pattern giúp đổi sang API giỏ hàng của backend mà không phải sửa Provider.

**Chất lượng / quy trình**

17. *Bạn test gì?* Unit test cho model (parse JSON, tính giá), CartProvider (cộng dồn, giới hạn tồn kho, phí ship), phân trang/race condition; widget test cho `QuantitySelector`. Dùng `FakeCartRepository` thay SQLite.
18. *Tối ưu hiệu năng?* `const` widget, `ListView/GridView.builder` (lazy), `select` để giảm rebuild, cache ảnh, `AutomaticKeepAliveClientMixin` để không tải lại tab, `IndexedStack` giữ state của bottom tab.
19. *Git flow?* Nhánh `feature/*`, commit message theo Conventional Commits (`feat:`, `fix:`), tạo Pull Request để review.
20. *Hạn chế của app / sẽ cải thiện gì?* Chưa có thanh toán thật, chưa có refresh token, search phụ thuộc dữ liệu tiếng Anh của API. Hướng phát triển: Riverpod/Bloc, `go_router`, secure storage, CI chạy `flutter test`.

**Câu "khó" nên chuẩn bị sẵn:** *"Em làm Flutter bao lâu rồi?"* Hãy trả lời thật: em có nền React và .NET/Node; khi thấy JD em đã tự học Flutter và làm project này để chứng minh khả năng học nhanh. Các khái niệm như component, state, gọi API, JWT em đã dùng ở các project React nên chuyển sang Flutter khá nhanh.

---

## 6. Gợi ý ghi vào CV

**Lumi Beauty – Flutter Cosmetics Shopping App** · *Personal project* · GitHub: github.com/Quang292001/lumi-beauty-flutter
*Flutter, Dart, Provider, REST API, SQLite (sqflite), JWT, Git*

- Phát triển ứng dụng mua sắm mỹ phẩm Android/iOS với 7 màn hình: đăng nhập, danh mục, tìm kiếm, chi tiết, giỏ hàng, yêu thích, tài khoản.
- Tích hợp RESTful API (JSON), đăng nhập bằng JWT, tự đăng nhập lại bằng token; xây dựng `ApiClient` xử lý timeout và lỗi mạng tập trung.
- Áp dụng kiến trúc phân lớp (Model – Service/Repository – Provider – UI); lưu giỏ hàng và yêu thích offline bằng SQLite.
- Infinite scroll phân trang, tìm kiếm có debounce, xử lý đủ trạng thái loading/error/empty.
- Viết unit test và widget test với `flutter_test`.
