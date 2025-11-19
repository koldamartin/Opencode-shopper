import { createOpencodeClient } from "@opencode-ai/sdk";
import { NextRequest, NextResponse } from "next/server";

// Create the OpenCode client connecting to the existing server
const client = createOpencodeClient({
  baseUrl: process.env.OPENCODE_URL || "https://strejda.onrender.com",
});

// Store session ID (in production, this should be per-user)
let sessionId: string | null = null;

export async function OPTIONS() {
  return new NextResponse(null, {
    status: 204,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
  });
}

export async function POST(request: NextRequest) {
  try {
    const { message } = await request.json();

    if (!message) {
      return NextResponse.json(
        { error: "Message is required" },
        {
          status: 400,
          headers: {
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    // Create session if it doesn't exist
    if (!sessionId) {
      const session = await client.session.create({
        body: {},
      });
      if (!session.data) {
        throw new Error("Failed to create session");
      }
      sessionId = session.data.id;
    }

    // Send the message to the OpenCode server (uses model from server config)
    const response = await client.session.prompt({
      path: { id: sessionId },
      body: {
        parts: [{ type: "text", text: message }],
      },
    });

    if (!response.data) {
      throw new Error("Failed to get response from server");
    }

    // Extract text content from response parts
    const textContent = response.data.parts
      .filter((part) => part.type === "text")
      .map((part) => part.text)
      .join("");

    return NextResponse.json(
      { response: textContent },
      {
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (error) {
    console.error("Error communicating with OpenCode server:", error);
    return NextResponse.json(
      { error: "Failed to communicate with OpenCode server" },
      {
        status: 500,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
}