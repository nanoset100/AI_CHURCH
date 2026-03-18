import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const authHeader = req.headers.get('Authorization')
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '', // 사용량 업데이트를 위해 서비스 롤 키 사용
      { global: { headers: { Authorization: authHeader } } }
    )

    // 실제 요청한 유저 정보 가져오기 (JWT 필수)
    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) throw new Error('인증되지 않은 유저입니다.')

    // --- [추가 코드] 사용량 체크 (하루 5회 제한 예시) ---
    // RPC 호출 (check_and_increment_ai_usage)
    const { data: isAllowed, error: rpcError } = await supabaseClient.rpc('check_and_increment_ai_usage', {
      user_id: user.id,
      max_limit: 5 // 여기에 하루 최대 생성 가능 횟수를 설정하세요
    })

    if (rpcError) throw new Error('사용량 확인 중 서버 오류가 발생했습니다.')
    if (!isAllowed) {
      return new Response(JSON.stringify({ error: '오늘 생성 한도를 초과했습니다. (하루 5회)' }), {
        status: 429, // Too Many Requests
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    // ----------------------------------------------

    const { topic, situation, length, tone, keyword } = await req.json()
    const openAiApiKey = Deno.env.get('OPENAI_API_KEY')

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: { 
        'Authorization': `Bearer ${openAiApiKey}`, 
        'Content-Type': 'application/json' 
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { 
            role: 'system', 
            content: '당신은 한국의 따뜻하고 영성 깊은 목사님입니다. 성도들의 상황과 고민을 듣고, 성경 말씀에 기반하여 따뜻한 위로와 소망을 주는 맞춤형 설교/권면의 편지를 작성합니다. 응답 형식(JSON)은 반드시 {"title": "제목", "verse": "성경구절", "content": "본문"} 이어야 합니다.' 
          },
          { 
            role: 'user', 
            content: `주제: ${topic}\n상황: ${situation ?? '없음'}\n길이: ${length}\n말투: ${tone}\n추가 키워드: ${keyword ?? '없음'}` 
          },
        ],
        temperature: 0.7,
      }),
    })

    const data = await response.json()
    return new Response(JSON.stringify(data.choices[0].message.content), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { 
      status: 400, 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    })
  }
})
