import { useState, useEffect, useCallback, useRef } from 'react';
import { RequestItem, WebSocketMessage } from '@/types/agentassist';

export interface UseWebSocketReturn {
  isConnected: boolean;
  requests: RequestItem[];
  sendResponse: (requestId: string, isError: boolean, responseText: string) => void;
  connect: (token: string) => void;
  disconnect: () => void;
}

export function useWebSocket(): UseWebSocketReturn {
  const [isConnected, setIsConnected] = useState(false);
  const [requests, setRequests] = useState<RequestItem[]>([]);
  const wsRef = useRef<WebSocket | null>(null);
  const tokenRef = useRef<string>('');

  const connect = useCallback((token: string) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      return;
    }

    tokenRef.current = token;
    const wsUrl = `${window.location.protocol === 'https:' ? 'wss:' : 'ws:'}//${window.location.host}/ws`;
    
    try {
      wsRef.current = new WebSocket(wsUrl);

      wsRef.current.onopen = () => {
        console.log('WebSocket connected');
        setIsConnected(true);
        
        // Send login message
        if (wsRef.current) {
          const loginMessage: WebSocketMessage = {
            cmd: 'UserLogin',
            strParam: token
          };
          wsRef.current.send(JSON.stringify(loginMessage));
        }
      };

      wsRef.current.onmessage = (event) => {
        try {
          const message: WebSocketMessage = JSON.parse(event.data);
          console.log('Received message:', message);

          if (message.cmd === 'AskQuestion' && message.askQuestionRequest) {
            const req = message.askQuestionRequest;
            const newRequest: RequestItem = {
              id: req.ID,
              type: 'ask_question',
              projectDirectory: req.request.projectDirectory,
              question: req.request.question,
              timeout: req.request.timeout,
              timestamp: new Date()
            };
            setRequests(prev => [...prev, newRequest]);
          } else if (message.cmd === 'TaskFinish' && message.taskFinishRequest) {
            const req = message.taskFinishRequest;
            const newRequest: RequestItem = {
              id: req.ID,
              type: 'task_finish',
              projectDirectory: req.request.projectDirectory,
              summary: req.request.summary,
              timeout: req.request.timeout,
              timestamp: new Date()
            };
            setRequests(prev => [...prev, newRequest]);
          }
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      };

      wsRef.current.onclose = () => {
        console.log('WebSocket disconnected');
        setIsConnected(false);
        
        // Attempt to reconnect after 3 seconds
        setTimeout(() => {
          if (tokenRef.current) {
            connect(tokenRef.current);
          }
        }, 3000);
      };

      wsRef.current.onerror = (error) => {
        console.error('WebSocket error:', error);
        setIsConnected(false);
      };
    } catch (error) {
      console.error('Failed to create WebSocket connection:', error);
    }
  }, []);

  const disconnect = useCallback(() => {
    if (wsRef.current) {
      wsRef.current.close();
      wsRef.current = null;
    }
    setIsConnected(false);
    setRequests([]);
    tokenRef.current = '';
  }, []);

  const sendResponse = useCallback((requestId: string, isError: boolean, responseText: string) => {
    if (!wsRef.current || wsRef.current.readyState !== WebSocket.OPEN) {
      console.error('WebSocket not connected');
      return;
    }

    // Find the request to determine the type
    const request = requests.find(r => r.id === requestId);
    if (!request) {
      console.error('Request not found:', requestId);
      return;
    }

    let responseMessage: WebSocketMessage;

    if (request.type === 'ask_question') {
      responseMessage = {
        cmd: 'AskQuestionReply',
        askQuestionRequest: {
          ID: requestId,
          userToken: tokenRef.current,
          request: {
            projectDirectory: request.projectDirectory,
            question: request.question || '',
            timeout: request.timeout
          }
        }
      };
    } else {
      responseMessage = {
        cmd: 'TaskFinishReply',
        taskFinishRequest: {
          ID: requestId,
          userToken: tokenRef.current,
          request: {
            projectDirectory: request.projectDirectory,
            summary: request.summary || '',
            timeout: request.timeout
          }
        }
      };
    }

    try {
      wsRef.current.send(JSON.stringify(responseMessage));
      console.log('Sent response for request:', requestId);
      
      // Remove the request from the list
      setRequests(prev => prev.filter(r => r.id !== requestId));
    } catch (error) {
      console.error('Failed to send response:', error);
    }
  }, [requests]);

  useEffect(() => {
    return () => {
      if (wsRef.current) {
        wsRef.current.close();
      }
    };
  }, []);

  return {
    isConnected,
    requests,
    sendResponse,
    connect,
    disconnect
  };
}
