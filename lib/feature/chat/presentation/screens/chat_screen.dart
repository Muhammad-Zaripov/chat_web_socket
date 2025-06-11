import 'package:chat_web_socket/core/utils/app_colors.dart';
import 'package:chat_web_socket/core/utils/app_images.dart';
import 'package:chat_web_socket/feature/chat/data/models/chat_model.dart';
import 'package:chat_web_socket/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_web_socket/feature/chat/presentation/widgets/custom_paint_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ValueNotifier<bool> isTextNotEmpty = ValueNotifier(false);
  final messageController = TextEditingController();

  @override
  void initState() {
    messageController.addListener(() {
      isTextNotEmpty.value = messageController.text.trim().isNotEmpty;
    });
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    isTextNotEmpty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uuid = Uuid();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Row(
          spacing: 10,
          children: [
            CircleAvatar(
              maxRadius: 20,
              backgroundImage: AssetImage(AppImages.avatar),
            ),
            Text('Bro'),
          ],
        ),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryColor,
            size: 25,
          ),
        ),
        actions: [
          SvgPicture.asset(AppImages.videoCall),
          SizedBox(width: 25),
          SvgPicture.asset(AppImages.call),
          SizedBox(width: 25),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.background, fit: BoxFit.cover),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return state.when(
                loading: () =>
                    Center(child: CircularProgressIndicator.adaptive()),
                error: (error) => Center(child: Text(error)),
                success: (chat) {
                  return ListView.separated(
                    reverse: true,
                    padding: EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    separatorBuilder: (context, index) =>
                        SizedBox(width: 4, height: 15),
                    itemCount: chat.length,
                    itemBuilder: (context, index) {
                      final data = chat[index];
                      final isMe = data.name == "Muhammad";
                      return Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Row(
                              children: [
                                CircleAvatar(
                                  maxRadius: 25,
                                  backgroundImage: AssetImage(AppImages.avatar),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          GestureDetector(
                            onLongPress: () {
                              context.read<ChatBloc>().add(
                                ChatEvent.deleteMessage(data.id),
                              );
                            },
                            child: CustomPaint(
                              painter: MessageBubblePainter(
                                isMe: isMe,
                                color: isMe
                                    ? AppColors.isMeMessageColor
                                    : Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: 10,
                                  top: 5,
                                ),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data.message,
                                        style: GoogleFonts.abyssinicaSil(
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        data.time.split("T")[1].substring(0, 5),
                                        style: GoogleFonts.abyssinicaSil(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.only(left: 14, right: 14, top: 7, bottom: 40),
          width: double.infinity,
          child: Row(
            spacing: 15,
            children: [
              SvgPicture.asset(AppImages.add),

              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: messageController,
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: AppColors.textFieldColor),
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          right: 12,
                        ),
                        child: SvgPicture.asset(AppImages.stickers),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: isTextNotEmpty,
                builder: (context, value, _) {
                  return value
                      ? IconButton(
                          onPressed: () {
                            context.read<ChatBloc>().add(
                              ChatEvent.sendMessage(
                                ChatModel(
                                  id: uuid.v4(),
                                  message: messageController.text.trim(),
                                  name: "Muhammad",
                                  time: DateTime.now().toIso8601String(),
                                ),
                              ),
                            );
                            messageController.clear();
                          },
                          icon: Icon(
                            Icons.send,
                            color: AppColors.primaryColor,
                            size: 30,
                          ),
                        )
                      : Row(
                          spacing: 15,
                          children: [
                            SvgPicture.asset(AppImages.nimabu),
                            SvgPicture.asset(AppImages.came),
                            SvgPicture.asset(AppImages.voice),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
