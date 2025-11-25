import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth
import 'package:applamdep/UI/profile/profile_screen.dart'; // 1. Import ProfileScreen

// 2. Chuyển thành StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 3. Biến để lưu tên người dùng
  String? _userName;

  @override
  void initState() {
    super.initState();
    // 4. Lấy thông tin người dùng khi màn hình khởi tạo
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Ưu tiên displayName, nếu không có thì dùng email
      _userName = user.displayName ?? user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Chiếm toàn bộ chiều rộng
        height: double.infinity, // Chiếm toàn bộ chiều cao
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
        child: Stack(
          children: [
            // --- PHẦN NỘI DUNG CHÍNH (SCROLLABLE) ---
            Positioned.fill(
              top: 52, // Chừa chỗ cho Status Bar/Header giả
              bottom: 80, // Chừa chỗ cho Bottom Navigation
              child: SingleChildScrollView(
                child: Container(
                  // Width 393 theo thiết kế gốc, nhưng để double.infinity để responsive
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // spacing: 20, // Lưu ý: spacing chỉ có ở Flutter mới nhất (Dart 3.3+). Tôi dùng SizedBox thay thế để an toàn.
                    children: [
                      // 1. Header & Search
                      _buildTopSection(),
                      const SizedBox(height: 20),

                      // 2. Special Offers
                      _buildSpecialOffers(),
                      const SizedBox(height: 20),

                      // 3. Services Grid
                      _buildServicesList(),
                      const SizedBox(height: 20),

                      // 4. Most Monthly
                      _buildMostMonthly(),
                      const SizedBox(height: 20),

                      // 5. Salons Near You
                      _buildSalonsNearYou(),

                      // Khoảng trống dưới cùng để không bị che
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // --- STATUS BAR GIẢ (TOP) ---
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Container(
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5), // Màu nền trùng khớp
                ),
                // Ẩn status bar giả của thiết kế vì thiết bị thật đã có
              ),
            ),

            // --- BOTTOM NAVIGATION BAR (BOTTOM) ---
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 24,
                ), // Thêm padding bottom cho iPhone X+
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  border: Border(top: BorderSide(color: Color(0xFFE0E2E5))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, 'Home', const Color(0xFFF25278)),
                    _buildNavItem(
                      Icons.grid_view,
                      'Collection',
                      const Color(0xFF8F929C),
                    ),
                    _buildNavItem(
                      Icons.calendar_today,
                      'Booking',
                      const Color(0xFF8F929C),
                    ),
                    _buildNavItem(
                      Icons.explore_outlined,
                      'Discover',
                      const Color(0xFF8F929C),
                    ),
                    // 2. Bọc widget Profile bằng GestureDetector để thêm sự kiện onTap
                    GestureDetector(
                      onTap: () {
                        // 3. Điều hướng đến màn hình Profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: _buildNavItem(
                        Icons.person_outline,
                        'Profile',
                        const Color(0xFF8F929C),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- FLOATING BUTTON (AI ICON) ---
            Positioned(
              right: 16,
              bottom: 100, // Nằm trên Bottom Nav
              child: Container(
                height: 208,
                // Phần này trong thiết kế mẫu có vẻ chứa cả shadow dài
                // Tôi chỉ giữ lại nút tròn chính
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF25278),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 7.60,
                        offset: Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON ĐƯỢC TÁCH RA TỪ MÃ MẪU ĐỂ GỌN GÀNG ---

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 5. Thay đổi UI để hiển thị lời chào
                  const Text(
                    'Hello, Welcome 👋',
                    style: TextStyle(
                      color: Color(0xFF7B7D87), // Màu xám hơn
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        // Hiển thị tên người dùng, nếu không có thì hiển thị 'Guest'
                        _userName ?? 'Guest',
                        style: const TextStyle(
                          color: Color(0xFF313235),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Notification Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar
          Container(
            width: double.infinity,
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: ShapeDecoration(
              color: const Color(0xFFEEF0F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Color(0xFFB8BCC1), size: 24),
                SizedBox(width: 12),
                Text(
                  'Search services, salons...',
                  style: TextStyle(
                    color: Color(0xFFB8BCC1),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Special Offers',
            style: TextStyle(
              color: Color(0xFF313235),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Banner trượt ngang
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Banner 1
              SizedBox(
                width: 284,
                height: 166,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://images.unsplash.com/photo-1604654894610-df63bc536371?w=500&q=80",
                            ), // Ảnh mẫu
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Lớp phủ màu hồng bên trái
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 155,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF25278),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Positioned(
                              top: 20,
                              left: 25,
                              child: Text(
                                'Nail Store',
                                style: TextStyle(
                                  color: Color(0xFFFFF2F4),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              left: 20,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '20',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 72,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        '%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'OFF',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 25,
                              left: 25,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                color: Colors.black,
                                child: const Text(
                                  'CART COUPON July 16',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Banner 2 (Demo)
              Container(
                width: 284,
                height: 166,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1522337660859-02fbefca4702?w=500&q=80",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF25278),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E2E5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E2E5),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Services',
                style: TextStyle(
                  color: Color(0xFF313235),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: Color(0xFFDE2057),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem('Nails', Icons.spa),
              _buildServiceItem('Eye', Icons.visibility),
              _buildServiceItem('Facial', Icons.face),
              _buildServiceItem('Hair Cut', Icons.content_cut),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFF25278), size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMostMonthly() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Most Monthly',
                style: TextStyle(
                  color: Color(0xFF313235),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: Color(0xFFDE2057),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              _buildProductCard(
                'Hot Style A.01',
                'Honey Salon',
                '6,4',
                '7,2',
                "https://images.unsplash.com/photo-1632922267756-9b71242b1592?w=500&q=80",
              ),
              const SizedBox(width: 12),
              _buildProductCard(
                'Nail Polish',
                'Honey Salon',
                '6,4',
                '7,2',
                "https://images.unsplash.com/photo-1519014816548-bf5fe059e98b?w=500&q=80",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(
    String title,
    String salon,
    String price,
    String oldPrice,
    String imgUrl,
  ) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imgUrl,
                  width: 152,
                  height: 152,
                  fit: BoxFit.cover,
                ),
              ),
              const Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 14,
                  child: Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                salon,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                '1,9k',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '\$$price',
                style: const TextStyle(
                  color: Color(0xFFF25278),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$$oldPrice',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalonsNearYou() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Salons Near You',
                style: TextStyle(
                  color: Color(0xFF313235),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: Color(0xFFDE2057),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Salon Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E2E5)),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    "https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&q=80",
                    height: 166,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Honey Salon - State',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.bookmark_border, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text('5.0/5.0 (255)', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Salon’s detailed address goes here',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
