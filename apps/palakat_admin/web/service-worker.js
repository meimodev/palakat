/**
 * Service Worker for Pusher Beams push notifications.
 * 
 * This service worker handles:
 * - Push notification display
 * - Notification click events to navigate to relevant screens
 * 
 * **Validates: Requirements 4.5, 4.6**
 */

// Import Pusher Beams service worker
importScripts('https://js.pusher.com/beams/service-worker.js');

// Handle notification click events
self.addEventListener('notificationclick', function(event) {
  event.notification.close();

  // Extract deep link data from notification
  const data = event.notification.data;
  let targetUrl = '/';

  if (data && data.deepLink) {
    targetUrl = data.deepLink;
  } else if (data && data.activityId) {
    // Navigate to activity detail screen
    targetUrl = '/activity?id=' + data.activityId;
  } else if (data && data.type) {
    // Navigate based on notification type
    switch (data.type) {
      case 'ACTIVITY_CREATED':
        targetUrl = '/activity';
        break;
      case 'APPROVAL_REQUIRED':
      case 'APPROVAL_CONFIRMED':
      case 'APPROVAL_REJECTED':
        targetUrl = '/approval';
        break;
      default:
        targetUrl = '/dashboard';
    }
  }

  // Open or focus the app window and navigate to the target URL
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then(function(clientList) {
        // Check if there's already a window open
        for (let i = 0; i < clientList.length; i++) {
          const client = clientList[i];
          if ('focus' in client) {
            // Navigate the existing window to the target URL
            client.postMessage({
              type: 'NOTIFICATION_CLICK',
              url: targetUrl,
              data: data
            });
            return client.focus();
          }
        }
        // If no window is open, open a new one
        if (clients.openWindow) {
          return clients.openWindow(targetUrl);
        }
      })
  );
});

// Handle push events (for custom notification display if needed)
self.addEventListener('push', function(event) {
  // Pusher Beams handles the default push display
  // This is here for any custom handling if needed in the future
  console.log('[Service Worker] Push received:', event);
});
