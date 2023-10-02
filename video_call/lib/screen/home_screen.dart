import 'package:flutter/material.dart';
import 'package:video_call/screen/cam_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100]!,  //배경색 설정
      body: SafeArea(  //레이아웃 설정
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [  //레이아웃 나누기
              Expanded(child: _Logo()),  //로고
              Expanded(child: _Image()),  //이미지
              Expanded(child: _EntryButton()),  //통화 시작 버튼
            ],
          ),
        ),
      ),
    );
  }
}
class _Logo extends StatelessWidget {  //로고 설정
  const _Logo({Key? key}) :  super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
                color: Colors.blue[300]!,
                blurRadius: 12.0,
                spreadRadius: 2.0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam,
                color: Colors.white,
                size: 40.0,
              ),
              SizedBox(width: 12.0),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  letterSpacing: 4.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class _Image extends StatelessWidget {  //이미지 설정
  const _Image({Key? key}) : super(key: key);

  @override
  Widget build (BuildContext context) {
    return Center(
      child: Image.asset(
        'asset/img/home_img.png',
      ),
    );
  }
}
class _EntryButton extends StatelessWidget {  //입장 버튼 설정
  const _EntryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: (){
            Navigator.of(context).push(  // push() => 다른 페이지로 이동
              MaterialPageRoute(
                builder: (_) => CamScreen(),
              ),
            );
          },
          child: Text('입장하기'),
        ),
      ],
    );
  }
}