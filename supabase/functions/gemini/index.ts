import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed. Only POST is supported." }),
      {
        status: 405,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }

  try {
    const apiKey =
      Deno.env.get("AI_API_KEY") ||
      Deno.env.get("OPENAI_API_KEY") ||
      Deno.env.get("GEMINI_API_KEY");

    if (!apiKey || apiKey.trim() === "") {
      return new Response(
        JSON.stringify({
          error:
            "API key tidak dikonfigurasi. Atur AI_API_KEY pada Supabase Secrets.",
          code: "API_KEY_MISSING",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const baseUrl = (
      Deno.env.get("AI_BASE_URL") ||
      "https://generativelanguage.googleapis.com/v1beta/openai"
    ).replace(/\/+$/, "");

    const model = Deno.env.get("AI_MODEL") || "base";

    let payload: any;
    try {
      payload = await req.json();
    } catch {
      return new Response(
        JSON.stringify({ error: "Format request body tidak valid (harus JSON)." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const { action, userPrompt, conversationHistory, base64Image, mimeType } =
      payload;

    const messages: any[] = [];

    if (action === "chat") {
      if (!userPrompt || typeof userPrompt !== "string") {
        return new Response(
          JSON.stringify({ error: "userPrompt dibutuhkan untuk chat." }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      const systemPrompt = `Kamu adalah StrikeBot, asisten AI memancing cerdas, ramah, dan profesional di aplikasi Strike Log.
Karaktermu:
- Pakar angler berpengalaman di perairan Indonesia (air tawar, muara, karang, laut dalam).
- Paham taktik umpan alami (udang hidup, cacing, lumut, ulat) maupun lure artificial (soft frog, minnow, jig, popper).
- Mengerti iklim maritim Indonesia, pengaruh pasang surut air laut (arus perbani/purnama), fase bulan, dan waktu makan ikan (solunar).
- Berikan saran yang aplikatif, santun, terstruktur rapi, dan solutif.
- Jika pengguna bertanya di luar memancing/kelautan/cuaca luar ruangan, arahkan kembali dengan sopan ke topik memancing.`;

      messages.push({
        role: "system",
        content: systemPrompt,
      });

      const history = Array.isArray(conversationHistory)
        ? conversationHistory
        : [];
      const recentHistory =
        history.length > 6 ? history.slice(history.length - 6) : history;

      for (const msg of recentHistory) {
        messages.push({
          role: msg.isUser ? "user" : "assistant",
          content: msg.text || "",
        });
      }

      messages.push({
        role: "user",
        content: userPrompt,
      });
    } else if (action === "vision") {
      if (!base64Image || typeof base64Image !== "string") {
        return new Response(
          JSON.stringify({ error: "base64Image dibutuhkan untuk vision." }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      const prompt =
        "Kamu adalah ahli biologi perikanan dan pemancing profesional. " +
        "Analisis foto ini. Identifikasi spesies ikannya (atau ikan air tawar/laut tropis Indonesia terdekat jika foto kurang jelas). " +
        "Berikan estimasi berat tangkapan realistis dalam kg, umpan/lure paling tepat, dan catatan deskripsi singkat 1-2 kalimat. " +
        "Jawab HANYA dalam format JSON valid persis seperti ini (tanpa markdown backtick): " +
        '{"fish_name":"Nama Ikan", "estimated_weight": 1.5, "recommended_lure":"Nama Umpan", "description":"Deskripsi singkat"}';

      const imageMime = mimeType || "image/jpeg";
      const imageUrl = `data:${imageMime};base64,${base64Image}`;

      messages.push({
        role: "user",
        content: [
          { type: "text", text: prompt },
          {
            type: "image_url",
            image_url: {
              url: imageUrl,
            },
          },
        ],
      });
    } else {
      return new Response(
        JSON.stringify({
          error: "Aksi tidak dikenali. Pilih action 'chat' atau 'vision'.",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const openAiBody = {
      model,
      stream: false,
      messages,
      temperature: 0.7,
      max_tokens: 1024,
    };

    const endpoint = `${baseUrl}/chat/completions`;
    const openAiResp = await fetch(endpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify(openAiBody),
    });

    if (!openAiResp.ok) {
      const errText = await openAiResp.text();
      let errMsg = `AI status ${openAiResp.status}`;
      try {
        const errJson = JSON.parse(errText);
        errMsg = errJson.error?.message || errMsg;
      } catch {
        // use default errMsg
      }

      return new Response(
        JSON.stringify({
          error: errMsg,
          status: openAiResp.status,
          code:
            openAiResp.status === 429 ? "RATE_LIMIT_EXCEEDED" : "AI_ERROR",
        }),
        {
          status: openAiResp.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const openAiData = await openAiResp.json();
    const choices = openAiData.choices;

    if (!choices || choices.length === 0) {
      return new Response(
        JSON.stringify({
          error: "Response AI kosong (tidak ada choices).",
          code: "EMPTY_RESPONSE",
        }),
        {
          status: 502,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const rawMessage = choices[0].message?.content || "";
    const textResult = rawMessage.trim();

    if (action === "chat") {
      return new Response(
        JSON.stringify({
          success: true,
          reply: textResult || "StrikeBot tidak dapat menghasilkan jawaban.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    } else {
      const startIdx = textResult.indexOf("{");
      const endIdx = textResult.lastIndexOf("}");
      if (startIdx !== -1 && endIdx !== -1 && endIdx > startIdx) {
        try {
          const parsed = JSON.parse(textResult.substring(startIdx, endIdx + 1));
          return new Response(
            JSON.stringify({
              success: true,
              data: parsed,
            }),
            {
              headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
          );
        } catch {
          return new Response(
            JSON.stringify({
              success: false,
              rawText: textResult,
              error: "Gagal mem-parsing format JSON dari AI.",
            }),
            {
              headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
          );
        }
      }

      return new Response(
        JSON.stringify({
          success: false,
          rawText: textResult,
          error: "Pola JSON tidak ditemukan di jawaban AI.",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }
  } catch (err: any) {
    return new Response(
      JSON.stringify({
        error: err.message || "Terjadi kesalahan internal pada Edge Function.",
        code: "INTERNAL_ERROR",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
