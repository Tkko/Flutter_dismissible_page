import 'package:dismissible_page/dismissible_page.dart';
import 'package:dismissible_page_example/demo/pages/dismissible_page_demo.dart';
import 'package:dismissible_page_example/demo/scenarios/demo_data.dart';
import 'package:dismissible_page_example/demo/widgets/dismissible_screen.dart';
import 'package:flutter/material.dart';
import 'package:dismissible_page_example/demo/theme/demo_text.dart';

/// Conversations that open as a screen you swipe back from: drag right
/// anywhere on the page and it follows your finger like a native push.
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const DismissibleBackButton(),
        title: const Text(
          'Messages',
          style: DemoText.title,
        ),
      ),
      body: ListView.separated(
        itemCount: demoContacts.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
        itemBuilder: (context, index) {
          final contact = demoContacts[index];
          return ListTile(
            onTap: () =>
                context.pushTransparentRoute(ChatPage(contact: contact)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: _Avatar(contact: contact, radius: 26),
            title: Text(
              contact.name,
              style: DemoText.plainSemiBold,
            ),
            subtitle: Text(
              contact.preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DemoText.caption,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  contact.time,
                  style: DemoText.label.copyWith(color: Colors.black45),
                ),
                const SizedBox(height: 4),
                if (contact.unread > 0)
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: contact.color,
                    child: Text(
                      '${contact.unread}',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({required this.contact, super.key});

  final DemoContact contact;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final List<DemoMessage> _messages = [...widget.contact.messages];
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add(DemoMessage(text, mine: true)));
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;

    return DismissibleDemo(
      // Swipe towards the end of the line, like going back in a navigator.
      direction: DismissiblePageDismissDirection.startToEnd,
      child: Scaffold(
        backgroundColor: const Color(0xfff4f5f9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          // A Builder, so the context is below the DismissiblePage.
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => DismissiblePage.dismiss(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              _Avatar(contact: contact, radius: 18),
              const SizedBox(width: 10),
              Text(
                contact.name,
                style: DemoText.lead,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _Bubble(
                  message: _messages[index],
                  color: contact.color,
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          filled: true,
                          fillColor: const Color(0xfff4f5f9),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _send,
                      icon: Icon(Icons.send_rounded, color: contact.color),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.color});

  final DemoMessage message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        decoration: BoxDecoration(
          color: mine ? color : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Text(
          message.text,
          style: DemoText.bodySmall
              .copyWith(color: mine ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.contact, required this.radius});

  final DemoContact contact;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: contact.color.withValues(alpha: 0.18),
      child: Text(
        contact.initials,
        style: DemoText.plainBold
            .copyWith(color: contact.color, fontSize: radius * 0.7),
      ),
    );
  }
}
