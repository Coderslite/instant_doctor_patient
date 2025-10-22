import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:instant_doctor/component/backButton.dart';
import 'package:instant_doctor/constant/color.dart';
import 'package:instant_doctor/models/AnonymousModel.dart';
import 'package:instant_doctor/screens/appointment/NewAppointment.dart';
import 'package:instant_doctor/services/AnonymousService.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';

class QuestionAnswerScreen extends StatefulWidget {
  const QuestionAnswerScreen({super.key});

  @override
  _QuestionAnswerScreenState createState() => _QuestionAnswerScreenState();
}

class _QuestionAnswerScreenState extends State<QuestionAnswerScreen> {
  final TextEditingController _questionController = TextEditingController();
  final Map<int, GlobalKey> _shareKeys = {};
  bool _isSharing = false;
  final Random _random = Random();
  final Map<String, int> _questionGradients =
      {}; // Stores gradient index for each question ID
  // Available gradient backgrounds
  int? _expandedColorCardIndex;
  int _getRandomGradientIndex() {
    return _random.nextInt(gradientOptions.length);
  }

  int _getGradientIndexForQuestion(String questionId) {
    // If we don't have a gradient for this question yet, assign a random one
    if (!_questionGradients.containsKey(questionId)) {
      _questionGradients[questionId] = _getRandomGradientIndex();
    }
    return _questionGradients[questionId]!;
  }

