import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';

// Import your color constants
import '../../utils/colors.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    return Scaffold(
      appBar: AppBar(
        title: Text('About',),

        iconTheme: IconThemeData(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Section (newly added)
              Text(
                'Welcome to Global 8®',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,

                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Welcome to Global 8®, a vibrant skate community for avid rollers, new skaters, and those who love life on wheels. Whether you\'re into roller skating, skateboarding or anything else that rolls with that powerful 8 vibration (think 808\'s in music), you\'re in the right place.\n\n'
                    'At Global 8®, we celebrate the worldwide art of skate! In bringing our vision to life, our goal was to curate a network of digital and physical spaces for skaters to connect. Browse event highlights, download your solo video footage, or catch up on the latest news and updates from the skate world, all in one spot. Skating is freeing and fun, and we want everyone—new and experienced alike—to feel the excitement and joy that it brings. Quad, ice, inline, skateboard...you name it...we welcome it!\n\n'
                    'We believe in the power of SK8 to bring people together. Every glide, every spin, every vibe tells a story. Join us as we support and grow this incredible community. Global 8®—where the rhythm of skating brings us all together. Let’s roll!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Terms & Conditions ExpansionTile
              ExpansionTile(
                title: Text(
                  'Terms & Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '''
TERMS AND CONDITIONS

Effective Date: 01/13/2025

Welcome to Global 8! These Terms and Conditions ("Terms") govern your use of the Global 8 application ("App"), including participation in posting on the feeds, stories. By using the App, you agree to these Terms.

1. **Acceptance of Terms**
   - By accessing or using the App, you confirm that you have read, understood, and agree to be bound by these Terms. If you do not agree, please do not use the App.

2. **User Accounts**
   - You must be at least 13 years old to use the App.
   - You are responsible for maintaining the security of your account credentials.
   - The App may terminate or suspend your account if you violate these Terms.

3. **Club Membership and Posting**
   - The App reserves the right to remove content that is inappropriate, offensive, or violates these Terms.

4. **Events**
   - TBD.

5. **Prohibited Conduct**
   - You agree not to:
     - Post offensive, illegal, or misleading content.
     - Engage in harassment, discrimination, or abuse of any kind.
     - Use the App for unauthorized commercial activities.
     - Attempt to hack, disrupt, or interfere with App operations.

6. **Payments and Refunds**
   - The App is not liable for any disputes arising from payment transactions.

7. **Privacy and Data**
   - The App collects and processes user data per our Privacy Policy.
   - Users are responsible for protecting their own privacy while using the App.

8. **Termination**
   - The App reserves the right to terminate or suspend any user account that violates these Terms without prior notice.

9. **Changes to Terms**
   - The App may update these Terms at any time. Continued use of the App after changes signifies your acceptance of the revised Terms.

10. **Contact Information**
    - For questions regarding these Terms, please contact us at Global8together@gmail.com.
                      ''',
                      style: TextStyle(fontSize: 14, ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

              // Legal ExpansionTile
              ExpansionTile(
                title: Text(
                  'Legal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '''
LEGAL AGREEMENT

Effective Date: 01/13/2025

This Legal Agreement ("Agreement") is entered into by and between Squared ("Company", "we", "us", or "our") and the user ("User", "you", or "your") accessing or using the Global 8 ("App").

1. **Introduction**
   This Agreement governs your access to and use of our services, including the App, and any content, functionality, and services offered.

2. **Intellectual Property Rights**
   - All content, logos, and trademarks displayed within the App are owned by the Company or used under appropriate licenses.
   - Users may not copy, modify, distribute, or use our intellectual property without prior written consent.

3. **Liability Disclaimer**
   - The Company shall not be held responsible for any damages, losses, or injuries resulting from the use of the App.
   - The App is provided "as is" without warranties of any kind, express or implied.

4. **Indemnification**
   - You agree to indemnify and hold harmless the Company and its affiliates from any claims, damages, losses, or expenses arising from your use of the App.

5. **Dispute Resolution**
   - Any disputes arising from this Agreement shall be resolved through binding arbitration in accordance with [Applicable Jurisdiction] laws.

6. **Termination Clause**
   - We reserve the right to terminate this Agreement at any time if a User violates any terms outlined herein.

7. **Governing Law**
   - This Agreement shall be governed by the laws of [Your Country/State].

8. **Changes to this Agreement**
   - We may update this Agreement from time to time. Continued use of the App signifies acceptance of any changes.

9. **Contact Information**
   - For any legal inquiries, contact us at Global8together@gmail.com.
                      ''',
                      style: TextStyle(fontSize: 14, ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
