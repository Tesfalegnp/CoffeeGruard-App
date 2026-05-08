import { serve } from "https://deno.land/std/http/server.ts";

serve(async (req) => {
  try {
    const { email, otp, name } = await req.json();

    const apiKey = Deno.env.get("RESEND_API_KEY");

    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        from: "CoffeeGuard <onboarding@resend.dev>",
        to: email,
        subject: "Your OTP Code",
        html: `
          <h2>Hello ${name}</h2>
          <p>Your OTP Code:</p>
          <h1>${otp}</h1>
          <p>Expires in 5 minutes.</p>
        `
      })
    });

    const data = await response.json();

    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
      status: 200
    });

  } catch (error) {
    return new Response(JSON.stringify({
      error: error.message
    }), {
      headers: { "Content-Type": "application/json" },
      status: 400
    });
  }
});