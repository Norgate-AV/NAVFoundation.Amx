const PORT = 8080;

Deno.serve({ port: PORT }, (req) => {
    if (req.headers.get("upgrade") !== "websocket") {
        return new Response("Not a WebSocket request", { status: 400 });
    }

    const { socket, response } = Deno.upgradeWebSocket(req);

    socket.onopen = () => {
        console.log("Client connected");
    };

    socket.onmessage = (event) => {
        const timestamp = new Date().toISOString();

        try {
            const data = JSON.parse(event.data);
            const level = (data.level || "INFO").toUpperCase();
            const message = data.message || event.data;

            console.log(`[${timestamp}] ${level}: ${message}`);
        } catch (e) {
            // Failed to parse JSON, log raw data
            console.log(`[${timestamp}] RAW: ${event.data}`);
        }
    };

    socket.onclose = () => {
        console.log("Client disconnected");
    };

    socket.onerror = (error) => {
        // Suppress "Unexpected EOF" during development uploads
        if (error.message === "Unexpected EOF") {
            console.log(
                "Client disconnected abruptly (likely program upload or power cycle/loss)",
            );
        } else {
            console.error("WebSocket error:", error);
        }
    };

    return response;
});

console.log(`WebSocket server listening on ws://localhost:${PORT}`);
