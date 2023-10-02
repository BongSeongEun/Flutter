import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:video_call/const/agora.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({Key? key}) : super(key: key);

  @override
  _CamScreenState createState() => _CamScreenState();
}

class _CamScreenState extends State<CamScreen> {

  RtcEngine? engine;
  int? uid;  //내 id
  int? otherUid;  //상대방 id

  Future<bool> init() async{
    final resp = await [Permission.camera, Permission.microphone].request();  //권한 요청 설정

    final cameraPermission = resp[Permission.camera];
    final micPermission = resp[Permission.microphone];

    if (cameraPermission != PermissionStatus.granted ||
        micPermission != PermissionStatus.granted) {
      throw '카메라 또는 마이크 권한이 없습니다.';
    }


    if (engine == null){  //엔진이 정의되지 않았다면
      engine = createAgoraRtcEngine();  //새로 정의하기
      await engine!.initialize(  //아고라 엔진을 초기화
        RtcEngineContext(  //초기화할 때 사용할 설정
          appId: APP_ID,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,  //라이브 동영상 송출에 최적화
        ),
      );
      engine!.registerEventHandler(  //아고라 엔진에서 받을 수 있는 이벤트값 등록
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {  //접속에 성공했을 때
            print('채널에 입장했습니다. uid : ${connection.localUid}');
            setState(() {
              this.uid = connection.localUid;
            });
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {  //퇴장했을 때
            print('채널 퇴장');
            setState(() {
              uid = null;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {  //다른 사용자가 들어왔을 때
            print('상대가 채널에 입장했습니다. uid : $remoteUid');
            setState(() {
              otherUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,  //다른 사용자가 나갔을 때
              UserOfflineReasonType reason) {
            print('상대가 채널에서 나갔습니다. uid : $uid');
            setState(() {
              otherUid = null;
            });
          },
        ),
      );

      await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);  //엔진으로 영상을 송출하겠다고 설정
      await engine!.enableVideo();  //동영상 기능 활성화
      await engine!.startPreview();  //카메라를 이용해 동영상을 화면에 실행
      await engine!.joinChannel(  //채널에 접속
        token: TEMP_TOKEN,
        channelId: CHANNEL_NAME,
        options: ChannelMediaOptions(),
        uid: 0,
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LIVE'),
      ),
      body: FutureBuilder(  //Future값을 반환하는 함수의 결과에 따라 위젯을 렌더링
        future: init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {  //future값에 따라 다르게 렌더링 하고 싶은 로직을 작성
          if (snapshot.hasError) {  //실핼 후 오류가 있을 때
            return Center(
              child: Text(
                snapshot.error.toString(),  //오류값 가져오기
              ),
            );
          }

          if (!snapshot.hasData) {  //실행 후 데이터가 없을 때
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    renderMainView(),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        color: Colors.grey,
                        height: 160,
                        width: 120,
                        child: renderSubView(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (engine != null) {
                      await engine!.leaveChannel();
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('채널 나가기'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget renderSubView() {  //내 핸드폰이 찍는 화면
    if (uid != null) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine!,

          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget renderMainView() {  //상대방 핸드폰이 찍는 화면
    if (otherUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine!,

          canvas: VideoCanvas(uid: otherUid),
          connection: const RtcConnection(channelId: CHANNEL_NAME),
        ),
      );
    } else {
      return Center(
        child: const Text(
          '다른 사용자가 입장할 때까지 대기해주세요.',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
