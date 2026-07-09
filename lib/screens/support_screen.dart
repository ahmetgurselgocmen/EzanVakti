import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/dynamic_background.dart';
import '../theme/app_colors.dart';
import '../main.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  bool _isSending = false;

  Future<void> _sendEmail() async {
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (email.isEmpty || subject.isEmpty || message.isEmpty) {
      _showAnimatedDialog(
        isSuccess: false,
        title: appSettings.l10n.t('error'),
        message: appSettings.l10n.t('supportEmptyError'),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // TODO: Formspree veya kendi sunucu API adresinizi buraya girin.
      // Örnek: https://api.formspree.io/f/x...
      final Uri apiEndpoint = Uri.parse('https://api.formspree.io/f/PLACEHOLDER_ID');
      
      /* Gerçek API isteği (Şu an placeholder ID olduğu için kapalı, test için 2 saniye bekliyoruz)
      final response = await http.post(
        apiEndpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'subject': subject,
          'message': message,
        }),
      );
      */
      
      // Simülasyon (Gerçek API'yi bağladığınızda bu satırı silin ve üsttekini açın)
      await Future.delayed(const Duration(seconds: 2));
      final bool isSuccess = true; // response.statusCode == 200

      if (!mounted) return;

      setState(() {
        _isSending = false;
      });

      if (isSuccess) {
        _showAnimatedDialog(
          isSuccess: true,
          title: appSettings.l10n.t('success'),
          message: appSettings.l10n.t('supportSuccessMessage'),
          onOkPressed: () {
            _emailController.clear();
            _subjectController.clear();
            _messageController.clear();
          },
        );
      } else {
        _showAnimatedDialog(
          isSuccess: false,
          title: appSettings.l10n.t('error'),
          message: appSettings.languageCode == 'tr'
              ? 'Gönderim başarısız oldu. Lütfen tekrar deneyin.'
              : 'Failed to send. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      _showAnimatedDialog(
        isSuccess: false,
        title: appSettings.l10n.t('error'),
        message: appSettings.languageCode == 'tr'
            ? 'Bir bağlantı hatası oluştu.'
            : 'A connection error occurred.',
      );
    }
  }

  void _showAnimatedDialog({
    required bool isSuccess,
    required String title,
    required String message,
    VoidCallback? onOkPressed,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: AlertDialog(
            backgroundColor: AppColors.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                    color: isSuccess ? Colors.green : Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textColor.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onOkPressed != null) onOkPressed();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      appSettings.l10n.t('ok'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textColor;
    final cardColor = AppColors.cardColor;
    final borderColor = AppColors.borderColor;

    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        appSettings.l10n.t('support'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel(appSettings.l10n.t('supportEmail')),
                        _buildTextField(
                          _emailController,
                          TextInputType.emailAddress,
                          hintText: appSettings.l10n.t('supportEmailHint'),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel(appSettings.l10n.t('supportSubject')),
                        _buildTextField(
                          _subjectController,
                          TextInputType.text,
                          hintText: appSettings.l10n.t('supportSubjectHint'),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel(appSettings.l10n.t('supportMessage')),
                        _buildTextField(
                          _messageController,
                          TextInputType.multiline,
                          hintText: appSettings.l10n.t('supportMessageHint'),
                          maxLines: 6,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSending
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    appSettings.l10n.t('supportSend'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textColor.withValues(alpha: 0.8),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, TextInputType type, {String? hintText, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textColor.withValues(alpha: 0.3),
        ),
        filled: true,
        fillColor: AppColors.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
