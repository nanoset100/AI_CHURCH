import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_canaan_church/theme/app_theme.dart';
import 'package:ai_canaan_church/services/auth_service.dart';
import 'package:ai_canaan_church/screens/auth/login_screen.dart';

/// 회원가입 화면
/// ReflectOS 패턴: 가입 성공 시 로그인 화면으로 리다이렉트
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim().isEmpty 
          ? null 
          : _nameController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result.success) {
      // ReflectOS 패턴: 회원가입 성공 시 스낵바 표시 후 로그인 화면으로 리다이렉트
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '가입을 축하합니다! 이제 로그인해주세요.',
            style: GoogleFonts.notoSansKr(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // 로그인 화면으로 리다이렉트 (자동 로그인 절대 금지)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      setState(() {
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notoSansKr = GoogleFonts.notoSansKr();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.textColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 회원가입 제목
                Text(
                  '회원가입',
                  style: notoSansKr.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI 가나안교회에 오신 것을 환영합니다',
                  style: notoSansKr.copyWith(
                    fontSize: 14,
                    color: AppTheme.textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 32),

                // 에러 메시지
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: notoSansKr.copyWith(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 이름 입력
                TextFormField(
                  controller: _nameController,
                  style: notoSansKr,
                  decoration: InputDecoration(
                    labelText: '이름 (선택)',
                    labelStyle: notoSansKr,
                    hintText: '기도제목에서 불릴 이름을 적어주세요',
                    hintStyle: notoSansKr,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: notoSansKr,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: notoSansKr,
                    hintText: 'example@email.com',
                    hintStyle: notoSansKr,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이메일을 입력해주세요.';
                    }
                    if (!value.contains('@')) {
                      return '유효한 이메일 형식이 아닙니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  style: notoSansKr,
                  decoration: InputDecoration(
                    labelText: '비밀번호 (6자 이상)',
                    labelStyle: notoSansKr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호 확인 입력
                TextFormField(
                  controller: _passwordConfirmController,
                  obscureText: !_passwordConfirmVisible,
                  style: notoSansKr,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    labelStyle: notoSansKr,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordConfirmVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordConfirmVisible = !_passwordConfirmVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '비밀번호 확인을 입력해주세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // 회원가입 버튼
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            '회원가입',
                            style: notoSansKr.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // 로그인 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이미 계정이 있으신가요? ',
                      style: notoSansKr.copyWith(
                        fontSize: 14,
                        color: AppTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '로그인',
                        style: notoSansKr.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
