import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:applamdep/UI/Login/forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Trạng thái cho checkbox và ẩn/hiện mật khẩu
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  // Controllers cho các ô text
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Màu sắc từ thiết kế
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color primaryPink = Color(0xFFF25278); // Màu "Forgot Password"
  static const Color buttonPink = Color(
    0xFFC72C41,
  ); // Ước lượng màu nút "Sign in"
  static const Color textPrimary = Color(0xFF313235);
  static const Color textSecondary = Color(0xFF7B7D87);
  static const Color textHint = Color(0xFF9A9EA7);
  static const Color textFieldBg = Color(
    0xFFF5F5F5,
  ); // Nền ô input giống nền chính
  static const Color textFieldBorder = Color(0xFFE0E2E5); // Viền ô input
  static const Color separatorText = Color(0xFF616161);
  static const Color separatorLine = Color(0xFFEEEEEE);

  @override
  void dispose() {
    // Giải phóng controllers khi widget bị huỷ
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC TỪ FILE THỨ HAI CỦA BẠN ĐÃ ĐƯỢC THÊM VÀO ĐÂY ---
  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    // (Bạn có thể thêm logic hiển thị loading ở đây)

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // TODO: Điều hướng đến màn hình chính (HomeScreen) sau khi đăng nhập thành công
      // if (mounted) {
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => const HomeScreen()),
      //   );
      // }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Header
                      const Text(
                        'Welcome Back! 👋',
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
                        'Your next nail appointment is just a tap away',
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
                      const SizedBox(height: 20),

                      // 3. Remember me & Forgot Password
                      _buildRememberForgotRow(),
                      const SizedBox(height: 28),

                      // 4. "or" Separator
                      _buildOrSeparator(),
                      const SizedBox(height: 28),

                      // 5. Social Logins
                      _buildSocialButton(
                        text: 'Continue with Google',
                        iconPath: 'assets/images/google_icon.png',
                        onPressed: () {
                          // TODO: Xử lý đăng nhập Google
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSocialButton(
                        text: 'Continue with Apple',
                        iconPath: 'assets/images/apple_icon.png',
                        onPressed: () {
                          // TODO: Xử lý đăng nhập Apple
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSocialButton(
                        text: 'Continue with Facebook',
                        iconPath: 'assets/images/facebook_icon.png',
                        onPressed: () {
                          // TODO: Xử lý đăng nhập Facebook
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // 6. Nút Sign in (đặt cố định ở dưới)
            _buildSignInButton(),
          ],
        ),
      ),
    );
  }

  // Widget cho các trường nhập liệu
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
            fillColor: Colors.white, // Nền trắng
            hintText: hintText,
            hintStyle: const TextStyle(
              color: textHint,
              fontSize: 16,
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
            // Viền
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: textFieldBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: textFieldBorder, width: 1),
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

  // Widget cho "Remember me" và "Forgot Password?"
  Widget _buildRememberForgotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (bool? value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: const BorderSide(color: textHint, width: 2),
            ),
            const Text(
              'Remember me',
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // Forgot Password
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const ForgotPasswordScreen();
                },
              ),
            );
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: primaryPink,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
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

  // Widget cho các nút đăng nhập xã hội
  Widget _buildSocialButton({
    required String text,
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Nền trắng
        foregroundColor: textPrimary,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: const BorderSide(color: textFieldBorder, width: 1),
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

  // Nút "Sign in" ở cuối trang
  Widget _buildSignInButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Đệm cho an toàn
      decoration: const BoxDecoration(
        color: backgroundColor, // Hoặc Colors.white nếu muốn nổi bật
      ),
      child: ElevatedButton(
        // --- KẾT NỐI VỚI HÀM _signIn ---
        onPressed: _signIn,
        // --- KẾT THÚC THAY ĐỔI ---
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonPink,
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: const Text(
          'Sign in',
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
