import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response("Unauthorized", { status: 401, headers: corsHeaders });
    }

    // Récupère l'utilisateur depuis son JWT
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const sb = createClient(supabaseUrl, supabaseServiceKey);

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error } = await sb.auth.getUser(token);

    if (error || !user) {
      return new Response("Unauthorized", { status: 401, headers: corsHeaders });
    }

    const email = user.email!;
    const name = user.user_metadata?.full_name || user.user_metadata?.name || "Athlète";
    const firstName = name.split(" ")[0];

    // Envoie l'email de confirmation via Resend
    const resendKey = Deno.env.get("RESEND_API_KEY");
    if (!resendKey) {
      console.warn("RESEND_API_KEY not set — email not sent");
      return new Response(JSON.stringify({ sent: false, reason: "no_api_key" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: Arial, sans-serif; background: #1A1A1A; margin: 0; padding: 0; }
    .container { max-width: 520px; margin: 40px auto; background: #2A2A2A; border-radius: 16px; overflow: hidden; }
    .header { background: #1A1A1A; padding: 28px 40px; text-align: center; border-bottom: 1px solid #333; }
    .logo { color: #7CB928; font-size: 26px; font-weight: 800; letter-spacing: 3px; font-family: Arial, sans-serif; }
    .body { padding: 36px 40px; }
    .body h2 { color: #FFFFFF; font-size: 20px; margin: 0 0 14px; }
    .body p { font-size: 15px; line-height: 1.7; color: #B0B0B0; margin: 0 0 16px; }
    .alert { background: #1e2e12; border: 1px solid #7CB928; border-radius: 10px; padding: 14px 18px; margin: 20px 0; }
    .alert p { color: #9BD43E; margin: 0; font-size: 14px; }
    .btn { display: inline-block; background: #7CB928; color: #FFF; text-decoration: none; padding: 13px 28px; border-radius: 50px; font-size: 14px; font-weight: 700; }
    .footer { padding: 20px 40px; text-align: center; font-size: 12px; color: #555; border-top: 1px solid #333; }
    .footer a { color: #7CB928; text-decoration: none; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="logo">SUBX</div>
    </div>
    <div class="body">
      <h2>Mot de passe modifié ✓</h2>
      <p>Bonjour ${firstName},</p>
      <p>Ton mot de passe SUBX vient d'être modifié avec succès.</p>
      <div class="alert">
        <p>🔒 Si tu n'es pas à l'origine de cette modification, contacte-nous immédiatement et sécurise ton compte.</p>
      </div>
      <p style="text-align:center; margin-top: 24px;">
        <a href="https://subx-orcin.vercel.app/profil.html" class="btn">Accéder à mon compte</a>
      </p>
    </div>
    <div class="footer">
      <p>&copy; 2025 SUBX &mdash; <a href="https://subx-orcin.vercel.app">subx-orcin.vercel.app</a></p>
    </div>
  </div>
</body>
</html>`;

    const resRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "SUBX <onboarding@resend.dev>",
        to: email,
        subject: "Ton mot de passe SUBX a été modifié",
        html,
      }),
    });

    if (!resRes.ok) {
      const err = await resRes.text();
      console.error("Resend error:", err);
      return new Response(JSON.stringify({ sent: false, error: err }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ sent: true }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
