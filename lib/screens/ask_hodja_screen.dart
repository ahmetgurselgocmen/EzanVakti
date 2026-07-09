import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../services/ad_service.dart';
import '../widgets/dynamic_background.dart';

class AskHodjaScreen extends StatefulWidget {
  const AskHodjaScreen({super.key});

  @override
  State<AskHodjaScreen> createState() => _AskHodjaScreenState();
}

class _AskHodjaScreenState extends State<AskHodjaScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appSettings.languageCode == 'tr'
                ? 'Lütfen bir soru yazınız.'
                : 'Please enter a question.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate network request
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _questionController.clear();
        });
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  appSettings.languageCode == 'tr' ? 'Başarılı' : 'Success',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              appSettings.languageCode == 'tr'
                  ? 'Sorunuz hocalarımıza iletilmek üzere başarıyla alınmıştır. En kısa sürede (varsa e-posta adresiniz üzerinden veya uygulama içerisinden) yanıtlanacaktır.'
                  : 'Your question has been successfully received by our scholars. It will be answered as soon as possible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  appSettings.languageCode == 'tr' ? 'Tamam' : 'OK',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTr = appSettings.languageCode == 'tr';
    final textColor = AppColors.textColor;
    final primaryColor = AppColors.primaryColor;

    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isTr ? 'Hocaya Soru Sor' : 'Ask a Question',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: textColor),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.question_answer_rounded,
                        color: primaryColor,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isTr
                            ? 'Dini konularda aklınıza takılan soruları alanında uzman hocalara sorabilirsiniz.'
                            : 'You can ask our expert scholars any questions you have regarding religious matters.',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
              
              // Email Field (Optional)
              Text(
                isTr ? 'E-Posta Adresiniz (İsteğe Bağlı)' : 'Your Email (Optional)',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: isTr ? 'Yanıt almak için e-posta girin...' : 'Enter email for reply...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                ),
              ),
              SizedBox(height: 24),
              
              // Question Field
              Text(
                isTr ? 'Sorunuz' : 'Your Question',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _questionController,
                maxLines: 6,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: isTr
                      ? 'Lütfen sorunuzu açık ve net bir şekilde ifade ediniz...'
                      : 'Please express your question clearly...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded),
                          SizedBox(width: 8),
                          Text(
                            isTr ? 'Soruyu Gönder' : 'Submit Question',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
              
              SizedBox(height: 24),
              Text(
                isTr 
                  ? '* Sorularınız uzman hocalarımız tarafından incelenip İslami kaynaklara dayanılarak yanıtlanmaktadır.'
                  : '* Your questions are reviewed and answered by expert scholars based on Islamic sources.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBannerAd(),
      ),
    );
  }
}
