import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_shadows.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer';
  late AnimationController _glowController;

  final List<String> _roles = ['customer', 'technician', 'advisor', 'manager'];

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
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
    _emailController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TechBackgroundPainter(_glowController),
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
                          _buildHeader(),
                          const SizedBox(height: AppSpacing.space32),
                          _buildFormPanel(isLoading),
                          const SizedBox(height: AppSpacing.space32),
                          _buildSubmitArea(isLoading),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'ACCOUNT REGISTRATION',
          style: AppTypography.headingLarge.copyWith(
            color: AppColors.textPrimary,
            letterSpacing: 4,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space8),
        Text(
          'Register access to your account',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormPanel(bool isLoading) {
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
            hint: 'Choose a profile username',
            icon: Icons.person_outline,
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Username required' : null,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.space16),
          _buildSleekInput(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'EMAIL ADDRESS',
            hint: 'user@wheelsdoc.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email required';
              if (!val.contains('@')) return 'Invalid email address';
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.space16),
          _buildSleekInput(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'PASSWORD',
            hint: '••••••••',
            icon: Icons.lock_outline,
            obscure: true,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Password required';
              if (val.trim().length < 6) return 'Minimum 6 characters';
              return null;
            },
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.space16),
          _buildRoleDropdown(isLoading),
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
    TextInputType keyboardType = TextInputType.text,
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
                      keyboardType: keyboardType,
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

  Widget _buildRoleDropdown(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT ROLE',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.space8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            border: Border.all(color: AppColors.borderDefault, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              dropdownColor: AppColors.bgSurface,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role.toUpperCase()),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (String? newVal) {
                      if (newVal != null) {
                        setState(() {
                          _selectedRole = newVal;
                        });
                      }
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitArea(bool isLoading) {
    return AnimatedBuilder(
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
            clipper: _AngledClipper(),
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
                        'REGISTER ACCOUNT',
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
    );
  }
}

class _AngledClipper extends CustomClipper<Path> {
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

class _TechBackgroundPainter extends CustomPainter {
  final Animation<double> glow;
  _TechBackgroundPainter(this.glow) : super(repaint: glow);

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

    final center = Offset(20, size.height - 60);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = AppColors.primary.withOpacity(0.05 + 0.08 * glow.value);

    canvas.drawCircle(center, 140, arcPaint);
    canvas.drawCircle(center, 160, arcPaint);

    final tickPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.04 + 0.06 * glow.value)
      ..strokeWidth = 2.0;

    for (var i = -90; i < 90; i += 15) {
      final rad = i * math.pi / 180;
      final start = Offset(
        center.dx + 140 * math.cos(rad),
        center.dy + 140 * math.sin(rad),
      );
      final end = Offset(
        center.dx + 155 * math.cos(rad),
        center.dy + 155 * math.sin(rad),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
