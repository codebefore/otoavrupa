import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/otp_input_field.dart';
import '../../providers/auth_provider.dart';
import 'vehicles_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _otpSent = false;
  bool _canResendOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _phoneController.text.trim();

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOtp(phoneNumber);

    if (!mounted) return;

    if (authProvider.status == AuthStatus.unauthenticated) {
      setState(() {
        _otpSent = true;
      });

      // Enable resend after 60 seconds
      Future.delayed(AppConstants.otpResendDelay, () {
        if (mounted) {
          setState(() {
            _canResendOtp = true;
          });
        }
      });
    } else if (authProvider.status == AuthStatus.error) {
      _showErrorSnackBar(authProvider.errorMessage ?? AppStrings.error);
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    final authProvider = context.read<AuthProvider>();
    await authProvider.verifyOtp(phoneNumber, otp);

    if (!mounted) return;

    if (authProvider.status == AuthStatus.authenticated) {
      // Navigate to vehicles screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VehiclesScreen(),
        ),
      );
    } else if (authProvider.status == AuthStatus.error) {
      _showErrorSnackBar(authProvider.errorMessage ?? AppStrings.invalidOtp);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),

                    // Logo and Title
                    _buildHeader(),

                    const SizedBox(height: 48),

                    // Phone Number Input
                    if (!_otpSent) ...[
                      _buildPhoneInput(),
                      const SizedBox(height: 24),
                      _buildSendOtpButton(),
                    ] else ...[
                      // OTP Input
                      _buildOtpInput(),
                      const SizedBox(height: 24),
                      _buildVerifyOtpButton(),
                      const SizedBox(height: 16),
                      _buildResendOtpButton(),
                    ],
                  ],
                ),
              ),
            ),
            // Loading overlay
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.status == AuthStatus.loading) {
                  return Container(
                    color: Colors.white.withOpacity(0.8),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        SvgPicture.asset(
          'assets/images/logo.svg',
          width: 200,
          height: 200,
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      enabled: !_otpSent,
      decoration: InputDecoration(
        labelText: AppStrings.phoneNumber,
        hintText: '+90 555 123 4567',
        prefixIcon: const Icon(Icons.phone),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.invalidPhone;
        }
        if (value.length < 10) {
          return AppStrings.invalidPhone;
        }
        return null;
      },
      onFieldSubmitted: (_) => _sendOtp(),
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        // Display phone number
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone, color: AppTheme.gray600),
              const SizedBox(width: 12),
              Text(
                _phoneController.text,
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // OTP Input Field
        OtpInputField(
          controller: _otpController,
          length: AppConstants.otpLength,
          onCompleted: (otp) => _verifyOtp(),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return ElevatedButton(
      onPressed: _sendOtp,
      child: Text(AppStrings.login),
    );
  }

  Widget _buildVerifyOtpButton() {
    return ElevatedButton(
      onPressed: _verifyOtp,
      child: Text(AppStrings.confirm),
    );
  }

  Widget _buildResendOtpButton() {
    return TextButton(
      onPressed: _canResendOtp
          ? () {
              setState(() {
                _otpSent = false;
                _canResendOtp = false;
                _otpController.clear();
              });
            }
          : null,
      child: Text(
        AppStrings.resendOtp,
        style: TextStyle(
          color: _canResendOtp ? AppTheme.primaryColor : AppTheme.gray400,
        ),
      ),
    );
  }
}
