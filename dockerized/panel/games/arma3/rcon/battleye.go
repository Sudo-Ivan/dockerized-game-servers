package rcon

import (
	"encoding/binary"
	"errors"
	"fmt"
	"hash/crc32"
	"net"
	"strings"
	"sync"
	"time"
)

const (
	packetLogin    byte = 0x00
	packetCommand  byte = 0x01
	packetResponse byte = 0x02
)

type Client struct {
	addr     string
	password string
	timeout  time.Duration

	mu   sync.Mutex
	conn net.Conn
	seq  byte
}

func New(host string, port int, password string) *Client {
	return &Client{
		addr:     fmt.Sprintf("%s:%d", host, port),
		password: password,
		timeout:  5 * time.Second,
	}
}

func (c *Client) Command(command string) (string, error) {
	c.mu.Lock()
	defer c.mu.Unlock()

	if err := c.ensureConn(); err != nil {
		return "", err
	}
	if err := c.writePacket(packetCommand, []byte(command)); err != nil {
		_ = c.closeConn()
		return "", err
	}
	return c.readUntilResponse()
}

func (c *Client) Close() error {
	c.mu.Lock()
	defer c.mu.Unlock()
	return c.closeConn()
}

func (c *Client) ensureConn() error {
	if c.conn != nil {
		return nil
	}
	conn, err := net.DialTimeout("udp", c.addr, c.timeout)
	if err != nil {
		return err
	}
	_ = conn.SetDeadline(time.Now().Add(c.timeout))
	c.conn = conn
	c.seq = 0
	if err := c.writePacket(packetLogin, []byte(c.password)); err != nil {
		_ = c.closeConn()
		return err
	}
	_, err = c.readUntilResponse()
	return err
}

func (c *Client) closeConn() error {
	if c.conn == nil {
		return nil
	}
	err := c.conn.Close()
	c.conn = nil
	return err
}

func (c *Client) writePacket(kind byte, payload []byte) error {
	if c.conn == nil {
		return errors.New("not connected")
	}
	body := make([]byte, 0, 8+len(payload))
	body = append(body, kind, c.seq)
	body = append(body, payload...)
	c.seq++

	packet := make([]byte, 0, 2+4+len(body))
	packet = append(packet, 'B', 'E')
	crc := crc32.ChecksumIEEE(body)
	buf := make([]byte, 4)
	binary.LittleEndian.PutUint32(buf, crc)
	packet = append(packet, buf...)
	packet = append(packet, body...)

	_, err := c.conn.Write(packet)
	return err
}

func (c *Client) readUntilResponse() (string, error) {
	if c.conn == nil {
		return "", errors.New("not connected")
	}

	var parts []string
	deadline := time.Now().Add(c.timeout)
	for time.Now().Before(deadline) {
		_ = c.conn.SetReadDeadline(time.Now().Add(800 * time.Millisecond))
		buf := make([]byte, 4096)
		n, err := c.conn.Read(buf)
		if err != nil {
			if ne, ok := err.(net.Error); ok && ne.Timeout() {
				if len(parts) > 0 {
					break
				}
				continue
			}
			return "", err
		}
		text, err := decodePacket(buf[:n])
		if err != nil {
			return "", err
		}
		if text != "" {
			parts = append(parts, text)
		}
	}
	if len(parts) == 0 {
		return "", errors.New("empty rcon response")
	}
	return strings.TrimSpace(strings.Join(parts, "\n")), nil
}

func decodePacket(raw []byte) (string, error) {
	if len(raw) < 8 || raw[0] != 'B' || raw[1] != 'E' {
		return "", errors.New("invalid battleye packet")
	}
	body := raw[6:]
	if len(body) < 2 {
		return "", nil
	}
	if body[0] != packetResponse {
		return "", nil
	}
	if len(body) <= 2 {
		return "", nil
	}
	return strings.TrimRight(string(body[2:]), "\x00"), nil
}

func (c *Client) Broadcast(message string) error {
	_, err := c.Command("say -1 " + message)
	return err
}
