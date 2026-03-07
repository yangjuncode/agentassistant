package main

import (
	"reflect"
	"strings"
	"testing"
)

func TestToolVisibilityConfigValidate(t *testing.T) {
	testCases := []struct {
		name        string
		config      toolVisibilityConfig
		wantErr     bool
		errContains string
	}{
		{
			name:    "both tools enabled",
			config:  toolVisibilityConfig{},
			wantErr: false,
		},
		{
			name: "only ask question disabled",
			config: toolVisibilityConfig{
				DisableAskQuestion: true,
			},
			wantErr: false,
		},
		{
			name: "only work report disabled",
			config: toolVisibilityConfig{
				DisableWorkReport: true,
			},
			wantErr: false,
		},
		{
			name: "both tools disabled",
			config: toolVisibilityConfig{
				DisableAskQuestion: true,
				DisableWorkReport:  true,
			},
			wantErr:     true,
			errContains: "both MCP tools are disabled",
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			err := testCase.config.validate()
			if testCase.wantErr {
				if err == nil {
					t.Fatalf("validate() error = nil, want error")
				}
				if testCase.errContains != "" && !strings.Contains(err.Error(), testCase.errContains) {
					t.Fatalf("validate() error = %q, want substring %q", err.Error(), testCase.errContains)
				}
				return
			}

			if err != nil {
				t.Fatalf("validate() unexpected error = %v", err)
			}
		})
	}
}

func TestEnabledToolNames(t *testing.T) {
	testCases := []struct {
		name      string
		config    toolVisibilityConfig
		wantNames []string
		wantErr   bool
	}{
		{
			name:      "default exposes both tools",
			config:    toolVisibilityConfig{},
			wantNames: []string{"ask_question", "work_report"},
		},
		{
			name: "ask question hidden",
			config: toolVisibilityConfig{
				DisableAskQuestion: true,
			},
			wantNames: []string{"work_report"},
		},
		{
			name: "work report hidden",
			config: toolVisibilityConfig{
				DisableWorkReport: true,
			},
			wantNames: []string{"ask_question"},
		},
		{
			name: "all tools hidden returns error",
			config: toolVisibilityConfig{
				DisableAskQuestion: true,
				DisableWorkReport:  true,
			},
			wantErr: true,
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			gotNames, err := enabledToolNames(testCase.config)
			if testCase.wantErr {
				if err == nil {
					t.Fatalf("enabledToolNames() error = nil, want error")
				}
				return
			}

			if err != nil {
				t.Fatalf("enabledToolNames() unexpected error = %v", err)
			}
			if !reflect.DeepEqual(gotNames, testCase.wantNames) {
				t.Fatalf("enabledToolNames() = %v, want %v", gotNames, testCase.wantNames)
			}
		})
	}
}
