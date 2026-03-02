# Supabase 보안 오류 해결 가이드

## 🔒 문제 상황

Supabase 보안 고문에서 다음 오류가 보고되었습니다:
- **2개의 오류**: `public.daily_worship`와 `public.bible_verses` 테이블에 RLS(Row Level Security)가 활성화되지 않음
- **3가지 경고**: 추가 보안 경고

## ✅ 해결 방법

### 1단계: Supabase SQL 에디터 열기

1. Supabase 대시보드에 로그인
2. 왼쪽 사이드바에서 **"SQL Editor"** 클릭
3. **"New query"** 버튼 클릭

### 2단계: SQL 스크립트 실행

1. `supabase_rls_fix.sql` 파일의 내용을 복사
2. SQL 에디터에 붙여넣기
3. **"Run"** 버튼 클릭하여 실행

### 3단계: 결과 확인

1. SQL 실행이 성공적으로 완료되었는지 확인
2. Supabase 대시보드에서 **"보안 고문" (Security Advisor)** 페이지로 이동
3. 하단의 **"재런 린터" (Rerun Linter)** 버튼 클릭
4. 오류가 해결되었는지 확인

## 📋 설정된 보안 정책

### `daily_worship` 테이블
- ✅ **SELECT**: 모든 사용자 (인증 불필요) - 공개 콘텐츠이므로
- ✅ **INSERT/UPDATE/DELETE**: 인증된 사용자만

### `bible_verses` 테이블
- ✅ **SELECT**: 모든 사용자 (인증 불필요) - 공개 콘텐츠이므로
- ✅ **INSERT/UPDATE/DELETE**: 인증된 사용자만

### `profiles` 테이블
- ✅ **SELECT/UPDATE**: 사용자는 자신의 프로필만 접근 가능

### `saved_sermons` 테이블
- ✅ **SELECT/INSERT/UPDATE/DELETE**: 사용자는 자신이 저장한 설교만 접근 가능

## 🔍 추가 확인 사항

만약 경고가 계속 나타난다면:

1. **다른 테이블 확인**: Supabase 대시보드에서 "Table Editor"로 이동하여 다른 테이블들도 RLS가 활성화되어 있는지 확인
2. **정책 확인**: "Authentication" > "Policies"에서 각 테이블의 정책이 올바르게 설정되었는지 확인
3. **에러 로그 확인**: SQL 실행 시 에러가 발생했다면 에러 메시지를 확인하고 필요시 수정

## 💡 참고사항

- RLS를 활성화하면 테이블의 모든 행에 대해 기본적으로 접근이 차단됩니다
- 명시적인 정책(Policy)을 생성해야만 데이터에 접근할 수 있습니다
- `USING (true)`는 모든 행에 대해 정책을 적용한다는 의미입니다
- `auth.uid()`는 현재 로그인한 사용자의 ID를 반환합니다

## 🚨 주의사항

- 이 스크립트는 기존 정책이 없는 경우에만 생성합니다
- 이미 정책이 존재하는 테이블은 건너뜁니다
- 프로덕션 환경에서 실행하기 전에 테스트 환경에서 먼저 확인하세요
