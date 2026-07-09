import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../widgets/dynamic_background.dart';

class ProMembershipScreen extends StatefulWidget {
  const ProMembershipScreen({super.key});

  @override
  State<ProMembershipScreen> createState() => _ProMembershipScreenState();
}

class _ProMembershipScreenState extends State<ProMembershipScreen> {
  bool _isProcessing = false;

  void _simulatePurchase() {
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () async {
      await appSettings.setPro(true);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appSettings.languageCode == 'tr'
                  ? 'Tebrikler! Artık PRO üyesiniz.'
                  : 'Congratulations! You are now a PRO member.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isTr = appSettings.languageCode == 'tr';
    final textColor = AppColors.textColor;
    const goldenColor = Color(0xFFD4AF37);
    final isPro = appSettings.isPro;

    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isTr ? 'PRO Üyelik' : 'PRO Membership',
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
              // Header Icon
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldenColor.withValues(alpha: 0.1),
                  border: Border.all(color: goldenColor, width: 2),
                ),
                child: Icon(
                  isPro ? Icons.workspace_premium : Icons.stars_rounded,
                  size: 80,
                  color: goldenColor,
                ),
              ),
              SizedBox(height: 24),
              Text(
                isTr ? 'Ayrıcalıkları Keşfedin' : 'Discover the Privileges',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                isTr 
                  ? 'Ezan Vakti uygulamasını sınırları olmadan, en verimli şekilde kullanın.'
                  : 'Use the Ezan Vakti app without limits and most efficiently.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 40),

              // Feature 1: No Ads
              _buildFeatureRow(
                icon: Icons.block,
                title: isTr ? 'Reklamsız Deneyim' : 'Ad-Free Experience',
                desc: isTr
                    ? 'Uygulama içindeki tüm afiş ve tam ekran reklamları sonsuza dek kaldırın.'
                    : 'Remove all banner and full-screen ads inside the app forever.',
                isActive: isPro,
              ),
              SizedBox(height: 24),

              // Feature 2: Ask Hodja
              _buildFeatureRow(
                icon: Icons.question_answer_rounded,
                title: isTr ? 'Hocaya Soru Sor' : 'Ask a Question',
                desc: isTr
                    ? 'Dini konulardaki sorularınızı doğrudan Diyanet uzmanlarına iletin.'
                    : 'Send your questions regarding religious matters directly to experts.',
                isActive: isPro,
              ),
              
              SizedBox(height: 48),

              // Purchase Button
              if (!isPro)
                ElevatedButton(
                  onPressed: _isProcessing ? null : _simulatePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldenColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isTr ? 'Premium\'a Geç (Simülasyon)' : 'Upgrade to Premium (Sim)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        isTr ? 'Aktif PRO Üyesisiniz' : 'You are an Active PRO Member',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isActive,
    Widget? action,
  }) {
    final textColor = AppColors.textColor;
    const goldenColor = Color(0xFFD4AF37);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? goldenColor : Colors.white,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? goldenColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? goldenColor : Colors.grey,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (action != null) ...[
                  SizedBox(height: 12),
                  action,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
