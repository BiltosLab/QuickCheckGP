/*
 * QuickCheck - Attendance Checking System
 * 
 * Author : mrlaith44@gmail.com
 * 
 * Copyright (C) 2024 Laith Shishani. All rights reserved.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quickcheck/components/Buttons.dart';
import 'package:quickcheck/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  // Chat or messages idk
  MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> chats = [];
  Timer? timer;
  int lastid = 0;
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    await fetchChats();
    messageslistener();
  }

  void
      messageslistener() // This is a hack i have implemented because of some broken stuff in supabase i can't use realtime stuff
  {
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      await checkmessages();
    });
  }

  Future<void> checkmessages() async {
    final response = await supabase
        .from('messages')
        .select('id')
        .order('id', ascending: false)
        .limit(1)
        .single();
    if (response['id'] > lastid) {
      await _fetchChats().whenComplete(() {
        if (mounted) {
          setState(() {
            lastid = response['id'];
          });
        }
      });
    } else {
      return;
    }
  }

  String determineKey(Map<String, dynamic> message, String currentUserId) {
    // This could be sender_id + receiver_id concatenated, or sorted in some manner
    List<String> ids = [message['sender_id'], message['receiver_id']];
    ids.sort(); // Sort to avoid duplicates from order variation (user1_user2 is the same as user2_user1)
    return ids.join('_');
  }

  Future<void> fetchChats() async {
    List<Map<String, dynamic>> enrichedMessages = [];
    final userId = supabase.auth.currentUser?.id;
    final response = await supabase
        .from('messages')
        .select()
        .ilike('msguuidsconcat', '%${userId}%')
        .order('timestamp', ascending: false);

    if (response.isNotEmpty) {
      for (var data in response) {
        String idforname = data['sender_id'].toString().contains(userId!)
            ? data['receiver_id']
            : data['sender_id'];
        String name = await getfullname(idforname);
        Map<String, dynamic> enrichedData = {
          ...data,
          'name': name
        };
        enrichedMessages
            .add(enrichedData);
      }
      Map<String, Map<String, dynamic>> latestMessages = {};

      for (var message in enrichedMessages) {
        String key = determineKey(
            message, userId!);
        DateTime currentMessageTime = DateTime.parse(message['timestamp']);
        if (!latestMessages.containsKey(key) ||
            DateTime.parse(latestMessages[key]!['timestamp'])
                .isBefore(currentMessageTime)) {
          latestMessages[key] = message;
        }
      }
      List<Map<String, dynamic>> chats = latestMessages.values.toList();

      if (mounted) {
        setState(() {
          this.chats = chats as List<Map<String, dynamic>>;
        });
      }
    } else {
      print('Error fetching chats: ${response.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        leading: const Back_Button(),
        title: const Text(
          "Messages",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ListTile(
                title: Text(
                  chat['name'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  chat['message'],
                  style: const TextStyle(color: Color.fromARGB(255, 168, 168, 168)),
                ),
                onLongPress: () {
                  print(
                      "LONG PRESS? ${chat['sender_id'] + " " + chat['receiver_id']}");
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUserId: supabase.auth.currentUser!.id,
                        otherUserId:
                            (chat['sender_id'] == supabase.auth.currentUser!.id
                                ? chat['receiver_id']
                                : chat['sender_id']),
                      ),
                    ),
                  );
                  if (mounted) {
                    _fetchChats();
                    setState(() {});
                  }
                });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 136, 90, 222),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MessagesSelectionScreen()));
          if (mounted) {
            setState(() {});
          }
        },
        tooltip: 'Start Messaging',
        child: const MessagesAddButton(),
      ),
    );
  }
}

class MessagesSelectionScreen extends StatefulWidget {
  const MessagesSelectionScreen({super.key});

  @override
  State<MessagesSelectionScreen> createState() =>
      _MessagesSelectionScreenState();
}

class _MessagesSelectionScreenState extends State<MessagesSelectionScreen> {
  List<Map<String, dynamic>> searchResults = [];
  String searchQuery = '';

  Future<void> searchuser(String chars) async {
    final response = await supabase
        .from('user_profiles')
        .select('user_id,first_name,last_name')
        .ilike('userfullname', '%$chars%');

    if (response.isNotEmpty) {
      if (mounted) {
        setState(() {
          searchResults = response as List<Map<String, dynamic>>;
        });
      }
    } else {
      print('Error searching users: ${response.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        leading: const Back_Button(),
        title: const Text(
          "Messages",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      searchQuery = value;
                    });
                  }
                  searchuser(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search by name',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  return ListTile(
                    title: Text(
                      (user['first_name'] + ' ' + user['last_name']),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                    currentUserId:
                                        supabase.auth.currentUser!.id,
                                    otherUserId: user['user_id'],
                                  )));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;

  ChatScreen({required this.currentUserId, required this.otherUserId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? timer1;
  int lastid = 0;

  @override
  void initState() {
    super.initState();
    print("SENDER UUID ${widget.currentUserId}");
    print("OTHER UUID ${widget.otherUserId}");
    _fetchChats();
  }

  @override
  void dispose() {
    super.dispose();
    timer1?.cancel();
    
  }
   Future<void> _fetchChats() async {
    streamofmsg();
    messageslistener();
  }
  void
      messageslistener() // This is a hack i have implemented because of some broken stuff in supabase i can't use realtime stuff
  {
    timer1 = Timer.periodic(const Duration(seconds: 5), (Timer timer) async {
      await checkmessages();
    });
  }

    Future<void> checkmessages() async {
    final response = await supabase
        .from('messages')
        .select('id')
        .order('id', ascending: false)
        .limit(1)
        .single();
    if (response['id'] > lastid) {
      await _fetchChats().whenComplete(() {
        if (mounted) {
          setState(() {
            lastid = response['id'];
          });
        }
      });
    } else {
      return;
    }
  }

  Stream<List<Map<String, dynamic>>> streamofmsg() {
    final star = supabase
        .from('messages')
        .select()
        .ilike('msguuidsconcat', '%${widget.currentUserId}%')
        .ilike('msguuidsconcat', '%${widget.otherUserId}%')
        .asStream();


    return star;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 39, 70),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 51, 54, 97),
        leading: const Back_Button(),
        title: const Text(
          "Chat",
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color.fromARGB(
                255, 74, 76, 133),
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder(
              stream: streamofmsg(),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isSender =
                        message['sender_id'] == widget.currentUserId;
                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSender
                              ? const Color.fromARGB(255, 68, 119, 206)
                              : const Color.fromARGB(255, 140, 171, 255),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              message['message'],
                              style: TextStyle(
                                  color:
                                      isSender ? Colors.white : Colors.black),
                            ),
                            Text(
                              DateFormat('h:mm a')
                                  .format(DateTime.parse(message['timestamp'])),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 185, 185, 185)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelStyle: const TextStyle(color: Colors.white),
                hintStyle: const TextStyle(color: Colors.white),
                suffixStyle: const TextStyle(color: Colors.white),
                fillColor: Colors.white,
                labelText: "Type a message",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      await Supabase.instance.client.from('messages').insert({
        'sender_id': widget.currentUserId,
        'receiver_id': widget.otherUserId,
        'message': _controller.text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _controller.clear();

      print("SENDER UUID ${widget.currentUserId}");
      print("OTHER UUID ${widget.otherUserId}");
    }
    if (mounted) {
      setState(() {});
    }
  }
}
