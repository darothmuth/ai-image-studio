/**
 * AI Image Studio — Backend
 * ----------------------------------------------------------------
 * Rule 4 compliance: the OpenAI API key lives ONLY here, in the
 * server's environment variables (.env). The Flutter app never sees it.
 *
 * Endpoints:
 *   GET  /api/health           -> liveness check
 *   POST /api/enhance-prompt   -> LLM rewrites a short prompt into a
 *                                 more descriptive one
 *   POST /api/generate         -> generates an image from a prompt
 *
 * Architecture:
 *   Flutter -> Backend (this file) -> configured image provider -> Flutter
 *
 * If OPENAI_API_KEY is absent, the server uses the free Pollinations image
 * endpoint and a local prompt enhancer. No secret is required in that mode.
 */

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const rateLimit = require("express-rate-limit");
const OpenAI = require("openai");

const app = express();
const PORT = process.env.PORT || 3000;
const IMAGE_MODEL = process.env.IMAGE_MODEL || "gpt-image-1";
const TEXT_MODEL = process.env.TEXT_MODEL || "gpt-4o-mini";

const hasOpenAiKey = Boolean(process.env.OPENAI_API_KEY);
const openai = hasOpenAiKey
  ? new OpenAI({ apiKey: process.env.OPENAI_API_KEY })
  : null;

if (!hasOpenAiKey) {
  console.log(
    "No OPENAI_API_KEY found. Using free mode: local prompt enhancement " +
      "and Pollinations image generation."
  );
}

// Render/Railway sit behind a proxy; needed so rate limiting sees real client IPs.
app.set("trust proxy", 1);
app.use(cors());
app.use(express.json({ limit: "2mb" }));

// Basic abuse protection (Section 19: rate limiting where appropriate).
const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 15,
  message: { error: "Too many requests. Please slow down." },
});
app.use("/api/", limiter);

app.get("/", (req, res) => {
  res.json({
    name: "Matrix AI Backend",
    status: "ok",
    message: "Backend is running. Use /api/health to check service health.",
    endpoints: ["/api/health", "/api/enhance-prompt", "/api/generate"],
  });
});

app.get("/api/health", (req, res) => {
  res.json({
    status: "ok",
    provider: hasOpenAiKey ? "openai" : "pollinations-free",
    time: new Date().toISOString(),
  });
});

function enhancePromptLocally(prompt) {
  return `${prompt.trim()}, highly detailed composition, cinematic lighting, rich colors, professional digital artwork`;
}

/**
 * POST /api/enhance-prompt
 * Body: { prompt: string }
 * Returns: { enhancedPrompt: string }
 */
app.post("/api/enhance-prompt", async (req, res) => {
  try {
    const { prompt } = req.body;
    if (!prompt || typeof prompt !== "string" || !prompt.trim()) {
      return res.status(400).json({ error: "A non-empty 'prompt' is required." });
    }

    if (!openai) {
      return res.json({ enhancedPrompt: enhancePromptLocally(prompt) });
    }

    const completion = await openai.chat.completions.create({
      model: TEXT_MODEL,
      messages: [
        {
          role: "system",
          content:
            "You rewrite short image-generation prompts into vivid, " +
            "descriptive prompts (subject, setting, lighting, mood, " +
            "composition) in 1-2 sentences. Do not add style names like " +
            "'anime' or 'oil painting' — the app adds style separately. " +
            "Return ONLY the rewritten prompt, nothing else.",
        },
        { role: "user", content: prompt },
      ],
      temperature: 0.8,
      max_tokens: 120,
    });

    const enhancedPrompt =
      completion.choices?.[0]?.message?.content?.trim() || prompt;

    res.json({ enhancedPrompt });
  } catch (err) {
    console.error("enhance-prompt error:", err.message);
    res.status(500).json({ error: "Failed to enhance prompt." });
  }
});

/**
 * POST /api/generate
 * Body: { prompt: string, style: string }
 * Returns: { imageBase64: string }  (base64-encoded PNG)
 */
app.post("/api/generate", async (req, res) => {
  try {
    const { prompt, style } = req.body;
    if (!prompt || typeof prompt !== "string" || !prompt.trim()) {
      return res.status(400).json({ error: "A non-empty 'prompt' is required." });
    }
    if (prompt.length > 1000) {
      return res.status(400).json({ error: "Prompt is too long." });
    }

    if (!openai) {
      const encodedPrompt = encodeURIComponent(prompt);
      const imageUrl =
        `https://image.pollinations.ai/prompt/${encodedPrompt}` +
        "?width=1024&height=1024&nologo=true";
      return res.json({ imageUrl, style, prompt });
    }

    const result = await openai.images.generate({
      model: IMAGE_MODEL,
      prompt,
      size: "1024x1024",
      n: 1,
    });

    const imageBase64 = result.data?.[0]?.b64_json;
    if (!imageBase64) {
      return res.status(502).json({ error: "The model did not return an image." });
    }

    res.json({ imageBase64, style, prompt });
  } catch (err) {
    console.error("generate error:", err.message);

    // Surface content-policy rejections clearly instead of a generic 500.
    if (err.status === 400 && /safety|policy/i.test(err.message || "")) {
      return res.status(400).json({
        error:
          "That prompt was blocked by the image model's content policy. " +
          "Please try a different description.",
      });
    }

    res.status(500).json({ error: "Image generation failed. Please try again." });
  }
});

// Local / Render: start a server. Vercel: just export the app (serverless).
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`AI Image Studio backend running on http://localhost:${PORT}`);
  });
}

module.exports = app;
