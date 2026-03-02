package main

import "testing"

func TestParseFcitxStatus(t *testing.T) {
	t.Parallel()

	tests := []struct {
		name    string
		input   string
		want    int
		wantErr bool
	}{
		{name: "active", input: "2\n", want: 2},
		{name: "inactive", input: "1", want: 1},
		{name: "closed", input: "0", want: 0},
		{name: "empty", input: " \n", wantErr: true},
		{name: "invalid", input: "abc", wantErr: true},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			got, err := parseFcitxStatus(tc.input)
			if tc.wantErr {
				if err == nil {
					t.Fatalf("expected error, got nil and value %d", got)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if got != tc.want {
				t.Fatalf("expected %d, got %d", tc.want, got)
			}
		})
	}
}

func TestIsEnglishIbusEngine(t *testing.T) {
	t.Parallel()

	tests := []struct {
		engine string
		want   bool
	}{
		{engine: "xkb:us::eng", want: true},
		{engine: "XKB:US::ENG", want: true},
		{engine: "xkb:us::intl", want: true},
		{engine: "libpinyin", want: false},
		{engine: "rime", want: false},
		{engine: "", want: false},
	}

	for _, tc := range tests {
		tc := tc
		t.Run(tc.engine, func(t *testing.T) {
			t.Parallel()
			if got := isEnglishIbusEngine(tc.engine); got != tc.want {
				t.Fatalf("engine %q expected %v, got %v", tc.engine, tc.want, got)
			}
		})
	}
}
