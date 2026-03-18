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

    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) throw new Error('인증되지 않은 유저입니다.')

    // --- [추가 코드] 사용량 체크 (하루 10회 제한 예시 - 음성은 횟수를 더 넉넉히 주거나 동일하게 설정 가능) ---
    const { data: isAllowed, error: rpcError } = await supabaseClient.rpc('check_and_increment_ai_usage', {
      user_id: user.id,
      max_limit: 10 // 여기에 하루 최대 TTS 생성 가능 횟수를 설정하세요
    })

    if (rpcError) throw new Error('사용량 확인 중 서버 오류가 발생했습니다.')
    if (!isAllowed) {
      return new Response(JSON.stringify({ error: '오늘 음성 생성 한도를 초과했습니다. (하루 10회)' }), {
        status: 429,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    // ----------------------------------------------

    const { text, voice } = await req.json()
    const openAiApiKey = Deno.env.get('OPENAI_API_KEY')

    const response = await fetch('https://api.openai.com/v1/audio/speech', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openAiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'tts-1',
        input: text,
        voice: voice || 'onyx',
        response_format: 'mp3',
      }),
    })

    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(`OpenAI TTS Error: ${JSON.stringify(errorData)}`)
    }

    const audioBuffer = await response.arrayBuffer()

    return new Response(audioBuffer, {
      headers: { 
        ...corsHeaders, 
        'Content-Type': 'audio/mpeg',
      },
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
