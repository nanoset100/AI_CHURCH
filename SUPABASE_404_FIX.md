# 회원가입 404 오류 해결 가이드

## 오류 메시지
`회원가입 중 오류가 발생했습니다: Received an empty response with status code 404`

## 원인
Supabase 서버에 요청이 도달하지 못하거나, 잘못된 URL/키로 인해 404가 반환됩니다.

---

## 1단계: Supabase 대시보드에서 값 다시 복사

1. **Supabase 대시보드** 로그인 → **AI_church** 프로젝트 선택  
2. 왼쪽 메뉴 **Settings (톱니바퀴)** → **API** 클릭  
3. 아래 값을 **그대로** 복사합니다.

### Project URL
- 형식: `https://xxxxxxxxxxxx.supabase.co`
- **끝에 슬래시(/) 없이** 복사
- 예: `https://aaaxmajwtxvzzqlyyxom.supabase.co`

### Project API keys – anon public
- **anon public** 키만 사용 (service role 키 사용 금지)
- JWT 형식이면 `eyJ`로 시작하는 긴 문자열
- 새 형식이면 `sb_publishable_` 로 시작할 수 있음
- **한 줄 전체**를 복사 (앞뒤 공백 없이)

---

## 2단계: .env 파일 수정

프로젝트 루트의 `.env` 파일을 열고 아래처럼 수정합니다.

```env
# 주석은 제거하거나 그대로 두어도 됨
SUPABASE_URL=https://여기에_Project_URL_붙여넣기
SUPABASE_ANON_KEY=여기에_anon_public_키_붙여넣기
```

### 주의사항
- `SUPABASE_URL`과 `SUPABASE_ANON_KEY` **앞뒤에 공백 없이** 붙여넣기  
- 따옴표(`"` 또는 `'`) **사용하지 않기**  
- URL 끝에 `/` 없어야 함  
- 한 줄에 하나의 값만 (등호 앞뒤 공백 없어도 됨)

### 올바른 예
```env
SUPABASE_URL=https://aaaxmajwtxvzzqlyyxom.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxx...
```

### 잘못된 예
```env
SUPABASE_URL="https://xxx.supabase.co"   ← 따옴표 사용 금지
SUPABASE_URL=https://xxx.supabase.co/    ← 끝에 / 금지
SUPABASE_ANON_KEY= 키값   ← 등호 뒤 공백 금지
```

---

## 3단계: 프로젝트 일시 중지 여부 확인

Supabase 무료 플랜은 **일정 기간 미사용 시 프로젝트가 일시 중지**됩니다.

1. 대시보드 접속 시 **"Project is paused"** 메시지가 나오면  
2. **Restore project** 버튼을 눌러 프로젝트를 다시 켭니다.  
3. 복구 후 1~2분 뒤에 앱에서 다시 회원가입을 시도합니다.

---

## 4단계: Auth 사용 설정 확인

1. Supabase 대시보드 왼쪽 메뉴 **Authentication** 클릭  
2. **Providers** 탭에서 **Email** 이 켜져 있는지 확인  
3. 꺼져 있으면 **Enable** 로 켠 뒤 저장

---

## 5단계: 앱 재실행

1. 터미널에서 실행 중인 앱이 있으면 **중지** (Ctrl+C)  
2. 다시 실행:
   ```bash
   flutter run -d chrome
   ```
3. 회원가입을 다시 시도합니다.

---

## 그래도 404가 나올 때

- **브라우저 개발자 도구** (F12) → **Network** 탭에서  
  회원가입 버튼 클릭 시 어떤 URL로 요청이 가는지 확인  
- 요청 URL이 `https://xxx.supabase.co/auth/v1/...` 형태인지 확인  
- Supabase 대시보드 **Settings > API** 에서 **Project URL** 과 복사한 값이 **완전히 동일**한지 다시 확인  

위 단계를 모두 확인한 뒤에도 404가 반복되면,  
사용 중인 **Supabase 프로젝트 URL**과 **anon public 키 앞 20자 정도**(비밀 번호는 가리기)를 알려주시면 다음 원인을 더 짚어볼 수 있습니다.
