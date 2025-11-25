import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm Firestore
import 'package:intl/intl.dart'; // Thêm intl để định dạng ngày

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isSaving = false; // 1. Thêm biến trạng thái để xử lý loading

  // Màu sắc từ code mẫu
  final Color bgScreen = const Color(0xFFF5F5F5);
  final Color bgInput = const Color(0xFFEEF0F1); // Màu nền ô input đặc trưng
  final Color primaryPink = const Color(0xFFF25278);
  final Color textDark = const Color(0xFF313235);
  final Color textGrey = const Color(0xFF9A9EA7);

  // 2. Thêm initState để lấy dữ liệu người dùng
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Sửa: Chuyển thành async để đợi Firestore
  void _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Lấy dữ liệu từ Auth
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';

      // Lấy dữ liệu bổ sung từ Firestore
      final docSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        _dobController.text = data['dob'] ?? '';
        setState(() => _selectedGender = data['gender'] ?? 'Male');
      }
    }
  }

  // 2. Hàm để lưu các thay đổi vào Firebase
  Future<void> _saveProfileChanges() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    setState(() {
      _isSaving = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user is currently signed in.");
      }

      final newName = _nameController.text.trim();

      // Chỉ cập nhật nếu tên hiển thị có thay đổi
      if (newName.isNotEmpty && newName != user.displayName) {
        await user.updateDisplayName(newName);
      }

      // Sửa: Lưu/Cập nhật dữ liệu vào Firestore
      // Dùng .set với merge:true sẽ tạo mới nếu chưa có, hoặc cập nhật nếu đã có
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'gender': _selectedGender,
        'dob': _dobController.text,
        // Bạn cũng có thể lưu các thông tin khác ở đây để truy vấn dễ hơn
        'email': user.email,
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(); // Quay về màn hình trước sau khi lưu
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Hàm để mở Date Picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Tùy chỉnh màu sắc cho DatePicker
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryPink)),
          child: child!,
        );
      },
    );
    if (picked != null)
      _dobController.text = DateFormat('MM/dd/yyyy').format(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgScreen,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 32),

            // Các trường nhập liệu
            _buildInputGroup(
              label: 'Full Name',
              child: _buildSimpleTextField(_nameController),
            ),
            const SizedBox(height: 20),

            _buildInputGroup(
              label: 'Email',
              child: _buildSimpleTextField(
                _emailController,
                prefixIcon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 20),

            _buildInputGroup(label: 'Phone Number', child: _buildPhoneField()),
            const SizedBox(height: 20),

            _buildInputGroup(label: 'Gender', child: _buildGenderDropdown()),
            const SizedBox(height: 20),

            _buildInputGroup(
              label: 'Birthdate',
              child: _buildSimpleTextField(
                _dobController,
                suffixIcon: Icons.calendar_today_outlined,
                isReadOnly: true,
                onTap: _selectDate, // Sửa: Gọi hàm _selectDate
              ),
            ),

            const SizedBox(height: 40),
            // Khoảng trống dưới cùng để không bị che bởi BottomNav nếu cần
          ],
        ),
      ),
      // Giữ BottomNavigationBar để đồng bộ layout
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // 1. AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgScreen,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textDark),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'My Profile',
        style: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
      actions: [
        // 3. Thay thế icon "..." bằng nút "Save"
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextButton(
            onPressed: _isSaving ? null : _saveProfileChanges,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      // color: primaryPink,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: primaryPink,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // 2. Avatar
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 117, // Kích thước từ code mẫu
            height: 117,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36, // Tăng kích thước chút cho dễ bấm
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryPink,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(
                  10,
                ), // Bo góc vuông nhẹ theo hình ảnh
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Input Group Helper (Label + Field)
  Widget _buildInputGroup({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // 4. Simple TextField (Dùng cho Name, Email, Birthdate)
  Widget _buildSimpleTextField(
    TextEditingController controller, {
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool isReadOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgInput, // Màu #EEF0F1
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: onTap,
        style: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600, // Chữ đậm như trong ảnh
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: textDark)
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: textDark)
              : null,
        ),
      ),
    );
  }

  // 5. Phone Field (Có cờ)
  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Icon Cờ Mỹ giả định
          Image.network(
            'https://flagcdn.com/w40/us.png',
            width: 24,
            height: 16,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.flag),
          ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, color: textDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              style: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  // 6. Gender Dropdown
  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: bgInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          icon: Icon(Icons.keyboard_arrow_down, color: textDark),
          isExpanded: true,
          dropdownColor: bgInput,
          style: TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
          items: <String>['Male', 'Female', 'Other']
              .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              })
              .toList(),
        ),
      ),
    );
  }

  // 7. Bottom Nav (Để hiển thị giống ảnh mẫu)
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 4, // Profile Tab
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryPink,
        unselectedItemColor: const Color(0xFF8F929C),
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: 'Collection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            label: 'Discover',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
