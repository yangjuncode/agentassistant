package service

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/websocket"
	"google.golang.org/protobuf/proto"

	agentassistproto "github.com/yangjuncode/agentassistant/agentassistproto"
)

// 缩小读写超时参数，让测试在 ~1s 内验证行为
func shortWSVars(t *testing.T, readWait, pingPeriod time.Duration) {
	t.Helper()
	origRead, origPing := wsReadWait, wsPingPeriod
	wsReadWait, wsPingPeriod = readWait, pingPeriod
	t.Cleanup(func() { wsReadWait, wsPingPeriod = origRead, origPing })
}

func wsTestServer(t *testing.T) string {
	t.Helper()
	h := NewWebSocketHandler(NewBroadcaster(), "test")
	srv := httptest.NewServer(http.HandlerFunc(h.HandleWebSocket))
	t.Cleanup(srv.Close)
	return "ws" + strings.TrimPrefix(srv.URL, "http")
}

func dialWS(t *testing.T, url string) *websocket.Conn {
	t.Helper()
	conn, _, err := websocket.DefaultDialer.Dial(url, nil)
	if err != nil {
		t.Fatalf("dial failed: %v", err)
	}
	t.Cleanup(func() { conn.Close() })
	// 不回 pong：模拟弱网丢 ping/pong 的客户端
	conn.SetPingHandler(func(string) error { return nil })
	return conn
}

// 回归：应用层消息必须给读超时续期。
// 客户端不回 pong，但每 50ms 发一条 GetPendingMessages（等于客户端的
// 应用层心跳）：若续期只认 pong，连接会在 readWait 处被掐断。
func TestWSAppTrafficExtendsReadDeadline(t *testing.T) {
	shortWSVars(t, 400*time.Millisecond, 100*time.Millisecond)
	conn := dialWS(t, wsTestServer(t))

	start := time.Now()
	until := start.Add(2 * time.Second) // 5×readWait
	stop := make(chan struct{})
	defer close(stop)
	go func() {
		mb, _ := proto.Marshal(&agentassistproto.WebsocketMessage{Cmd: "GetPendingMessages"})
		for {
			select {
			case <-stop:
				return
			case <-time.After(50 * time.Millisecond):
				if conn.WriteMessage(websocket.BinaryMessage, mb) != nil {
					return
				}
			}
		}
	}()

	for time.Now().Before(until) {
		if _, _, err := conn.ReadMessage(); err != nil {
			t.Fatalf("conn died at %v despite app traffic every 50ms: %v",
				time.Since(start).Round(time.Millisecond), err)
		}
	}
}

// 对照：既不回 pong 也不发消息的连接，仍必须在 ~readWait 被回收，
// 防止续期逻辑把死连接永久吊着。
func TestWSSilentConnStillReaped(t *testing.T) {
	shortWSVars(t, 400*time.Millisecond, 100*time.Millisecond)
	conn := dialWS(t, wsTestServer(t))

	start := time.Now()
	for {
		if _, _, err := conn.ReadMessage(); err != nil {
			elapsed := time.Since(start)
			if elapsed < 300*time.Millisecond {
				t.Fatalf("conn killed too early at %v: %v", elapsed.Round(time.Millisecond), err)
			}
			t.Logf("silent conn reaped at %v", elapsed.Round(time.Millisecond))
			return
		}
		if time.Since(start) > 3*time.Second {
			t.Fatal("silent conn survived past 3s — read deadline not enforced")
		}
	}
}
