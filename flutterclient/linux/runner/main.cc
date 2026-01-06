#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include "my_application.h"

// Signal handler to exit immediately and avoid Flutter/GTK cleanup crashes on Linux
void signal_handler(int sig) {
  _exit(0);
}

// Custom log handler to silence annoying warnings
static void custom_log_handler(const gchar *log_domain,
                               GLogLevelFlags log_level,
                               const gchar *message,
                               gpointer user_data) {
  if (message) {
    // Silence libayatana-appindicator deprecation warning
    if (strstr(message, "libayatana-appindicator is deprecated")) return;
    // Silence the GTK module warning
    if (strstr(message, "appmenu-gtk-module")) return;
    // Silence implicit view removal warning from engine
    if (strstr(message, "The implicit view cannot be removed")) return;
  }
  g_log_default_handler(log_domain, log_level, message, user_data);
}

int main(int argc, char** argv) {
  // Suppress "Failed to load module 'appmenu-gtk-module'" warning at environment level
  setenv("GTK_MODULES", "", 1);

  // Set up custom log handler as early as possible
  g_log_set_default_handler(custom_log_handler, nullptr);

  // Install signal handlers to prevent core dump on forced close (Ctrl+C, SIGTERM)
  signal(SIGINT, signal_handler);
  signal(SIGTERM, signal_handler);

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
