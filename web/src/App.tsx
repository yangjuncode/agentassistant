import { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { useWebSocket } from '@/hooks/useWebSocket';
import { RequestItem } from '@/types/agentassist';
import { MessageCircle, CheckCircle, AlertCircle, Clock, Folder } from 'lucide-react';

function App() {
  const [token, setToken] = useState('');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const { isConnected, requests, sendResponse, connect, disconnect } = useWebSocket();
  const [responses, setResponses] = useState<Record<string, string>>({});

  useEffect(() => {
    // Check for token in URL params
    const urlParams = new URLSearchParams(window.location.search);
    const urlToken = urlParams.get('token');
    if (urlToken) {
      setToken(urlToken);
      handleLogin(urlToken);
    }
  }, []);

  const handleLogin = (loginToken?: string) => {
    const tokenToUse = loginToken || token;
    if (tokenToUse.trim()) {
      connect(tokenToUse);
      setIsLoggedIn(true);
    }
  };

  const handleLogout = () => {
    disconnect();
    setIsLoggedIn(false);
    setToken('');
    setResponses({});
  };

  const handleResponseChange = (requestId: string, value: string) => {
    setResponses(prev => ({ ...prev, [requestId]: value }));
  };

  const handleSendResponse = (requestId: string, isError: boolean) => {
    const responseText = responses[requestId] || '';
    if (!isError && !responseText.trim()) {
      alert('Please enter a response');
      return;
    }
    
    sendResponse(requestId, isError, responseText);
    setResponses(prev => {
      const newResponses = { ...prev };
      delete newResponses[requestId];
      return newResponses;
    });
  };

  const formatTimestamp = (timestamp: Date) => {
    return timestamp.toLocaleTimeString();
  };

  const getRequestIcon = (type: string) => {
    return type === 'ask_question' ? <MessageCircle className="h-4 w-4" /> : <CheckCircle className="h-4 w-4" />;
  };

  if (!isLoggedIn) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-4">
        <Card className="w-full max-w-md">
          <CardHeader className="text-center">
            <CardTitle className="text-2xl">Agent Assistant</CardTitle>
            <CardDescription>
              Enter your token to connect to the Agent Assistant server
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <label htmlFor="token" className="text-sm font-medium">
                Token
              </label>
              <input
                id="token"
                type="text"
                value={token}
                onChange={(e) => setToken(e.target.value)}
                placeholder="Enter your token"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                onKeyPress={(e) => e.key === 'Enter' && handleLogin()}
              />
            </div>
            <Button onClick={() => handleLogin()} className="w-full">
              Connect
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <h1 className="text-2xl font-bold">Agent Assistant</h1>
            <Badge variant={isConnected ? "default" : "destructive"}>
              {isConnected ? "Connected" : "Disconnected"}
            </Badge>
          </div>
          <Button variant="outline" onClick={handleLogout}>
            Logout
          </Button>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6">
        {requests.length === 0 ? (
          <Card>
            <CardContent className="flex flex-col items-center justify-center py-12">
              <Clock className="h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold mb-2">Waiting for requests</h3>
              <p className="text-muted-foreground text-center">
                When an AI agent sends a request, it will appear here for you to respond to.
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-6">
            <h2 className="text-xl font-semibold">
              Pending Requests ({requests.length})
            </h2>
            {requests.map((request) => (
              <RequestCard
                key={request.id}
                request={request}
                response={responses[request.id] || ''}
                onResponseChange={(value) => handleResponseChange(request.id, value)}
                onSendResponse={(isError) => handleSendResponse(request.id, isError)}
                formatTimestamp={formatTimestamp}
                getRequestIcon={getRequestIcon}
              />
            ))}
          </div>
        )}
      </main>
    </div>
  );
}

interface RequestCardProps {
  request: RequestItem;
  response: string;
  onResponseChange: (value: string) => void;
  onSendResponse: (isError: boolean) => void;
  formatTimestamp: (timestamp: Date) => string;
  getRequestIcon: (type: string) => JSX.Element;
}

function RequestCard({ 
  request, 
  response, 
  onResponseChange, 
  onSendResponse, 
  formatTimestamp, 
  getRequestIcon 
}: RequestCardProps) {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            {getRequestIcon(request.type)}
            <CardTitle className="text-lg">
              {request.type === 'ask_question' ? 'Question' : 'Task Finished'}
            </CardTitle>
          </div>
          <div className="flex items-center space-x-2 text-sm text-muted-foreground">
            <Clock className="h-4 w-4" />
            {formatTimestamp(request.timestamp)}
          </div>
        </div>
        <CardDescription>
          Request ID: {request.id}
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center space-x-2 text-sm">
          <Folder className="h-4 w-4" />
          <span className="font-medium">Project:</span>
          <code className="bg-muted px-2 py-1 rounded text-xs">
            {request.projectDirectory}
          </code>
        </div>
        
        {request.type === 'ask_question' && request.question && (
          <div>
            <h4 className="font-medium mb-2">Question:</h4>
            <div className="bg-muted p-3 rounded-md">
              <p className="text-sm">{request.question}</p>
            </div>
          </div>
        )}
        
        {request.type === 'task_finish' && request.summary && (
          <div>
            <h4 className="font-medium mb-2">Summary:</h4>
            <div className="bg-muted p-3 rounded-md">
              <p className="text-sm">{request.summary}</p>
            </div>
          </div>
        )}
        
        <div className="flex items-center space-x-2 text-sm text-muted-foreground">
          <AlertCircle className="h-4 w-4" />
          <span>Timeout: {request.timeout} seconds</span>
        </div>
        
        <div className="space-y-3">
          <label htmlFor={`response-${request.id}`} className="text-sm font-medium">
            Your Response:
          </label>
          <Textarea
            id={`response-${request.id}`}
            value={response}
            onChange={(e) => onResponseChange(e.target.value)}
            placeholder="Enter your response here..."
            className="min-h-[100px]"
          />
          <div className="flex space-x-2">
            <Button 
              onClick={() => onSendResponse(false)}
              className="flex-1"
            >
              Send Response
            </Button>
            <Button 
              variant="destructive" 
              onClick={() => onSendResponse(true)}
            >
              Report Error
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

export default App;
