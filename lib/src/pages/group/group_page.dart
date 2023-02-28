import 'package:flutter/material.dart';
import 'package:group_chat_socket_io/src/foundation/msg_widget/other_message_widget.dart';
import 'package:group_chat_socket_io/src/foundation/msg_widget/own_message_widget.dart';
import 'package:group_chat_socket_io/src/pages/group/msg_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required this.name, required this.userId});
  final name;
  final String userId;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  IO.Socket? socket;
  List<MsgModel> listMsg = [];
  TextEditingController msgController = TextEditingController();
  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io("http://192.168.245.15:3000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket!.connect();
    socket!.onConnect((_) {
      print('connected into frontend');
      socket!.on("sendMsgServer", (msg) {
        print(msg);
        if (msg["userId"] != widget.userId) {
          setState(() {
            listMsg.add(MsgModel(
                type: msg["type"], msg: msg["msg"], sender: msg["senderName"]));
          });
        }
      });
    });
  }

  void sendMsg(String msg, String senderName) {
    MsgModel ownMsg = MsgModel(type: "ownMsg", msg: msg, sender: senderName);
    setState(() {
      listMsg.add(ownMsg);
    });
    socket!.emit("sendMsg", {
      "type": "ownMsg",
      "msg": msg,
      "senderName": senderName,
      "userId": widget.userId
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anonymous Group')),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: listMsg.length,
            itemBuilder: (context, index) {
              if (listMsg[index].type == "ownMsg") {
                return OwnMsgWidget(
                    msg: listMsg[index].msg, sender: listMsg[index].sender);
              } else {
                return OtherMsgWidget(
                    msg: listMsg[index].msg, sender: listMsg[index].sender);
              }
            },
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: TextFormField(
              controller: msgController,
              decoration: InputDecoration(
                  hintText: 'Type here...',
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2),
                  ),
                  suffixIcon: IconButton(
                      onPressed: () {
                        String msg = msgController.text;
                        if (msg.isNotEmpty) {
                          sendMsg(msgController.text, widget.name);
                          msgController.clear();
                        }
                      },
                      icon: Icon(Icons.send))),
            ),
          )
        ],
      ),
    );
  }
}
