import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/controllers/ReferController.dart';
import 'package:instant_doctor/main.dart';
import 'package:instant_doctor/models/UserModel.dart';
import 'package:instant_doctor/services/GetUserId.dart';
import 'package:instant_doctor/services/format_number.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {
  final referralController = Get.find<ReferralController>();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  bool _hasAccountDetails = false;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
  }

  void _loadAccountDetails() {
    // Load account details from user data

    if (user != null &&
        userController.bankName.value.isNotEmpty &&
        userController.accountNumber.isNotEmpty) {
      setState(() {
        _bankNameController.text = userController.bankName.value;
        _accountNumberController.text = userController.accountNumber.value;
        _accountNameController.text = userController.accountName.value;
        _hasAccountDetails = true;
      });
    }
  }

  Future<void> _saveAccountDetails() async {
    if (_bankNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty) {
      toast("Please enter bank name and account number");
      return;
    }

    if (_accountNumberController.text.length < 10) {
      toast("Account number must be at least 10 digits");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update user data with bank details
      final updatedData = {
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'accountName': _accountNameController.text.trim(),
      };

      // Call your service to update user in database
      await userService.updateProfile(
        userId: userController.userId.value,
        data: updatedData,
      );

      setState(() {
        _hasAccountDetails = true;
        _isEditing = false;
      });

      toast("Account details saved successfully");
    } catch (e) {
      toast("Failed to save account details: $e");
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteAccountDetails() async {
    showConfirmDialogCustom(
      context,
      title: "Remove Account Details",
      subTitle:
          "Are you sure you want to remove your bank account details? You won't receive payments until you add new details.",
      onAccept: (context) async {
        try {
          // Remove bank details from user data
          final updatedData = {
            'bankName': null,
            'accountNumber': null,
            'accountName': null,
          };

          await userService.updateProfile(
            userId: userController.userId.value,
            data: updatedData,
          );

          setState(() {
            _bankNameController.clear();
            _accountNumberController.clear();
            _accountNameController.clear();
            _hasAccountDetails = false;
            _isEditing = false;
          });

          toast("Account details removed");
        } catch (e) {
          toast("Failed to remove account details: $e");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  backButton(context),
                  16.width,
                  Text(
                    "Refer & Earn",
                    style: boldTextStyle(size: 24),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      _showWithdrawDialog();
                    },
                    icon: Icon(Iconsax.wallet_3, size: 24, color: kPrimary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Balance Card
                    StreamBuilder<UserModel>(
                      stream: userService.getProfile(
                          userId: userController.userId.value),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final user = snapshot.data!;
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [kPrimary, Color(0xFF6C63FF)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Iconsax.wallet_money,
                                          color: Colors.white),
                                    ),
                                    16.width,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Available Balance",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              fontSize: 14,
                                            ),
                                          ),
                                          4.height,
                                          Text(
                                            "₦${formatAmountWithoutCurrency(user.referralBalance.validate().toInt())}",
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 32,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                20.height,
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Icon(Iconsax.gift,
                                              color: Colors.white, size: 24),
                                          8.height,
                                          Text(
                                            "Instant Bonus",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                          4.height,
                                          Text(
                                            "₦50",
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "On Sign-up",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Icon(Iconsax.calendar_1,
                                              color: Colors.white, size: 24),
                                          8.height,
                                          Text(
                                            "Payment Date",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                          4.height,
                                          Text(
                                            "28th Monthly",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "Auto Payout",
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kPrimary, Color(0xFF6C63FF)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white)),
                        );
                      },
                    ),

                    24.height,

                    // Referral Code Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Referral Code",
                            style: boldTextStyle(size: 20),
                          ),
                          16.height,
                          StreamBuilder<UserModel>(
                            stream: userService.getProfile(
                                userId: userController.userId.value),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final user = snapshot.data!;
                                final referralCode = user.tag.validate();

                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.grey[200]!, width: 1),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: kPrimary.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Iconsax.tag_2,
                                                color: kPrimary),
                                            12.width,
                                            Text(
                                              referralCode,
                                              style: boldTextStyle(
                                                  size: 24, color: kPrimary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      20.height,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: referralCode));
                                                toast("Referral code copied");
                                              },
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16),
                                                side: BorderSide(
                                                    color: kPrimary, width: 2),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Iconsax.copy,
                                                      color: kPrimary),
                                                  8.width,
                                                  Text(
                                                    "Copy Code",
                                                    style: boldTextStyle(
                                                        color: kPrimary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          16.width,
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                await referralController
                                                    .handleShare(
                                                        code: referralCode);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: kPrimary,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Iconsax.share,
                                                      color: Colors.white),
                                                  8.width,
                                                  Text(
                                                    "Share",
                                                    style: boldTextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                        ],
                      ),
                    ),

                    32.height,

                    // Account Details Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.bank, color: kPrimary, size: 24),
                                  12.width,
                                  Text(
                                    "Account Details",
                                    style: boldTextStyle(size: 20),
                                  ),
                                ],
                              ),
                              if (_hasAccountDetails &&
                                  !_isEditing &&
                                  !_isSaving)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  },
                                  icon: Icon(Iconsax.edit_2,
                                      color: kPrimary, size: 20),
                                ),
                            ],
                          ),
                          16.height,
                          if (_hasAccountDetails && !_isEditing)
                            _buildAccountDetailsDisplay()
                          else
                            _buildAccountDetailsForm(),
                        ],
                      ),
                    ),

                    32.height,

                    // How It Works
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: context.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "How It Works",
                            style: boldTextStyle(size: 20),
                          ),
                          20.height,
                          _buildStep(
                            number: 1,
                            title: "Share your code",
                            description:
                                "Share your unique referral code with friends and family",
                            icon: Iconsax.share,
                          ),
                          16.height,
                          _buildStep(
                            number: 2,
                            title: "They sign up",
                            description:
                                "When they register with your code, you earn ₦50 instantly",
                            icon: Iconsax.user_add,
                          ),
                          16.height,
                          _buildStep(
                            number: 3,
                            title: "They book appointments",
                            description:
                                "When they book appointments, you earn 10% of their payments",
                            icon: Iconsax.calendar,
                          ),
                          16.height,
                          _buildStep(
                            number: 4,
                            title: "Monthly Payout",
                            description:
                                "Earnings are automatically paid to your saved account on the 28th of every month",
                            icon: Iconsax.money_send,
                          ),
                        ],
                      ),
                    ),

                    24.height,

                    // Rewards & Payout Info
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green[100]!),
                          color: context.cardColor),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Iconsax.info_circle, color: Colors.green),
                              12.width,
                              Text(
                                "Reward Structure & Payout",
                                style: boldTextStyle(
                                    size: 18, color: Colors.green),
                              ),
                            ],
                          ),
                          16.height,
                          _buildRewardItem(
                            "Instant Sign-up Bonus",
                            "₦50",
                          ),
                          _buildRewardItem(
                            "Appointment Commission",
                            "10% of payment",
                          ),
                          _buildRewardItem(
                            "Payment Schedule",
                            "28th of every month",
                          ),
                          _buildRewardItem(
                            "Minimum Withdrawal",
                            "₦1,000",
                          ),
                          _buildRewardItem(
                            "Admin View",
                            "Can see your bank details for payment",
                          ),
                        ],
                      ),
                    ),

                    40.height,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailsDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem("Bank Name", _bankNameController.text),
        12.height,
        _buildDetailItem("Account Number", _accountNumberController.text),
        12.height,
        if (_accountNameController.text.isNotEmpty)
          Column(
            children: [
              _buildDetailItem("Account Name", _accountNameController.text),
              12.height,
            ],
          ),
        16.height,
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _deleteAccountDetails,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.trash, color: Colors.red, size: 20),
                    8.width,
                    Text(
                      "Remove",
                      style: boldTextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            12.width,
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.edit_2, color: Colors.white, size: 20),
                    8.width,
                    Text(
                      "Edit",
                      style: boldTextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        16.height,
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, color: Colors.blue, size: 20),
              8.width,
              Expanded(
                child: Text(
                  "Admin can view these details for monthly payments on the 28th",
                  style: primaryTextStyle(size: 12, color: Colors.blue[800]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetailsForm() {
    return Column(
      children: [
        AppTextField(
          controller: _bankNameController,
          textFieldType: TextFieldType.NAME,
          decoration: InputDecoration(
            label: Text("Bank Name*"),
            hintText: "e.g., GTBank, First Bank",
            prefixIcon: Icon(Iconsax.bank, size: 20),
            filled: true,
            hintStyle: secondaryTextStyle(),
            fillColor: context.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
        ),
        16.height,
        AppTextField(
          controller: _accountNumberController,
          textFieldType: TextFieldType.PHONE,
          maxLength: 10,
          decoration: InputDecoration(
            label: Text("Account Number*"),
            hintText: "10-digit account number",
            hintStyle: secondaryTextStyle(),
            prefixIcon: Icon(Iconsax.card, size: 20),
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
        ),
        16.height,
        AppTextField(
          controller: _accountNameController,
          textFieldType: TextFieldType.NAME,
          decoration: InputDecoration(
            label: Text("Account Name"),
            hintText: "Name on account",
            prefixIcon: Icon(Iconsax.user, size: 20),
            filled: true,
            fillColor: context.cardColor,
            hintStyle: secondaryTextStyle(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: gray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPrimary, width: 1.5),
            ),
          ),
        ),
        20.height,
        Row(
          children: [
            if (_hasAccountDetails)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: boldTextStyle(),
                  ),
                ),
              ),
            if (_hasAccountDetails) 12.width,
            Expanded(
              child: _isSaving
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: kPrimary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _saveAccountDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _hasAccountDetails ? "Update Details" : "Save Details",
                        style: boldTextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
        16.height,
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, color: Colors.blue, size: 20),
              8.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Important:",
                      style: boldTextStyle(size: 12, color: Colors.blue[800]),
                    ),
                    4.height,
                    Text(
                      "• Admin will use these details to pay you on the 28th of every month\n"
                      "• Ensure details are accurate to avoid payment delays\n"
                      "• Minimum balance for payout: ₦1,000",
                      style:
                          primaryTextStyle(size: 11, color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        4.height,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: boldTextStyle(size: 16),
          ),
        ),
      ],
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Iconsax.wallet_3, color: kPrimary),
            12.width,
            Text("Withdraw Earnings", style: boldTextStyle(size: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment Information",
              style: boldTextStyle(size: 16),
            ),
            12.height,
            Text(
              "• Automatic payouts on the 28th of every month\n"
              "• Minimum balance required: ₦1,000\n"
              "• Payments sent to your saved bank account\n"
              "• Admin processes all payments manually\n"
              "• Contact support for payment inquiries",
              style: primaryTextStyle(),
            ),
            20.height,
            if (!_hasAccountDetails)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.warning_2, color: Colors.orange),
                    8.width,
                    Expanded(
                      child: Text(
                        "Add bank account details to receive payments",
                        style: primaryTextStyle(color: Colors.orange[800]),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: primaryTextStyle()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (!_hasAccountDetails) {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimary,
            ),
            child: Text(
              _hasAccountDetails ? "Check Balance" : "Add Account",
              style: boldTextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: kPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        16.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: kPrimary, size: 20),
                  8.width,
                  Text(
                    title,
                    style: boldTextStyle(size: 16),
                  ),
                ],
              ),
              8.height,
              Text(
                description,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.5,
                    color: settingsController.isDarkMode.value
                        ? white.withOpacity(0.5)
                        : black.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: primaryTextStyle(size: 14),
            ),
          ),
          10.width,
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 14, color: kPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
