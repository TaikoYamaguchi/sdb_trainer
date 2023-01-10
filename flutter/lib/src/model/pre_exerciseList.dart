import 'package:sdb_trainer/src/model/exercisesdata.dart';

List<Exercises> new_Ex = [
  Exercises(
      goal: 0.0,
      name: '머신 로우 로우',
      image: null,
      onerm: 0.0,
      custom: false,
      target: ["등", "이두"],
      category: "머신",
      note: ''),
  Exercises(
      goal: 0.0,
      name: '머신 하이 로우',
      image: null,
      onerm: 0.0,
      custom: false,
      target: ["등", "이두"],
      category: "머신",
      note: ''),
  Exercises(
      goal: 0.0,
      name: ' 얼터네이팅 덤벨 컬',
      image: null,
      onerm: 0.0,
      custom: false,
      target: ["이두"],
      category: "덤벨",
      note: ''),
  Exercises(
      goal: 0.0,
      name: ' 얼터네이팅 해머 컬',
      image: null,
      onerm: 0.0,
      custom: false,
      target: ["이두"],
      category: "덤벨",
      note: ''),
];

List<String> delete_Ex = [
  '원 암 덤벨 로우',
  '시티드 로우',
  '바이셉스 컬',
  '바텀 하프 컬',
  '탑 하프 컬',
  '라잉 더블 바이셉스 케이블 컬',
  '로프 케이블 해머 컬',
  '싱글 암 바벨 컬',
  '시티드 카프 레이즈',
  '플랫 벤치 프레스',
  '머신 버티컬 벤치 프레스',
  '덤벨 트위스팅 숄더 프레스',
  '시티드 덤벨 리어 델트 엘보우 레이즈',
  '싱글 암 케이블 리어 델트 레이즈(무릎)',
  '포워드 린 딥스',
  '디클라인 싱글 덤벨 트라이셉스 익스텐션',
  '디클라인 싱글 암 덤벨 트라이셉스 익스텐션',
  '로우 케이블 트라이셉스 익스텐션',
  '라잉 오버헤드 EZ바 트라이셉스 익스텐션',
  '라잉 리버스 EZ바 트라이셉스 익스텐션',
  '싱글 암 타월 트라이셉 푸쉬다운',
  '타월 트라이셉스 푸쉬다운',
];

