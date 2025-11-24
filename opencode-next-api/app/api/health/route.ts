import { createOpencodeClient } from "@opencode-ai/sdk";
import { NextResponse } from "next/server";

export async function GET() {
  try {
    const startTime = Date.now();

     // Create the OpenCode client
     const client = createOpencodeClient({
       baseUrl: process.env.OPENCODE_URL || "http://localhost:8080",
     });

    // Test connection to the backend server
    // Using a simple session list request to verify connectivity
    const response = await client.session.list();

    const responseTime = Date.now() - startTime;

    // Check if we got a valid response
    if (response.error) {
      return NextResponse.json(
        {
          status: "unhealthy",
          message: "Backend server is not responding",
          error: response.error,
          timestamp: new Date().toISOString(),
          responseTime: `${responseTime}ms`,
        },
        { status: 503 }
      );
    }

    return NextResponse.json({
      status: "healthy",
      message: "All services are operational",
      timestamp: new Date().toISOString(),
      responseTime: `${responseTime}ms`,
      services: {
        api: "healthy",
        backend: "healthy",
      },
    });
  } catch (error) {
    return NextResponse.json(
      {
        status: "unhealthy",
        message: "Failed to connect to backend server",
        error: error instanceof Error ? error.message : "Unknown error",
        timestamp: new Date().toISOString(),
      },
      { status: 503 }
    );
  }
}
