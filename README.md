# sdb_trainer

weight lifting trainer app

## server 사용법
1. Docker 설치 한다.
2. flutter/lib/localhost.dart 에서 본인 컴터 ip로 고친다. 
3. sudo service docker start ---- 로 Docker 실행시킨다.
4. docker run -d -p 9000:9000 --name=portainer --restart=unless-stopped -v /var/run/docker.sock:/var/run/docker.sock -v /var/portainer/data:/data portainer/portainer----Docker 툴인 portainer 를 9000포트에서 실행시킨다.
5. scripts/build.sh를 sh build.sh로 실행시킨다.(Docker에 서버를 구축해주는 작업)
6. 본인컴퓨터 ip ex:) http://172.20.138.109:9000 위로 브라우저로 접속해서 Portainer를 킨다.
7. backend는 http://172.20.138.109:8888/api/docs (스웨거), pgadmin http://172.20.138.109:8088/ (pgadmin, postgresql)
8. pgadmin ID, 비밀번호는 postgres, 1234
9. backend는 fastAPI, DB는 postgresql, DB 관리는 alembic

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