Map image_dir = {
  '풀 리버스 크런치': 'assets/gif/401913-7a28cb_360.webp',
  '인클라인 힙 쓰러스트': 'assets/gif/490213-7a28cb_360.webp',
  '인클라인 리버스 크런치': 'assets/gif/184513-7a28cb_360.webp',
  '라잉 힙 쓰러스트': 'assets/gif/207213-7a28cb_360.webp',
  '리버스 크런치': 'assets/gif/087213-7a28cb_360.webp',
  '케이블 풀 쓰루': 'assets/gif/019613-7a28cb_360.webp',
  '리버스 크런치(메디신 볼)': 'assets/gif/503113-7a28cb_360.webp',
  '알터네이팅 힐 터치': 'assets/gif/000613-7a28cb_360.webp',
  '벤트 니 힙 로테이션(메디신 볼)': 'assets/gif/363913-7a28cb_360.webp',
  '케이블 챱': 'assets/gif/457313-7a28cb_360.webp',
  '행잉 레그 레이즈': 'assets/gif/047213-7a28cb_360.webp',
  '평행바 레그 레이즈': 'assets/gif/296313-7a28cb_360.webp',
  '레그 레이즈': 'assets/gif/116313-7a28cb_360.webp',
  '크로스 크런치': 'assets/gif/026213-7a28cb_360.webp',
  '크로스 크런치(메디신 볼)': 'assets/gif/526613-7a28cb_360.webp',
  '디클라인 크로스 싯업': 'assets/gif/252313-7a28cb_360.webp',
  '디클라인 트위스트 싯업': 'assets/gif/497213-7a28cb_360.webp',
  '리버스 케이블 챱': 'assets/gif/169713-7a28cb_360.webp',
  '시티드 메디신 볼 트위스트': 'assets/gif/069413-7a28cb_360.webp',
  '트렁크 로테이터': 'assets/gif/068713-7a28cb_360.webp',
  '프론트 플랭크(무릎)': 'assets/gif/323813-7a28cb_360.webp',
  '프론트 플랭크(발가락)': 'assets/gif/046313-7a28cb_360.webp',
  '사이드 플랭크(무릎)': 'assets/gif/350313-7a28cb_360.webp',
  '사이드 플랭크(힙)': 'assets/gif/346013-7a28cb_360.webp',
  '사이드 플랭크(발가락)': 'assets/gif/071513-7a28cb_360.webp',
  'AB 사이클': 'assets/gif/488313-7a28cb_360.webp',
  'AB 롤아웃(무릎)': 'assets/gif/085713-7a28cb_360.webp',
  'V-UP(메디신 볼)': 'assets/gif/281513-7a28cb_360.webp',
  'V-UP': 'assets/gif/362213-7a28cb_360.webp',
  '벤트 니 싯업': 'assets/gif/087113-7a28cb_360.webp',
  '벤트 니 크런치': 'assets/gif/087113-7a28cb_360.webp',
  '크런치': 'assets/gif/027413-7a28cb_360.webp',
  '디클라인 크런치': 'assets/gif/027713-7a28cb_360.webp',
  '사이드 브릿지': 'assets/gif/070513-7a28cb_360.webp',
  '머신 AB 크런치': 'assets/gif/145213-7a28cb_360.webp',
  '디클라인 싯업': 'assets/gif/028213-7a28cb_360.webp',
  '케이블 AB 크런치': 'assets/gif/017513-7a28cb_360.webp',
  '힐 터치': 'assets/gif/400713-7a28cb_360.webp',
  '덤벨 사이드 밴드': 'assets/gif/433513-7a28cb_360.webp',
  '싯업': 'assets/gif/073513-7a28cb_360.webp',
  '어시스티드 풀업': 'assets/gif/001713-7a28cb_360.webp',
  '클로즈그립 랫 풀다운': 'assets/gif/104713-7a28cb_360.webp',
  'V바 랫 풀다운': 'assets/gif/261613-7a28cb_360.webp',
  '인버티드 풀업': 'assets/gif/261613-7a28cb_360.webp',
  '랫 풀다운': 'assets/gif/497413-7a28cb_360.webp',
  '풀업': 'assets/gif/067813-7a28cb_360.webp',
  '머슬업': 'assets/gif/140113-7a28cb_360.webp',
  '친업': 'assets/gif/132613-7a28cb_360.webp',
  '리버스그립 랫 풀다운': 'assets/gif/512313-7a28cb_360.webp',
  '리버스그립 풀다운': 'assets/gif/512313-7a28cb_360.webp',
  'V바 풀업': 'assets/gif/547313-7a28cb_360.webp',
  '와이드그립 랫 풀다운': 'assets/gif/019713-7a28cb_360.webp',
  '케이블 스트레이트 암 풀다운': 'assets/gif/603613-7a28cb_360.webp',
  '벤트 오버 얼터네이팅 덤벨 로우': 'assets/gif/483713-7a28cb_360.webp',
  '벤트 오버 바벨 로우': 'assets/gif/002713-7a28cb_360.webp',
  'T바 로우': 'assets/gif/320013-7a28cb_360.webp',
  '펜들레이 로우': 'assets/gif/301713-7a28cb_360.webp',
  '벤트 오버 덤벨 로우': 'assets/gif/029313-7a28cb_360.webp',
  '벤트 오버 해머 덤벨 로우': 'assets/gif/029313-7a28cb_360.webp',
  '벤트 오버 롱 바벨 로우': 'assets/gif/058913-7a28cb_360.webp',
  '벤트 오버 리버스그립 바벨 로우': 'assets/gif/011813-7a28cb_360.webp',
  '벤트 오버 싱글 암 롱 바벨 로우': 'assets/gif/006413-7a28cb_360.webp',
  '머신 로우': 'assets/gif/135013-7a28cb_360.webp',
  '머신 로우 로우': 'assets/gif/421413-7a28cb_360.webp',
  '머신 하이 로우': 'assets/gif/058113-7a28cb_360.webp',
  '리버스 인클라인 덤벨 로우': 'assets/gif/133113-7a28cb_360.webp',
  '로프 케이블 로우': 'assets/gif/436813-7a28cb_360.webp',
  '인클라인 덤벨 로우': 'assets/gif/032713-7a28cb_360.webp',
  '시티드 케이블 로우': 'assets/gif/555313-7a28cb_360.webp',
  '싱글 암 케이블 로우': 'assets/gif/021413-7a28cb_360.webp',
  '싱글 암 덤벨 로우': 'assets/gif/483713-7a28cb_360.webp',
  '싱글 암 랫 풀다운': 'assets/gif/120413-7a28cb_360.webp',
  '스탠딩 케이블 로우': 'assets/gif/509013-7a28cb_360.webp',
  '스탠딩 싱글암 케이블 로우': 'assets/gif/121213-7a28cb_360.webp',
  '덤벨 슈러그': 'assets/gif/040613-7a28cb_360.webp',
  '바벨 슈러그': 'assets/gif/009513-7a28cb_360.webp',
  '덤벨 컬': 'assets/gif/041613-7a28cb_360.webp',
  '해머 컬': 'assets/gif/031213-7a28cb_360.webp',
  '바벨 컬': 'assets/gif/011313-7a28cb_360.webp',
  '케이블 컬': 'assets/gif/163213-7a28cb_360.webp',
  '컨센트레이션 덤벨 컬': 'assets/gif/029713-7a28cb_360.webp',
  '크로스 바디 해머 컬': 'assets/gif/029813-7a28cb_360.webp',
  ' 얼터네이팅 덤벨 컬': 'assets/gif/028513-7a28cb_360.webp',
  'EZ바 컬': 'assets/gif/274113-7a28cb_360.webp',
  "' 얼터네이팅 해머 컬':'assets/gif/164813-7a28cb_360.webp',"
      '인클라인 얼터네이팅 덤벨 컬': 'assets/gif/368213-7a28cb_360.webp',
  '인클라인 얼터네이팅 해머 컬': 'assets/gif/123313-7a28cb_360.webp',
  '인클라인 덤벨 컬': 'assets/gif/031713-7a28cb_360.webp',
  '인클라인 해머 컬': 'assets/gif/032013-7a28cb_360.webp',
  '케이블 컬(무릎)': 'assets/gif/529713-7a28cb_360.webp',
  '라잉 케이블 컬': 'assets/gif/239613-7a28cb_360.webp',
  '라잉 하이 케이블 컬': 'assets/gif/018213-7a28cb_360.webp',
  '머신 컬': 'assets/gif/433613-7a28cb_360.webp',
  '오버헤드 더블 바이셉스 케이블 컬': 'assets/gif/163613-7a28cb_360.webp',
  '오버헤드 로프 케이블 컬': 'assets/gif/306813-7a28cb_360.webp',
  '프리쳐 바벨 컬': 'assets/gif/701213-7a28cb_360.webp',
  '프리쳐 케이블 컬': 'assets/gif/019513-7a28cb_360.webp',
  '프리쳐 덤벨 컬': 'assets/gif/040213-7a28cb_360.webp',
  '프리쳐 EZ바 컬': 'assets/gif/640613-7a28cb_360.webp',
  '프리쳐 해머 덤벨 컬': 'assets/gif/592113-7a28cb_360.webp',
  '프리쳐 싱글 암 덤벨 컬': 'assets/gif/529813-7a28cb_360.webp',
  '리버스 컬': 'assets/gif/042913-7a28cb_360.webp',
  '로프 케이블 컬': 'assets/gif/016513-7a28cb_360.webp',
  '시티드 얼터네이팅 컬': 'assets/gif/165013-7a28cb_360.webp',
  '시티드 얼터네이팅 해머 컬': 'assets/gif/164813-7a28cb_360.webp',
  '시티드 덤벨 컬': 'assets/gif/167713-7a28cb_360.webp',
  '시티드 해머 컬': 'assets/gif/167813-7a28cb_360.webp',
  '싱글 암 케이블 컬': 'assets/gif/265613-7a28cb_360.webp',
  '싱글 암 덤벨 컬(인클라인 벤치)': 'assets/gif/031813-7a28cb_360.webp',
  '덤벨 스파이더 컬': 'assets/gif/396313-7a28cb_360.webp',
  '바벨 스파이더 컬': 'assets/gif/162813-7a28cb_360.webp',
  '바벨 카프 레이즈': 'assets/gif/010813-7a28cb_360.webp',
  '카프 프레스': 'assets/gif/073813-7a28cb_360.webp',
  '스탠딩 카프 레이즈': 'assets/gif/476013-7a28cb_360.webp',
  '덤벨 카프 레이즈': 'assets/gif/041713-7a28cb_360.webp',
  '싱글 레그 카프 프레스': 'assets/gif/139213-7a28cb_360.webp',
  '싱글 레그 덤벨 카프 레이즈': 'assets/gif/117813-7a28cb_360.webp',
  '스미스 카프 레이즈': 'assets/gif/116413-7a28cb_360.webp',
  '시티드 카프 레이즈': 'assets/gif/059413-7a28cb_360.webp',
  '시티드 싱글-레그 카프 레이즈': 'assets/gif/121613-7a28cb_360.webp',
  '얼터네이팅 덤벨 벤치 프레스': 'assets/gif/418413-7a28cb_360.webp',
  '바벨 벤치 프레스': 'assets/gif/002513-7a28cb_360.webp',
  '디클라인 바벨 벤치 프레스': 'assets/gif/003313-7a28cb_360.webp',
  '체스트 프레스': 'assets/gif/057613-7a28cb_360.webp',
  '인클라인 체스트 프레스': 'assets/gif/129913-7a28cb_360.webp',
  '디클라인 체스트 프레스': 'assets/gif/130013-7a28cb_360.webp',
  '디클라인 덤벨 벤치 프레스': 'assets/gif/030113-7a28cb_360.webp',
  '디클라인 스미스 머신 벤치 프레스': 'assets/gif/075313-7a28cb_360.webp',
  '덤벨 벤치 프레스': 'assets/gif/028913-7a28cb_360.webp',
  '덤벨 푸쉬업': 'assets/gif/127413-7a28cb_360.webp',
  '엘레베이티드 푸쉬업': 'assets/gif/563713-7a28cb_360.webp',
  '인클라인 얼터네이팅 덤벨 벤치 프레스': 'assets/gif/354513-7a28cb_360.webp',
  '인클라인 바벨 벤치 프레스': 'assets/gif/004713-7a28cb_360.webp',
  '인클라인 덤벨 벤치 프레스': 'assets/gif/031413-7a28cb_360.webp',
  '인클라인 해머 덤벨 벤치 프레스': 'assets/gif/032113-7a28cb_360.webp',
  '인클라인 싱글 암 덤벨 벤치 프레스': 'assets/gif/128913-7a28cb_360.webp',
  '인클라인 스미스 머신 벤치 프레스': 'assets/gif/075713-7a28cb_360.webp',
  '인클라인 트위스팅 덤벨 벤치 프레스': 'assets/gif/621813-7a28cb_360.webp',
  '푸쉬업(무릎)': 'assets/gif/321113-7a28cb_360.webp',
  '머신 벤치 프레스': 'assets/gif/104113-7a28cb_360.webp',
  '크로스오버 푸쉬업(메디신 볼)': 'assets/gif/066313-7a28cb_360.webp',
  '푸쉬업': 'assets/gif/066213-7a28cb_360.webp',
  '싱글 암 덤벨 벤치 프레스': 'assets/gif/333313-7a28cb_360.webp',
  '스미스 머신 벤치 프레스': 'assets/gif/074813-7a28cb_360.webp',
  '트위스팅 덤벨 벤치 프레스': 'assets/gif/121413-7a28cb_360.webp',
  '와이드그립 푸쉬업': 'assets/gif/131113-7a28cb_360.webp',
  '클로즈그립 푸쉬업': 'assets/gif/025913-7a28cb_360.webp',
  '케이블 크로스오버': 'assets/gif/126913-7a28cb_360.webp',
  '벤치 푸쉬업': 'assets/gif/563713-7a28cb_360.webp',
  '케이블 플라이': 'assets/gif/022713-7a28cb_360.webp',
  '디클라인 덤벨 플라이': 'assets/gif/030213-7a28cb_360.webp',
  '덤벨 플라이': 'assets/gif/030813-7a28cb_360.webp',
  '하이 케이블 크로스 오버': 'assets/gif/127013-7a28cb_360.webp',
  '인클라인 케이블 플라이': 'assets/gif/017113-7a28cb_360.webp',
  '인클라인 덤벨 플라이': 'assets/gif/031913-7a28cb_360.webp',
  '인클라인 트위스팅 덤벨 플라이': 'assets/gif/033113-7a28cb_360.webp',
  '로우 케이블 크로스 오버': 'assets/gif/015513-7a28cb_360.webp',
  '덤벨 풀오버': 'assets/gif/037513-7a28cb_360.webp',
  '체스트 플라이': 'assets/gif/059613-7a28cb_360.webp',
  '벤트 니 싱글 레그 힙 리프트': 'assets/gif/404413-7a28cb_360.webp',
  '힙 리프트(발높여서)': 'assets/gif/352313-7a28cb_360.webp',
  '싱글 레그 힙 리프트(발높여서)': 'assets/gif/343513-7a28cb_360.webp',
  '힙 리프트': 'assets/gif/301313-7a28cb_360.webp',
  '싱글 레그 힙 리프트': 'assets/gif/600013-7a28cb_360.webp',
  '바벨 데드리프트': 'assets/gif/003213-7a28cb_360.webp',
  '덤벨 데드리프트': 'assets/gif/030013-7a28cb_360.webp',
  '바벨 루마니안 데드리프트': 'assets/gif/008513-7a28cb_360.webp',
  '바벨 스티프 레그 데드리프트': 'assets/gif/011613-7a28cb_360.webp',
  '바벨 스모 데드리프트': 'assets/gif/011713-7a28cb_360.webp',
  '스미스 머신 데드리프트': 'assets/gif/075213-7a28cb_360.webp',
  '레그 컬': 'assets/gif/434713-7a28cb_360.webp',
  '라잉 알터네이팅 레그 컬': 'assets/gif/058213-7a28cb_360.webp',
  '라잉 레그 컬': 'assets/gif/058613-7a28cb_360.webp',
  '라잉 싱글 레그 컬': 'assets/gif/159013-7a28cb_360.webp',
  '시티드 레그 컬': 'assets/gif/059913-7a28cb_360.webp',
  '바벨 대각선 런지': 'assets/gif/141013-7a28cb_360.webp',
  '바벨 핵 스쿼트': 'assets/gif/004613-7a28cb_360.webp',
  '바벨 프론트 스쿼트': 'assets/gif/002913-7a28cb_360.webp',
  '바벨 런지': 'assets/gif/005413-7a28cb_360.webp',
  '바벨 리버스 런지': 'assets/gif/007813-7a28cb_360.webp',
  '바벨 사이드 런지': 'assets/gif/141013-7a28cb_360.webp',
  '바벨 스플릿 스쿼트': 'assets/gif/303013-7a28cb_360.webp',
  '바벨 스쿼트': 'assets/gif/143613-7a28cb_360.webp',
  '바벨 스텝 업': 'assets/gif/011413-7a28cb_360.webp',
  '바벨 워킹 런지': 'assets/gif/440913-7a28cb_360.webp',
  '대각선 런지': 'assets/gif/455213-7a28cb_360.webp',
  '덤벨 대각선 런지': 'assets/gif/363513-7a28cb_360.webp',
  '덤벨 런지': 'assets/gif/033613-7a28cb_360.webp',
  '덤벨 리버스 런지': 'assets/gif/038113-7a28cb_360.webp',
  '덤벨 사이드 런지': 'assets/gif/344813-7a28cb_360.webp',
  '덤벨 스플릿 스쿼트': 'assets/gif/041013-7a28cb_360.webp',
  '덤벨 스쿼트': 'assets/gif/155513-7a28cb_360.webp',
  '덤벨 스텝 업': 'assets/gif/043113-7a28cb_360.webp',
  '덤벨 워킹 런지': 'assets/gif/155713-7a28cb_360.webp',
  '포워드 런지': 'assets/gif/347013-7a28cb_360.webp',
  '레터럴 바벨 스쿼트': 'assets/gif/009813-7a28cb_360.webp',
  '레터럴 바벨 스텝 업': 'assets/gif/088413-7a28cb_360.webp',
  '레터럴 스쿼트': 'assets/gif/478813-7a28cb_360.webp',
  '레터럴 스텝 업': 'assets/gif/515413-7a28cb_360.webp',
  '레그 프레스': 'assets/gif/226713-7a28cb_360.webp',
  '파워 레그 프레스': 'assets/gif/073913-7a28cb_360.webp',
  '런지': 'assets/gif/400013-7a28cb_360.webp',
  '라잉 머신 스쿼트': 'assets/gif/074413-7a28cb_360.webp',
  '머신 핵 스쿼트': 'assets/gif/199213-7a28cb_360.webp',
  '리버스 런지': 'assets/gif/158113-7a28cb_360.webp',
  '싱글 암 바벨 사이드 스쿼트': 'assets/gif/006613-7a28cb_360.webp',
  '싱글 암 덤벨 사이드 스쿼트': 'assets/gif/041113-7a28cb_360.webp',
  '싱글 레그 바벨 스쿼트': 'assets/gif/006813-7a28cb_360.webp',
  '싱글 레그 박스 스쿼트': 'assets/gif/349313-7a28cb_360.webp',
  '싱글 레그 덤벨 박스 스쿼트': 'assets/gif/376713-7a28cb_360.webp',
  '싱글 레그 덤벨 스쿼트': 'assets/gif/376713-7a28cb_360.webp',
  '싱글 레그 스쿼트': 'assets/gif/175913-7a28cb_360.webp',
  '스미스 머신 스쿼트': 'assets/gif/328113-7a28cb_360.webp',
  '스플릿 스쿼트': 'assets/gif/353313-7a28cb_360.webp',
  '스텝 업': 'assets/gif/457913-7a28cb_360.webp',
  '워킹 런지': 'assets/gif/146013-7a28cb_360.webp',
  '알터네이팅 레그 익스텐션': 'assets/gif/187413-7a28cb_360.webp',
  '레그 익스텐션': 'assets/gif/058513-7a28cb_360.webp',
  '싱글 레그 익스텐션': 'assets/gif/157113-7a28cb_360.webp',
  '알터네이팅 슈퍼맨': 'assets/gif/471513-7a28cb_360.webp',
  '백 익스텐션': 'assets/gif/476213-7a28cb_360.webp',
  '슈퍼맨': 'assets/gif/343613-7a28cb_360.webp',
  '슈퍼맨 홀드': 'assets/gif/348313-7a28cb_360.webp',
  '아놀드 덤벨 프레스': 'assets/gif/410813-7a28cb_360.webp',
  '바벨 숄더 프레스': 'assets/gif/532813-7a28cb_360.webp',
  '덤벨 얼터네디팅 숄더 프레스': 'assets/gif/397213-7a28cb_360.webp',
  '바벨 업라이트 로우': 'assets/gif/563213-7a28cb_360.webp',
  '덤벨 업라이트 로우': 'assets/gif/176513-7a28cb_360.webp',
  '케이블 업라이트 로우': 'assets/gif/024613-7a28cb_360.webp',
  '덤벨 숄더 프레스': 'assets/gif/040513-7a28cb_360.webp',
  '머신 숄더 프레스': 'assets/gif/145413-7a28cb_360.webp',
  '싱글 암 덤벨 숄더 프레스': 'assets/gif/036113-7a28cb_360.webp',
  '스미스 머신 숄더 프레스': 'assets/gif/077413-7a28cb_360.webp',
  '바벨 프론트 레이즈': 'assets/gif/004113-7a28cb_360.webp',
  '벤트 오버 케이블 리어 델트 레이즈': 'assets/gif/391213-7a28cb_360.webp',
  '벤트 오버 덤벨 리어 델트 레이즈': 'assets/gif/038013-7a28cb_360.webp',
  '케이블 프론트 레이즈': 'assets/gif/016213-7a28cb_360.webp',
  '케이블 래터럴 레이즈': 'assets/gif/017813-7a28cb_360.webp',
  '덤벨 사이드 래터럴 레이즈': 'assets/gif/563113-7a28cb_360.webp',
  '덤벨 프론트 래터럴 레이즈': 'assets/gif/031013-7a28cb_360.webp',
  '프론트 플레이트 레이즈': 'assets/gif/083413-7a28cb_360.webp',
  '라잉 덤벨 익스터널 로테이션': 'assets/gif/086313-7a28cb_360.webp',
  '라잉 덤벨 리어 델트 레이즈': 'assets/gif/034813-7a28cb_360.webp',
  '라잉 싱글 암 덤벨 리어 델트 레이즈': 'assets/gif/034113-7a28cb_360.webp',
  '리어 델트 플라이': 'assets/gif/394313-7a28cb_360.webp',
  '인클라인 덤벨 리어 델트 레이즈': 'assets/gif/032613-7a28cb_360.webp',
  '시티드 덤벨 리어 델트 레이즈': 'assets/gif/423513-7a28cb_360.webp',
  '싱글 암 케이블 래터럴 레이즈': 'assets/gif/019213-7a28cb_360.webp',
  '케이블 익스터널 로테이션': 'assets/gif/023512-7a28cb_360.webp',
  '클로즈그립 벤치 프레스': 'assets/gif/003013-7a28cb_360.webp',
  '케이블 로프 페이스 풀': 'assets/gif/565613-7a28cb_360.webp',
  '어시스티드 딥스': 'assets/gif/236413-7a28cb_360.webp',
  '벤치 딥스': 'assets/gif/139913-7a28cb_360.webp',
  '다이아몬드 푸쉬업': 'assets/gif/028313-7a28cb_360.webp',
  '딥스': 'assets/gif/025113-7a28cb_360.webp',
  '머신 딥스': 'assets/gif/187113-7a28cb_360.webp',
  '디클라인 덤벨 트라이셉스 익스텐션': 'assets/gif/030613-7a28cb_360.webp',
  '디클라인 EZ바 트라이셉스 익스텐션': 'assets/gif/218613-7a28cb_360.webp',
  '덤벨 킥 백': 'assets/gif/174113-7a28cb_360.webp',
  '인클라인 EZ바 트라이셉스 익스텐션': 'assets/gif/044913-7a28cb_360.webp',
  '케이블 트라이셉스 익스텐션(무릎)': 'assets/gif/185913-7a28cb_360.webp',
  '리닝 오버헤드 트라이셉스 익스텐션': 'assets/gif/172413-7a28cb_360.webp',
  '라잉 케이블 트라이셉스 익스텐션': 'assets/gif/524313-7a28cb_360.webp',
  '라잉 EZ바 트라이셉스 익스텐션': 'assets/gif/174813-7a28cb_360.webp',
  '라잉 싱글 덤벨 트라이셉 익스텐션': 'assets/gif/173513-7a28cb_360.webp',
  '라잉 싱글 암 덤벨 트라이셉 익스텐션': 'assets/gif/034613-7a28cb_360.webp',
  '라잉 트라이셉스 익스텐션': 'assets/gif/006113-7a28cb_360.webp',
  '오버헤드 덤벨 트라이셉스 익스텐션': 'assets/gif/218913-7a28cb_360.webp',
  '오버헤드 EZ바 트라이셉스 익스텐션': 'assets/gif/045313-7a28cb_360.webp',
  '오버헤드 로프 케이블 트라이셉스 익스텐션': 'assets/gif/019413-7a28cb_360.webp',
  '오버헤드 싱글 덤벨 트라이셉 익스텐션': 'assets/gif/218813-7a28cb_360.webp',
  '오버헤드 싱글 암 케이블 트라이셉 익스텐션': 'assets/gif/495813-7a28cb_360.webp',
  '오버헤드 싱글 암 덤벨 트라이셉 익스텐션': 'assets/gif/615813-7a28cb_360.webp',
  '리버스 트라이셉스 푸쉬다운': 'assets/gif/020713-7a28cb_360.webp',
  '로프 트라이셉스 푸쉬다운': 'assets/gif/020013-7a28cb_360.webp',
  '싱글 암 트라이셉 푸쉬다운': 'assets/gif/172313-7a28cb_360.webp',
  '트라이셉스 익스텐션': 'assets/gif/218813-7a28cb_360.webp',
  '트라이셉스 푸쉬다운': 'assets/gif/020113-7a28cb_360.webp',
  'V바 트라이셉스 푸쉬다운': 'assets/gif/435513-7a28cb_360.webp',
  '힙 어브덕션': 'assets/gif/059713-7a28cb_360.webp',
  '힙 어뎍션': 'assets/gif/059813-7a28cb_360.webp',
  '바벨 힙 쓰러스트': 'assets/gif/106013-7a28cb_360.webp',
  '러닝': 'assets/gif/068413-7a28cb_360.webp',
  '사이클링': 'assets/gif/213813-7a28cb_360.webp',
  '플랭크': 'assets/gif/235813-7a28cb_360.webp',
  '로잉': 'assets/gif/116113-7a28cb_360.webp',
  '스텝 머신': 'assets/gif/231113-7a28cb_360.webp',
};