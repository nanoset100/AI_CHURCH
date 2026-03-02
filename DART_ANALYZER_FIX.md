# Dart Analyzer 오류 해결 가이드

## 🔴 문제 상황
- "Dart Analysis Server client: couldn't create connection to server"
- "The Dart Analyzer has terminated"

## ✅ 해결 방법 (순서대로 시도)

### 방법 1: IDE 재시작 (가장 간단)
1. Cursor/VS Code 완전히 종료
2. 다시 실행
3. 프로젝트 열기

### 방법 2: Dart Analysis Server 재시작
1. **Command Palette** 열기:
   - Windows/Linux: `Ctrl + Shift + P`
   - Mac: `Cmd + Shift + P`
2. 다음 명령어 입력 및 실행:
   ```
   Dart: Restart Analysis Server
   ```

### 방법 3: Flutter/Dart 캐시 정리
터미널에서 다음 명령어 실행:

```bash
# Flutter 캐시 정리
flutter clean

# pub 캐시 정리
flutter pub cache repair

# 의존성 다시 설치
flutter pub get
```

### 방법 4: Dart SDK 경로 확인
1. Command Palette (`Ctrl + Shift + P`)
2. `Dart: Change SDK` 실행
3. 올바른 Flutter SDK 경로 선택

### 방법 5: IDE 확장 프로그램 확인
1. 확장 프로그램 탭 열기 (`Ctrl + Shift + X`)
2. "Dart" 확장 프로그램 확인
3. 비활성화 → 재시작 → 활성화

### 방법 6: 프로젝트 재로드
1. Command Palette (`Ctrl + Shift + P`)
2. `Developer: Reload Window` 실행

### 방법 7: 완전 초기화 (최후의 수단)
```bash
# 프로젝트 디렉토리에서
flutter clean
rm -rf .dart_tool
rm -rf build
flutter pub get
```

그 다음 IDE 완전히 재시작

## 🔍 추가 확인 사항

### Flutter/Dart 설치 확인
```bash
flutter doctor
```

모든 항목이 체크되어 있는지 확인

### IDE 출력 로그 확인
1. "Go to output" 버튼 클릭
2. 오류 메시지 확인
3. 필요시 GitHub에 이슈 리포트

## 💡 예방 방법

1. **정기적인 업데이트**: Flutter와 Dart 확장 프로그램을 최신 버전으로 유지
2. **충분한 메모리**: Dart Analyzer는 메모리를 많이 사용하므로 시스템 리소스 확인
3. **대용량 파일 제외**: `.dart_tool`, `build` 폴더를 `.gitignore`에 추가

## 🚨 여전히 해결되지 않으면

1. IDE 출력 로그의 전체 오류 메시지 복사
2. GitHub 이슈 리포트 작성
3. 또는 Flutter 커뮤니티에 문의
