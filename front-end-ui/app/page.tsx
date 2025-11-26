'use client';

import { useState } from 'react';

type Product = {
  name: string;
  price_czk: number;
  image_link: string;
};

type ChatPayload = {
  output_text: string;
  products: Product[] | null;
};

type Message =
  | { role: 'user'; content: string }
  | { role: 'assistant'; content: ChatPayload };

// Helper function to parse markdown bold syntax
const parseMarkdownBold = (text: string) => {
  const parts = text.split(/(\*\*.*?\*\*)/g);
  return parts.map((part, index) => {
    if (part.startsWith('**') && part.endsWith('**')) {
      return <strong key={index}>{part.slice(2, -2)}</strong>;
    }
    return part;
  });
};

export default function Home() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [sessionId, setSessionId] = useState<string | null>(null);

  const handleSend = async () => {
    if (!input.trim()) return;

    // Add user message
    const userMessage: Message = { role: 'user', content: input };
    const updatedMessages = [...messages, userMessage];
    setMessages(updatedMessages);
    setInput('');
    setIsLoading(true);

    try {
      // Send message to OpenCode API
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';
      const response = await fetch(`${apiUrl}/api/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message: input, sessionId }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to get response');
      }

      // Store the session ID for future requests
      if (data.sessionId) {
        setSessionId(data.sessionId);
      }

      const aiMessage: Message = { role: 'assistant', content: data.response };
      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      console.error('Error sending message:', error);
      const errorMessage: Message = {
        role: 'assistant',
        content: {
          output_text: 'Sorry, there was an error processing your message.',
          products: null
        }
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-zinc-50 via-blue-50 to-zinc-100 dark:from-zinc-950 dark:via-blue-950 dark:to-zinc-900 p-4">
      <div className="w-full max-w-4xl h-[85vh] bg-white/80 dark:bg-zinc-800/90 backdrop-blur-sm rounded-2xl shadow-2xl border border-zinc-200/50 dark:border-zinc-700/50 flex flex-col">
        {/* Header */}
        <div className="p-6 border-b border-zinc-200/60 dark:border-zinc-700/60 bg-gradient-to-r from-blue-50 to-transparent dark:from-blue-950/30 dark:to-transparent">
          <h1 className="text-2xl font-bold text-zinc-900 dark:text-zinc-100 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
            OpenCode Chat
          </h1>
          <p className="text-sm text-zinc-600 dark:text-zinc-400 mt-1">
            Powered by Big Pickle
          </p>
        </div>

        {/* Messages Container */}
        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          {messages.length === 0 && (
            <div className="text-center text-zinc-400 dark:text-zinc-500 mt-12">
              <div className="text-6xl mb-4">💬</div>
              <p className="text-lg font-medium">Send a message to start chatting</p>
              <p className="text-sm mt-2">Ask me anything about products!</p>
            </div>
          )}
          {messages.map((message, index) => (
            <div
              key={index}
              className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[80%] rounded-2xl px-5 py-3 shadow-md ${
                  message.role === 'user'
                    ? 'bg-gradient-to-br from-blue-500 to-blue-600 text-white'
                    : 'bg-white dark:bg-zinc-700 text-zinc-900 dark:text-zinc-100 border border-zinc-200 dark:border-zinc-600'
                }`}
              >
                {message.role === 'user' ? (
                  message.content
                ) : (
                  <div className="space-y-4">
                    {/* output_text in black with bold markdown support */}
                    <p className="text-zinc-900 dark:text-zinc-100">
                      {parseMarkdownBold(message.content.output_text)}
                    </p>

                    {/* products in horizontal card grid below output_text */}
                    {message.content.products && message.content.products.length > 0 && (
                      <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mt-4">
                         {message.content.products.map((product, i) => (
                          <div 
                            key={i} 
                            className="border border-zinc-200 dark:border-zinc-600 rounded-xl shadow-md hover:shadow-xl transition-all duration-300 hover:-translate-y-1 bg-white dark:bg-zinc-50 p-4 flex flex-col"
                          >
                            {/* Product Image - centered at top */}
                            {product.image_link && (
                              <div className="flex justify-center mb-3">
                                <img 
                                  src={product.image_link} 
                                  alt={product.name} 
                                  className="w-full h-auto object-contain rounded"
                                />
                              </div>
                            )}
                            
                            {/* Product Name - blue, clickable */}
                            <a 
                              href={product.image_link} 
                              target="_blank" 
                              rel="noopener noreferrer"
                              className="text-blue-600 hover:underline cursor-pointer mb-2 text-sm font-medium"
                            >
                              {product.name}
                            </a>
                            
                            {/* Price - red/pink, right-aligned */}
                            <p className="text-right text-pink-600 font-medium text-sm mt-auto">
                              {product.price_czk} Kč
                            </p>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          ))}
          {isLoading && (
            <div className="flex justify-start">
              <div className="bg-white dark:bg-zinc-700 border border-zinc-200 dark:border-zinc-600 rounded-2xl px-5 py-3 shadow-md">
                <div className="flex gap-1">
                  <span className="animate-bounce text-blue-500">●</span>
                  <span className="animate-bounce text-blue-500" style={{animationDelay: '0.1s'}}>●</span>
                  <span className="animate-bounce text-blue-500" style={{animationDelay: '0.2s'}}>●</span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Input Area */}
        <div className="p-6 border-t border-zinc-200/60 dark:border-zinc-700/60 bg-zinc-50/50 dark:bg-zinc-900/30">
          <div className="flex gap-3">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Type your message..."
              className="flex-1 px-5 py-3 border border-zinc-300 dark:border-zinc-600 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-700 dark:text-zinc-100 shadow-sm transition-all"
              disabled={isLoading}
            />
            <button
              onClick={handleSend}
              disabled={isLoading || !input.trim()}
              className="px-8 py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl hover:from-blue-600 hover:to-blue-700 disabled:from-zinc-300 disabled:to-zinc-300 disabled:cursor-not-allowed transition-all shadow-md hover:shadow-lg font-medium"
            >
              Send
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
