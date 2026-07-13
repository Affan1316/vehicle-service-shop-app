import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_shadows.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _glowController;
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginRequested(
              _usernameController.text.trim(),
              _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashboardBackgroundPainter(_glowController),
            ),
          ),
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.dangerText,
                  ),
                );
              } else if (state is Authenticated) {
                context.go('/dashboard');
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrandHeader(),
                          const SizedBox(height: AppSpacing.space48),
                          _buildInputPanel(isLoading),
                          const SizedBox(height: AppSpacing.space32),
                          _buildActionArea(isLoading),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2 + 0.3 * _glowController.value),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1 * _glowController.value),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
            const Icon(
              LucideIcons.gauge,
              size: 44,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space16),
        Text(
          'WHEELS DOC',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 6,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 2,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.space8),
            Text(
              'VEHICLE SERVICE HUB',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            Container(
              width: 12,
              height: 2,
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputPanel(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withOpacity(0.7),
        border: Border.all(color: AppColors.borderDefault, width: 1.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: AppShadows.shadow1,
      ),
      padding: const EdgeInsets.all(AppSpacing.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSleekInput(
            controller: _usernameController,
            focusNode: _usernameFocus,
            label: 'USERNAME',
            hint: 'Enter your username',
            icon: LucideIcons.user,
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Username required' : null,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.space24),
          _buildSleekInput(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'PASSWORD',
            hint: '••••••••',
            icon: LucideIcons.lock,
            obscure: true,
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Password required' : null,
            enabled: !isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSleekInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    bool enabled = true,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isFocused ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.space8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                border: Border.all(
                  color: isFocused ? AppColors.borderActive : AppColors.borderDefault,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isFocused ? AppColors.primary : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Icon(
                    icon,
                    color: isFocused ? AppColors.primary : AppColors.textDisabled,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.space12),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      obscureText: obscure,
                      enabled: enabled,
                      validator: validator,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.space12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionArea(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2 * _glowController.value),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: ClipPath(
                clipper: _ButtonAngledClipper(),
                child: Container(
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFF4500)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.textPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'SIGN IN',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.space24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Need an account?",
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: Text(
                'Register here',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ButtonAngledClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(12, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width - 12, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _DashboardBackgroundPainter extends CustomPainter {
  final Animation<double> glow;
  _DashboardBackgroundPainter(this.glow) : super(repaint: glow);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderDefault.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSpacing = 40.0;
    for (var x = 0.0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final speedoCenter = Offset(size.width - 20, 60);
    final speedoPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.primary.withOpacity(0.05 + 0.08 * glow.value);
    
    canvas.drawCircle(speedoCenter, 140, speedoPaint);
    canvas.drawCircle(speedoCenter, 160, speedoPaint);

    final tickPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.04 + 0.06 * glow.value)
      ..strokeWidth = 2.0;

    for (var i = 90; i < 270; i += 15) {
      final rad = i * math.pi / 180;
      final start = Offset(
        speedoCenter.dx + 140 * math.cos(rad),
        speedoCenter.dy + 140 * math.sin(rad),
      );
      final end = Offset(
        speedoCenter.dx + 155 * math.cos(rad),
        speedoCenter.dy + 155 * math.sin(rad),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
