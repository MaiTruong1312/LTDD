// File: lib/UI/Login/otp_verification_screen.dart (File cũ của bạn đã đổi tên)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:applamdep/UI/Login/reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  // THÊM DÒNG NÀY: Để nhận email từ màn hình trước
  final String email;

  // THÊM DÒNG NÀY: Cập nhật constructor
  const OtpVerificationScreen({super.key, required this.email});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // ... (giữ nguyên các biến của bạn)
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  String _otp = "";

  Timer? _timer;
  int _countdown = 56;
  bool _canResend = false;
  bool _isLoading = false;

  // ... (giữ nguyên các màu sắc)
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF313235);
  static const Color textSecondary = Color(0xFF7B7D87);
  static const Color primaryPink = Color(0xFFF25278);
  static const Color countdownColor = Color(0xFFF25278);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _otpController.addListener(_onOtpChanged);
    startTimer();
  }

  // ... (giữ nguyên dispose, _onOtpChanged, startTimer)

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onOtpChanged() {
    setState(() {
      _otp = _otpController.text;
    });
    if (_otp.length == 4 && !_isLoading) {
      _verifyOtp(_otp);
    }
  }

  void startTimer() {
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  // Gửi lại code
  void _resendCode() {
    if (_canResend) {
      // Bây giờ bạn có thể dùng email ở đây
      print('Gửi lại code cho email: ${widget.email}');
      // TODO: Thêm logic gửi lại code ở đây

      setState(() {
        _countdown = 56;
      });
      startTimer();
    }
  }

  // Xác thực OTP
  void _verifyOtp(String otp) async {
    _focusNode.unfocus();
    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();
    await Future.delayed(const Duration(seconds: 2));

    // Bây giờ bạn có thể dùng email và otp để xác thực
    print('Xác thực OTP: $otp cho email: ${widget.email}');
    // TODO: Thêm logic xác thực OTP với Firebase hoặc API ở đây

    if (mounted) {
      Navigator.of(context).pop(); // Tắt dialog
    }

    // SỬA DÒNG NÀY: Truyền email sang màn hình ResetPasswordScreen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email),
        ),
      );
    }
  }

  // ... (giữ nguyên _showLoadingDialog, build, _buildOtpInput, _buildOtpBox, _buildResendText)
  // ... (Không cần thay đổi các hàm build UI)
  // ... (Dán phần còn lại của file bạn vào đây)
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // 1. Header
                      const Text(
                        'Enter OTP Code 🔐',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 28,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          height: 1.21,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 2. Subtitle
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  "Please check your email inbox for a message from Pionails. Enter the one-time verification code sent to ",
                            ),
                            TextSpan(
                              text: widget.email, // Hiển thị email người dùng
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3. Ô nhập OTP (và TextField ẩn)
                      _buildOtpInput(),

                      const SizedBox(height: 32),
                      // 4. Đếm ngược
                      _buildResendText(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget chứa 4 ô OTP và TextField ẩn
  Widget _buildOtpInput() {
    return GestureDetector(
      onTap: () {
        // Mở bàn phím khi bấm vào các ô
        _focusNode.requestFocus();
      },
      child: Stack(
        children: [
          // 4 ô vuông hiển thị
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOtpBox(0),
              _buildOtpBox(1),
              _buildOtpBox(2),
              _buildOtpBox(3),
            ],
          ),
          // TextField ẩn để xử lý nhập liệu
          SizedBox(
            width: double.infinity,
            height: 60, // Chiều cao bằng ô OTP
            child: TextField(
              controller: _otpController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // Ẩn text và con trỏ
              style: const TextStyle(
                color: Colors.transparent, // Ẩn văn bản
                fontSize: 0, // Ẩn con trỏ
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '', // Ẩn bộ đếm ký tự
                filled: true,
                fillColor: Colors.transparent,
              ),
              cursorColor: Colors.transparent,
              enableSuggestions: false,
              autocorrect: false,
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho từng ô OTP
  Widget _buildOtpBox(int index) {
    // Ký tự sẽ hiển thị
    final char = index < _otp.length ? _otp[index] : '';
    // Ô hiện tại đang được focus (sẽ có viền hồng)
    final hasFocus = index == _otp.length;
    final textFieldBg = Color(0xFFEEF0F1);
    return Container(
      width: 75, // Kích thước ô
      height: 75,
      decoration: BoxDecoration(
        color: textFieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus ? primaryPink : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 32, // Cỡ chữ lớn cho số
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  // Widget cho văn bản đếm ngược và nút "Resend"
  Widget _buildResendText() {
    return Center(
      child: _canResend
          ? TextButton(
              onPressed: _resendCode,
              child: const Text(
                'Resend code',
                style: TextStyle(
                  color: primaryPink,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'You can resend the code in '),
                  TextSpan(
                    text: '$_countdown seconds',
                    style: const TextStyle(
                      color: countdownColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
