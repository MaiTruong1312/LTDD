import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Trạng thái cho checkbox và ẩn/hiện mật khẩu
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;

  // Controllers cho các ô text
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();

  // Màu sắc từ thiết kế
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color primaryPink = Color(0xFFF25278);
  static const Color buttonPink = Color(0xFFBB1549); // Màu nút Sign up
  static const Color textPrimary = Color(0xFF313235);
  static const Color textSecondary = Color(0xFF7B7D87);
  static const Color textHint = Color(0xFF9A9EA7);
  static const Color textFieldBg = Color(0xFFEEF0F1);
  static const Color separatorText = Color(0xFF616161);
  static const Color separatorLine = Color(0xFFEEEEEE);
  static const Color socialButtonBorder = Color(0xFFE0E2E5);

  @override
  void dispose() {
    // Giải phóng controllers khi widget bị huỷ
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  // --- LOGIC TỪ FILE THỨ HAI CỦA BẠN ĐÃ ĐƯỢC THÊM VÀO ĐÂY ---
  void _signUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms & Conditions'),
        ),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    // Hiển thị vòng quay loading
    // (Bạn có thể thêm logic hiển thị loading ở đây)

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Nếu thành công, quay lại màn hình trước đó (có thể là màn hình đăng nhập)
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful! Please sign in.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi từ Firebase
      String message = 'An error occurred. Please try again.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      // Xử lý các lỗi khác
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }

    // (Và logic ẩn loading ở đây)
  }
  // --- KẾT THÚC LOGIC TỪ FILE THỨ HAI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar với nút Back
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header
                const Text(
                  'Join Pionails Today 👤',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.21,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Confidence starts at your fingertips',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
                const SizedBox(height: 28),

                // 2. Form Fields
                _buildTextFieldGroup(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: 24),
                _buildTextFieldGroup(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                _buildTextFieldGroup(
                  label: 'Referral Code (optional)',
                  controller: _referralController,
                  hintText: 'Referral Code',
                ),
                const SizedBox(height: 24),

                // 3. Terms & Conditions
                _buildTermsRow(),
                const SizedBox(height: 24),

                // 4. Link "Sign in"
                _buildSignInLink(),
                const SizedBox(height: 24),

                // 5. "or" Separator
                _buildOrSeparator(),
                const SizedBox(height: 24),

                // 6. Google Sign in
                _buildSocialButton(
                  text: 'Continue with Google',
                  iconPath: 'assets/icons/google_icon.png',
                  onPressed: () {
                    // TODO: Xử lý đăng nhập Google
                  },
                ),
                const SizedBox(height: 20),

                // 7. Nút Sign up
                ElevatedButton(
                  // --- KẾT NỐI VỚI HÀM _signUp ---
                  onPressed: _signUp,
                  // --- KẾT THÚC THAY ĐỔI ---
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonPink,
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget cho các trường nhập liệu (Email, Password, Referral)
  Widget _buildTextFieldGroup({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool isPassword = false,
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
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: textFieldBg,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: textHint,
              fontSize: 18, // 18 theo code gợi ý, 16 theo hình ảnh
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: icon != null ? Icon(icon, color: textHint) : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: textHint,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Viền đã trùng màu nền
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryPink, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // Widget cho hàng "I agree to..."
  Widget _buildTermsRow() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (bool? value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: primaryPink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          side: const BorderSide(color: primaryPink, width: 3),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'I agree to Loyalify ',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: const TextStyle(
                    color: primaryPink,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Mở trang Terms & Conditions
                    },
                ),
                const TextSpan(
                  text: '.',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget cho "Already have an account? Sign in"
  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.25,
          ),
        ),
        GestureDetector(
          onTap: () {
            // Điều hướng về trang Sign In
            Navigator.of(context).pop(); // Quay lại màn hình trước đó
          },
          child: const Text(
            'Sign in',
            style: TextStyle(
              color: primaryPink,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.50,
            ),
          ),
        ),
      ],
    );
  }

  // Widget cho dải phân cách "or"
  Widget _buildOrSeparator() {
    return Row(
      children: const [
        Expanded(child: Divider(color: separatorLine, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'or',
            style: TextStyle(
              color: separatorText,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
        ),
        Expanded(child: Divider(color: separatorLine, thickness: 1)),
      ],
    );
  }

  // Widget cho nút "Continue with Google"
  Widget _buildSocialButton({
    required String text,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Khác với mainlogin (F5F5F5)
        foregroundColor: textPrimary,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: const BorderSide(color: socialButtonBorder, width: 1),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.login, size: 24);
            },
          ),
          const SizedBox(width: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
