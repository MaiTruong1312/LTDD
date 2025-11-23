// File: lib/UI/Login/reset_password_screen.dart

import 'package:flutter/material.dart';

// SỬA 1: Đổi tên class cho đúng với tên file và logic import
class ResetPasswordScreen extends StatefulWidget {
  // SỬA 2: Thêm biến để nhận email từ màn hình trước
  final String email;

  // SỬA 3: Cập nhật constructor để yêu cầu email
  const ResetPasswordScreen({super.key, required this.email});

  @override
  // SỬA 4: Đổi tên State cho khớp với tên class mới
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

// SỬA 5: Đổi tên State cho khớp với tên class mới
class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Key cho Form
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Trạng thái
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Màu sắc
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF313235);
  static const Color textHint = Color(0xFF9A9EA7);
  static const Color textFieldBg = Color(0xFFEEF0F1);
  static const Color buttonPink = Color(0xFFBB1549);
  static const Color primaryPink = Color(0xFFF25278);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Hiển thị dialog loading
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: primaryPink),
                const SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hàm xử lý lưu mật khẩu
  void _savePassword() async {
    // 1. Ẩn bàn phím
    FocusScope.of(context).unfocus();

    // 2. Kiểm tra Form
    if (!_formKey.currentState!.validate()) {
      return; // Dừng lại nếu form không hợp lệ
    }

    // 3. Kiểm tra mật khẩu có trùng khớp không
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 4. Bắt đầu loading
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog();

    // 5. Mô phỏng gọi API
    await Future.delayed(const Duration(seconds: 2));

    // In ra email để kiểm tra
    print('Đang cập nhật mật khẩu cho email: ${widget.email}');
    print('Mật khẩu mới: ${_passwordController.text}');

    // TODO: Thêm logic cập nhật mật khẩu Firebase của bạn ở đây
    // Bạn sẽ cần widget.email và _passwordController.text

    // 6. Tắt dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    // 7. Điều hướng đến màn hình thành công
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ResetSuccessScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        // Dùng Form để validation
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nội dung chính
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // 1. Header
                        const Text(
                          'Secure Your Account 🔐',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 28,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.21,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Hiển thị email để người dùng biết họ đang đổi MK cho ai
                        Text(
                          'Creating a new password for ${widget.email}',
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 2. Ô Password
                        _buildPasswordField(
                          label: 'Password',
                          controller: _passwordController,
                          isVisible: _isPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // 3. Ô Confirm Password
                        _buildPasswordField(
                          label: 'Confirming New Password',
                          controller: _confirmPasswordController,
                          isVisible: _isConfirmPasswordVisible,
                          onToggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Nút bấm cố định ở dưới
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget chung cho các ô mật khẩu
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            filled: true,
            fillColor: textFieldBg,
            hintText: 'Password',
            hintStyle: const TextStyle(
              color: textHint,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.lock_outline, color: textHint),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: textHint,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryPink, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Widget cho nút "Save New Password"
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      color: backgroundColor,
      child: ElevatedButton(
        // Nút sẽ bị vô hiệu hóa khi _isLoading = true
        onPressed: _isLoading ? null : _savePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonPink,
          disabledBackgroundColor: buttonPink.withOpacity(
            0.5,
          ), // Màu khi bị vô hiệu hóa
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: const Text(
          'Save New Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

// --- MÀN HÌNH THỨ HAI: THÀNH CÔNG ---

class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({super.key});

  // Màu sắc (có thể định nghĩa lại hoặc import từ file constants)
  static const Color textPrimary = Color(0xFF313235);
  static const Color textSecondary = Color(0xFF7B7D87);
  static const Color buttonPink = Color(0xFFBB1549);
  static const Color buttonLightPink = Color(0xFFF25278); // Nút Go to Homepage
  static const Color backgroundColor = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Căn giữa nội dung và đẩy nút xuống dưới
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: buttonPink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_android_rounded, // Icon điện thoại
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Text
                    const Text(
                      "You're All Set!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 28,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your password has been successfully changed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút Go to Homepage
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 8.0), // Đệm dưới
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Thay 'YourHomeScreen()' bằng trang chủ của bạn
                    // Navigator.of(context).pushAndRemoveUntil(
                    //   MaterialPageRoute(
                    //     builder: (context) => const YourHomeScreen(),
                    //   ),
                    //   (Route<dynamic> route) => false, // Xóa hết stack
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonLightPink, // Màu hồng nhạt
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    'Go to Homepage',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