  void _updateQuestionGradient(String questionId, int newIndex) {
    setState(() {
      _questionGradients[questionId] = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  backButton(context),
                  Text(
                    'Q/A',
                    style: boldTextStyle(
                      weight: FontWeight.bold,
                      size: 16,
                    ),
                  ),
                  Container(
                    width: 40,
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<List<AnonymousModel>>(
                    stream: AnonymousService().getAnonymous(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        if (data.isEmpty) {
                          return _buildEmptyState();
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            itemCount: data.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final reversedIndex = data.length - 1 - index;
                              final question = data[reversedIndex];
                              _shareKeys[reversedIndex] ??= GlobalKey();
                              final gradientIndex =
                                  _getGradientIndexForQuestion(
                                      question.id.validate());
                              return _buildQuestionCard(
                                  question, reversedIndex, gradientIndex);
                            },
                          );
                        }
                      }
                      return Loader();
                    }),
              ),
              AppButton(
                width: double.infinity,
                onTap: _showQuestionDialog,
                text: "New Question",
                color: kPrimary,
                textColor: white,
                shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: white),
                    SizedBox(width: 8),
                    Text(
                      "New Question",
                      style: boldTextStyle(color: white),
                    ),
                  ],
                ),
              ),
              // _buildQuestionInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.question_answer,
              size: 80, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 20),
          Text(
            'No questions yet',
            style: boldTextStyle(
              size: 22,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Ask your first question below',
            style: secondaryTextStyle(
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

// Replace your _buildQuestionCard with this version
  Widget _buildQuestionCard(AnonymousModel qa, int index, int gradientIndex) {
    final isPending = qa.status.validate() == 'pending';
    final isShowingColors = _expandedColorCardIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: RepaintBoundary(
        key: _shareKeys[index],
        child: Dismissible(
          key: Key('${qa.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) async {
            await AnonymousService().deleteAnonymous(id: qa.id.validate());
            setState(() {
              _shareKeys.remove(index);
              if (_expandedColorCardIndex == index) {
                _expandedColorCardIndex = null;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Question deleted')),
            );
          },
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: gradientOptions[gradientIndex],
              ),
              child: Padding(
                padding: EdgeInsets.all(1.5), // Border width
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 70,
                        child: Image.asset(
                          "assets/images/logo1.png",
                          color: white,
                          opacity: Animation.fromValueListenable(
                            ValueNotifier(0.5),
                          ),
                        ),
                      ),
                      // Question
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getGradientColor(gradientIndex)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          qa.question.validate(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: white,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Answer - Pending or Answered State
                      isPending
                          ? Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.amber[200], size: 24),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your question is pending\nOur doctors will answer soon',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              qa.answer.validate(),
                              style: TextStyle(
                                fontSize: 16,
                                color: white,
                                height: 1.5,
                              ),
                            ),

                      SizedBox(height: 24),

                      // Footer with toggleable color picker
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isPending) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _expandedColorCardIndex =
                                          _expandedColorCardIndex == index
                                              ? null
                                              : index;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isShowingColors
                                              ? Icons.palette
                                              : Icons.color_lens,
                                          color: white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Background',
                                          style: secondaryTextStyle(
                                            color: white,
                                            size: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.share, size: 20, color: white),
                                  onPressed: () async {
                                    // Hide colors before sharing
                                    if (isShowingColors) {
                                      setState(() {
                                        _expandedColorCardIndex = null;
                                      });
                                      await Future.delayed(
                                          Duration(milliseconds: 100));
                                    }
                                    _captureAndShare(index);
                                  },
                                ),
                              ],
                            ),
                            if (isShowingColors) ...[
                              SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1,
                                ),
                                itemCount: gradientOptions.length,
                                itemBuilder: (context, gradIndex) {
                                  return GestureDetector(
                                    onTap: () {
                                      _updateQuestionGradient(
                                          qa.id.validate(), gradIndex);
                                      setState(() {
                                        _expandedColorCardIndex = null;
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: gradientOptions[gradIndex],
                                        borderRadius: BorderRadius.circular(6),
                                        border: gradientIndex == gradientIndex
                                            ? Border.all(
                                                color: Colors.white, width: 2)
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ],
                      ),
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.call,
                            color: white,
                            size: 14,
                          ),
                          5.width,
                          Text(
                            "talk to a doctor",
                            style: secondaryTextStyle(color: white),
                          ).center(),
                        ],
                      ).onTap(() {
                        NewAppointment().launch(context);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradientColor(int gradientIndex) {
    return gradientOptions[gradientIndex].colors.first;
  }

// Replace your current _buildQuestionInput() and modal implementation with this:

  void _showQuestionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ask Your Question',
                      style: boldTextStyle(
                        size: 20,
                        weight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.iconColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Question Input
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Type your question below',
                      style: secondaryTextStyle(
                        size: 14,
                        color: context.iconColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: kPrimary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _questionController,
                        maxLines: 5,
                        minLines: 3,
                        style: primaryTextStyle(),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(16),
                          border: InputBorder.none,
                          hintText: 'What would you like to ask?',
                          hintStyle: secondaryTextStyle(),
                        ),
                      ),
                    ),
                    // SizedBox(height: 24),

                    SizedBox(height: 32),

                    // Submit Button
                    AppButton(
                      onTap: () {
                        if (_questionController.text.trim().isNotEmpty) {
                          _submitQuestion();
                          Navigator.pop(context);
                        }
                      },
                      text: 'Submit Question',
                      color: kPrimary,
                      textColor: white,
                      width: double.infinity,
                      shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send, color: white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Submit Question',
                            style: boldTextStyle(color: white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      AnonymousService().addAnonymous(
        question: _questionController.text,
      );
      _questionController.clear();
    });
  }

  Future<void> _captureAndShare(int index) async {
    if (_isSharing) return;
    _isSharing = true;

    try {
      await Future.delayed(Duration(milliseconds: 200));

      final boundary = _shareKeys[index]?.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        _isSharing = false;
        return;
      }

      if (boundary.debugNeedsPaint) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        await Share.shareXFiles(
          [
            XFile.fromData(pngBytes,
                name: 'question_answer.png', mimeType: 'image/png')
          ],
          text: 'Check out this Q&A!',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: ${e.toString()}')),
      );
      print('Error sharing: $e');
    } finally {
      _isSharing = false;
    }
  }
}
