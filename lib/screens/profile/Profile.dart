import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instant_doctor/component/AnimatedCard.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/AuthenticationController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/screens/profile/about/About.dart';
import 'package:instant_doctor/screens/profile/help/Help.dart';
import 'package:instant_doctor/screens/profile/medical/MedicalData.dart';
import 'package:instant_doctor/screens/profile/personal/PersonalProfile.dart';
import 'package:instant_doctor/screens/profile/policy/Policy.dart';
import 'package:instant_doctor/screens/refer/ApplyRefer.dart';
import 'package:instant_doctor/screens/refer/Refer.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../component/ProfileImage.dart';
import '../../component/check_country.dart';
import '../../component/check_internet.dart';
import '../../controllers/ReferController.dart';
import '../../models/UserModel.dart';
import '../../services/GetAppVersion.dart';
import '../settings/SettingScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthenticationController authenticationController =
      Get.put(AuthenticationController());
  ReferralController referralController = Get.put(ReferralController());

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    settingsController.version.value = await getAppVersion();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return SafeArea(
          top: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: context.scaffoldBackgroundColor,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfileHeader(context),
                      ],
                    ),
                  ),
                ),
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                    ),
                    onPressed: () => const SettingScreen().launch(context),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    children: [
                      _buildProfileStatsCard(),
                      24.height,
                      _buildProfileOptions(),
                      24.height,
                      _buildAppVersion(),
                      16.height,
                      _buildSignOutButton(),
                      20.height,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: userService.getProfile(userId: userController.userId.value),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return Column(
            children: [
              internetCheck(),
              countryCheck(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gray, width: 2),
                    ),
                    child: ClipOval(
                      child:
                          profileImage(UserModel(), 100, 100, context: context),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimary, width: 2),
                      ),
                      child: Icon(Icons.edit, size: 16, color: kPrimary),
                    ).onTap(
                        () => const PersonalProfileScreen().launch(context)),
                  ),
                ],
              ),
              12.height,
              Text(
                "${user.firstName} ${user.lastName}",
                style: boldTextStyle(size: 20),
              ),
            ],
          );
        }
        return Loader();
      },
    );
  }

  Widget _buildProfileStatsCard() {
    return StreamBuilder<UserModel>(
      stream: userService.getProfile(userId: userController.userId.value),
      builder: (context, snapshot) {
        print(
            'StreamBuilder snapshot: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, error: ${snapshot.error}');
        if (snapshot.hasData) {
          final user = snapshot.data!;
          print(
              'User data: dob=${user.dob}, address=${user.address}, bloodGroup=${user.bloodGroup}, weight=${user.weight}, height=${user.height}');
          final isPersonalDataIncomplete =
              user.dob == null || user.address.validate().isEmpty;
          final isMedicalDataIncomplete = user.bloodGroup == null ||
              user.bloodGroup!.isEmpty ||
              user.weight == null ||
              user.weight!.isEmpty ||
              user.height == null ||
              user.height!.isEmpty;

          if (isPersonalDataIncomplete) {
            print(
                'Showing incomplete personal profile card with colors: amber, orange');
            return _buildIncompleteProfileCard(false);
          } else if (isMedicalDataIncomplete) {
            print(
                'Showing incomplete medical data card with colors: amber, orange');
            return _buildIncompleteProfileCard(true);
          }

          print(
              'Showing complete profile card with colors: $kPrimary, $kPrimaryDark');
          return AnimatedCard(
            key: UniqueKey(),
            color1: kPrimary,
            color2: kPrimaryDark,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem("Age",
                          "${(DateTime.now().difference(user.dob!.toDate())).inDays ~/ 365} yrs"),
                      _buildStatItem(
                          "Blood Group",
                          user.bloodGroup.validate().isNotEmpty
                              ? user.bloodGroup!
                              : "N/A"),
                      _buildStatItem("Weight", "${user.weight.validate()} kg"),
                      _buildStatItem("Height", "${user.height.validate()} cm"),
                    ],
                  ),
                  12.height,
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          print('Stream error: ${snapshot.error}');
          return Text('Error loading profile: ${snapshot.error}');
        }
        print('Showing loader');
        return Loader();
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: boldTextStyle(size: 14, color: Colors.white)),
        Text(label,
            style: secondaryTextStyle(
                size: 12, color: Colors.white.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildIncompleteProfileCard(bool isMedicalDataIncomplete) {
    return AnimatedCard(
      key: UniqueKey(),
      color1: Colors.amber,
      color2: Colors.orange,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                12.width,
                Expanded(
                  child: Text(
                    isMedicalDataIncomplete
                        ? "Complete medical data to access all features"
                        : "Complete your profile to access all features",
                    style: boldTextStyle(size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            12.height,
            AvatarGlow(
              glowShape: BoxShape.rectangle,
              glowBorderRadius: BorderRadius.circular(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  await (isMedicalDataIncomplete
                      ? const MedicalDataScreen().launch(context)
                      : const PersonalProfileScreen().launch(context));
                  setState(() {});
                },
                child: Text(
                  isMedicalDataIncomplete
                      ? "Complete Medical Data"
                      : "Complete Profile",
                  style: boldTextStyle(size: 14, color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildProfileOptionTile(
          icon: Icons.person_outline,
          title: "Personal Information",
          subtitle: "Update your personal details",
          onTap: () => const PersonalProfileScreen().launch(context),
        ),
        _buildProfileOptionTile(
          icon: Icons.medical_services_outlined,
          title: "Medical Data",
          subtitle: "Manage your health information",
          onTap: () => const MedicalDataScreen().launch(context),
        ),
        _buildProfileOptionTile(
            icon: Icons.monetization_on,
            title: "Referral",
            subtitle: "Refer and earn",
            onTap: () {
              if (userController.referralProgramApplied.value) {
                ReferScreen().launch(context);
              } else {
                ApplyReferralProgramScreen().launch(context);
              }
            }).visible(userController.referralEnabled.value),
        _buildProfileOptionTile(
          icon: Icons.privacy_tip_outlined,
          title: "Privacy",
          subtitle: "Manage your account security",
          onTap: () {
            launchUrl(Uri.parse("http://instantdoctor.co/privacy.php"));
          },
        ),
        _buildProfileOptionTile(
          icon: Icons.policy_outlined,
          title: "Policy",
          subtitle: "Read our terms and conditions",
          onTap: () => const PolicyScreen().launch(context),
        ),
        _buildProfileOptionTile(
          icon: Icons.help_outline,
          title: "Help & Support",
          subtitle: "Contact our support team",
          onTap: () => const HelpScreen().launch(context),
        ),
        _buildProfileOptionTile(
          icon: Icons.info_outline,
          title: "About Instant Doctor",
          subtitle: "Learn more about our app",
          onTap: () => AboutScreen(version: settingsController.version.value)
              .launch(context),
        ),
      ],
    );
  }

  Widget _buildProfileOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: context.cardColor,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: kPrimary),
        ),
        title: Text(title, style: boldTextStyle(size: 14)),
        subtitle: Text(subtitle, style: secondaryTextStyle(size: 12)),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAppVersion() {
    return Text(
      "Version ${settingsController.version.value}",
      style: secondaryTextStyle(size: 12),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: redColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => authenticationController.handleLogout(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18, color: redColor),
            8.width,
            Text(
              "Sign Out",
              style: boldTextStyle(size: 16, color: redColor),
            ),
          ],
        ),
      ),
    );
  }
}
