# AI 가나안교회 앱 - 구글 콘솔 등록 가이드

앱 용도에 따라 **Google Cloud Console**과 **Google Play Console** 중에서 선택합니다.

---

## 1. Google Cloud Console (API·OAuth·Firebase용)

**용도:** Google 로그인, 지도, Firebase, 기타 Google API 사용 시 필요

### 1단계: 프로젝트 만들기

1. **Google Cloud Console** 접속  
   https://console.cloud.google.com/

2. 상단 프로젝트 선택 → **"새 프로젝트"** 클릭

3. 프로젝트 정보 입력  
   - **프로젝트 이름:** `AI 가나안교회` (또는 원하는 이름)  
   - **위치:** 조직이 있으면 선택, 없으면 "조직 없음"  
   - **만들기** 클릭

### 2단계: OAuth 동의 화면 설정 (Google 로그인 사용 시)

1. 왼쪽 메뉴 **"API 및 서비스"** → **"OAuth 동의 화면"**

2. **User Type**  
   - 테스트만: **"외부"** → 테스트 사용자 추가  
   - 일반 공개: **"외부"** → 나중에 "게시 상태"로 전환

3. **앱 정보**  
   - 앱 이름: `AI 가나안교회`  
   - 사용자 지원 이메일: 본인 이메일  
   - (선택) 앱 로고, 개인정보처리방침 URL

4. **범위**  
   - Google 로그인만 쓰면 `email`, `profile`, `openid` 등 필요 범위 추가  
   - **저장 후 계속**

5. **테스트 사용자** (외부 + 테스트 모드일 때)  
   - 로그인 허용할 이메일 추가 → **저장**

### 3단계: OAuth 2.0 클라이언트 ID 만들기

1. **"API 및 서비스"** → **"사용자 인증 정보"**

2. **"+ 사용자 인증 정보 만들기"** → **"OAuth 클라이언트 ID"**

3. **애플리케이션 유형**  
   - **웹 앱** (Chrome 등): "웹 애플리케이션"  
     - 이름: `AI 가나안교회 Web`  
     - **승인된 JavaScript 원본:**  
       - `http://localhost:9871` (개발)  
       - `http://localhost:12693` (다른 포트 사용 시)  
       - 실제 도메인: `https://yourdomain.com`  
     - **승인된 리디렉션 URI:**  
       - Supabase 사용 시: Supabase 대시보드에 나온 콜백 URL  
       - 또는 `http://localhost:9871` 등

   - **Android 앱**: "Android"  
     - 패키지 이름: `com.example.ai_canaan_church` (또는 실제 패키지명)  
     - SHA-1: 터미널에서  
       ```bash
       cd android && ./gradlew signingReport
       ```  
       의 `SHA1` 값 복사

4. **만들기** → **클라이언트 ID**와 **클라이언트 보안 비밀** 복사해 안전한 곳에 보관

### 4단계: 필요한 API 사용 설정

1. **"API 및 서비스"** → **"라이브러리"**

2. 사용할 API 검색 후 **"사용"** 클릭  
   - Google 로그인: **Google+ API** 또는 **Google Identity**  
   - 지도: **Maps SDK for Android** / **Maps JavaScript API**  
   - Firebase: Firebase 프로젝트 연결 후 Firebase 콘솔에서 설정

---

## 2. Google Play Console (Android 앱 스토어 출시용)

**용도:** 앱을 Google Play 스토어에 올릴 때만 필요

### 1단계: 개발자 등록

1. **Google Play Console** 접속  
   https://play.google.com/console/

2. **개발자 계정**  
   - 한 번만 등록 (약 $25, 계정 생성 비용)  
   - 약관 동의 후 결제

### 2단계: 앱 만들기

1. **"앱 만들기"** 클릭

2. **앱 정보**  
   - 앱 이름: `AI 가나안교회`  
   - 기본 언어: 한국어  
   - 앱/게임: **앱**  
   - 무료/유료: 선택

3. **정책 동의**  
   - 개인정보처리방침, 미국 수출 규정 등 체크

### 3단계: Flutter 앱 준비

1. **앱 서명**  
   - Play App Signing 사용 권장  
   - 업로드용 키스토어 생성:
     ```bash
     keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
     ```

2. **android/app/build.gradle**  
   - `applicationId`: 고유 패키지명 (예: `com.yourcompany.ai_canaan_church`)  
   - `versionCode`, `versionName` 설정

3. **AAB 빌드**  
   ```bash
   flutter build appbundle
   ```  
   출력: `build/app/outputs/bundle/release/app-release.aab`

### 4단계: Play Console에 앱 올리기

1. **"앱 릴리스"** → **"프로덕션"** (또는 내부 테스트)

2. **"새 버전 만들기"**  
   - `app-release.aab` 업로드  
   - 버전 이름, 릴리스 노트 입력

3. **스토어 등록정보**  
   - 앱 이름, 짧은 설명, 전체 설명  
   - 스크린샷(필수), 아이콘, 기능 그래픽 등

4. **콘텐츠 등급**, **대상 그룹**, **개인정보처리방침** 등 입력 후 제출

---

## 3. 요약

| 목적                     | 사용할 콘솔           |
|--------------------------|------------------------|
| Google 로그인, API 사용  | **Google Cloud Console** |
| Play 스토어에 앱 출시    | **Google Play Console**  |

- **Google 로그인만** 쓰려면: Google Cloud Console에서 OAuth 동의 화면 + OAuth 클라이언트 ID만 하면 됩니다.  
- **스토어 출시만** 하려면: Google Play Console 가이드만 따라하면 됩니다.  
- 둘 다 하려면: 1번으로 앱 등록·OAuth 설정 후, 2번으로 빌드·업로드하면 됩니다.

필요한 단계만 골라서 진행하시면 됩니다.
