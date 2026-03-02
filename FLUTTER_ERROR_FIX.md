# Flutter/Dart 오류 해결 가이드

## 🔴 발생한 오류

1. **Dart Analysis Server 연결 실패**
   - "Dart Analysis Server client: couldn't create connection to server"
   - "The Dart Analyzer has terminated"

2. **Flutter pub upgrade 실패**
   - "Error (-1073740791): Unable to 'pub upgrade' flutter tool"
   - 계속 재시도 중

## ✅ 해결 방법 (단계별)

### 1단계: 실행 중인 프로세스 취소 및 IDE 재시작

1. **현재 실행 중인 작업 취소**
   - 터미널/콘솔에서 "Cancel" 버튼 클릭
   - 또는 `Ctrl + C`로 중단

2. **IDE (Cursor) 완전 종료**
   - 모든 Cursor 창 닫기
   - 작업 관리자에서 `Cursor.exe` 프로세스가 완전히 종료되었는지 확인

3. **IDE 재시작**

### 2단계: Flutter 캐시 정리

터미널에서 다음 명령어들을 순서대로 실행:

```bash
# Flutter 캐시 정리
flutter clean

# Flutter 도구 재설치
flutter pub cache repair

# Flutter 버전 확인
flutter --version
```

### 3단계: 프로젝트 의존성 재설치

프로젝트 디렉토리에서:

```bash
# 프로젝트 디렉토리로 이동
cd m:\MyProject777\test009AICHURCH

# 기존 빌드 파일 삭제
flutter clean

# 의존성 재설치
flutter pub get
```

### 4단계: Dart SDK 확인 및 재설정

```bash
# Dart SDK 경로 확인
dart --version

# Flutter doctor로 전체 상태 확인
flutter doctor -v
```

### 5단계: IDE 설정 재설정

1. **Cursor 설정 열기**
   - `Ctrl + ,` (설정)
   - 또는 `File` > `Preferences` > `Settings`

2. **Dart 확장 확인**
   - 확장 프로그램에서 "Dart" 확장이 설치되어 있는지 확인
   - 필요시 재설치

3. **워크스페이스 재로드**
   - `Ctrl + Shift + P`
   - "Reload Window" 입력 후 실행

## 🔧 고급 해결 방법

### 방법 A: Flutter SDK 재설치

만약 위 방법들이 작동하지 않으면:

```bash
# Flutter SDK 경로 확인
flutter doctor -v

# Flutter 업그레이드
flutter upgrade

# Flutter 채널 확인 및 변경 (안정 버전 사용)
flutter channel stable
flutter upgrade
```

### 방법 B: 환경 변수 확인

Windows 환경 변수에서:

1. `FLUTTER_ROOT` 경로 확인
2. `PATH`에 Flutter bin 디렉토리가 포함되어 있는지 확인
3. 필요시 재설정

### 방법 C: 프로젝트 재생성 (최후의 수단)

만약 모든 방법이 실패하면:

1. **프로젝트 백업**
   ```bash
   # lib 폴더와 pubspec.yaml 백업
   ```

2. **새 프로젝트 생성**
   ```bash
   flutter create new_project
   ```

3. **기존 코드 복원**
   - 백업한 `lib` 폴더 복사
   - `pubspec.yaml` 의존성 복사

## 📋 빠른 체크리스트

- [ ] 실행 중인 프로세스 취소
- [ ] IDE 완전 재시작
- [ ] `flutter clean` 실행
- [ ] `flutter pub get` 실행
- [ ] `flutter doctor -v`로 상태 확인
- [ ] IDE 워크스페이스 재로드

## 💡 예방 방법

1. **정기적인 Flutter 업데이트**
   ```bash
   flutter upgrade
   ```

2. **의존성 정기 정리**
   ```bash
   flutter pub cache repair
   ```

3. **프로젝트 정기 정리**
   ```bash
   flutter clean
   flutter pub get
   ```

## 🆘 여전히 해결되지 않으면

1. **에러 로그 전체 확인**
   - "Go to output" 버튼 클릭
   - 전체 에러 메시지 확인

2. **GitHub 이슈 리포트**
   - Dart Analyzer 종료 오류의 경우 GitHub에 이슈 리포트

3. **Flutter 커뮤니티 도움 요청**
   - Flutter Discord 또는 Stack Overflow
