# ConVo Flutter Application — Developer Handover & API Architecture Guide

This document is the definitive single source of truth for the **ConVo Flutter** frontend codebase. It provides a complete, authoritative developer handover based directly on empirical code inspection of all models, data sources, repositories, BLoCs, storage services, and real-time STOMP WebSocket streams.

---

## 1. Project Overview

- **Application Purpose**: Modern real-time messaging application providing phone-number OTP authentication, profile setup, contact synchronization, WhatsApp-style instant chat messaging with STOMP WebSockets, and offline-first data caching.
- **Framework & Language**: Flutter (Dart 3.x).
- **Architecture**: **Clean Architecture** (Data, Domain, Presentation layers) with Dependency Injection via `GetIt`.
- **State Management**: BLoC pattern using `flutter_bloc` (`AuthBloc`, `ContactsBloc`, `ChatBloc`, `HomeBloc`).
- **Networking**: Custom `ApiClient` wrapping `http.Client` with automatic JWT Bearer header injection.
- **Local Storage**: `SharedPreferences` (via `LocalStorage`) for JSON string persistence and `SecureStorage` for token security.
- **Real-Time WebSockets**: `stomp_dart_client` via `StompService` and `ChatRealtimeService` for STOMP over WebSocket messaging.
- **Media Handling**: `image_picker` for camera/gallery image and video picking, with multipart uploads via `ApiClient.postMultipart`.

### Main Directory Structure

```text
lib/
├── app/
│   ├── config/          # ApiConfig (Base URL, Timeout, Endpoint paths)
│   ├── localization/    # LanguageManager & string translations
│   ├── router/          # AppRouter & RouteNames
│   └── theme/           # AppColors & ThemeData (Light/Dark mode)
├── core/
│   ├── constants/       # StorageKeys & AppConstants
│   ├── network/         # ApiClient, StompService, ChatRealtimeService, Exceptions
│   ├── storage/         # LocalStorage & SecureStorage wrappers
│   ├── utils/           # Validators & Logger
│   └── widgets/         # AppScaffold, CustomTextField, CustomButton
├── features/
│   ├── authentication/  # Login, OTP, AuthBloc, AuthRepository, DataSources
│   ├── chats/           # ChatPage, ChatBloc, ChatRepository, Message Entities/Models
│   ├── contacts/        # ContactsPage, ContactProfilePage, ContactsBloc, Sync
│   ├── home/            # HomePage, HomeBloc, HomeRepository, ChatSummary Models
│   ├── media/           # MediaPickerPage & image/video handling
│   ├── profile/         # ProfileSetupPage & ProfilePage
│   ├── settings/        # SettingsPage (Language & Theme selection)
│   └── splash/          # SplashPage (Startup Authentication Check)
└── injection/
    └── dependency_injection.dart # GetIt Service Locator Registrations
```

---

## 2. Complete API Inventory

| API Endpoint | Method | Feature / Screen | Auth Required | Request Payload | Response Data | Local Storage Impact |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `/api/auth/request-otp` | `POST` | Login Screen | ❌ No | `{ countryCode, phoneNumber }` | `{ success, message, code }` | Saves phone & country code |
| `/api/auth/verify-otp` | `POST` | OTP Screen | ❌ No | `{ countryCode, phoneNumber, otp }` | `{ success, data: { token, isNewUser, user } }` | Saves JWT token & `is_logged_in` flag |
| `/api/users/profile` | `POST` (Multipart) | Profile Setup | 🔑 Yes | Query: `name`, `about` + File: `image` | `{ success, data: { id, name, profileImage, ... } }` | Updates local user profile |
| `/api/users/me` | `DELETE` | Settings Screen | 🔑 Yes | None | `{ success, message }` | Clears all local storage & token |
| `/api/contacts/sync` | `POST` | Contacts Screen | 🔑 Yes | `{ contacts: [...], phoneNumbers: [...] }` | `{ success, data: [ { id, name, phoneNumber, status, online } ] }` | Saves `synced_contacts` JSON |
| `/api/chats` | `POST` | Contacts / Chat | 🔑 Yes | `{ targetUserId: <int> }` | `{ success, data: { chatId, chatType, targetUserId } }` | Maps `chat_id_user_$targetUserId` |
| `/api/chats` | `GET` | Home Screen | 🔑 Yes | None | `{ success, data: [ { chatId, chatType, otherUser, lastMessage, ... } ] }` | Saves `home_chats_list` JSON |
| `/api/chats/{id}/messages` | `GET` | Chat Screen | 🔑 Yes | None | `{ success, data: { content: [ MessageObjects ] } }` | Saves `chat_messages_$chatId` JSON |
| `/api/messages` | `POST` | Chat Screen | 🔑 Yes | `{ chatId, receiverId, type, content, mediaUrl, mediaId, replyToId }` | `{ success, data: MessageObject }` | Appends message to local cache |
| `/api/media/upload` | `POST` (Multipart) | Chat Screen | 🔑 Yes | Multipart Form File (`file` / `video`) | `{ success, data: { mediaId, mediaUrl } }` | Temporary file cache |

---

## 3. Authentication APIs & Complete Flow

### Authentication Sequence Flow

```text
[Phone Number Input (+91)] ──> POST /api/auth/request-otp
                                        │
[OTP Verification Screen] ◄─────────────┘
          │
          ├──> POST /api/auth/verify-otp ──> Returns JWT Bearer Token
          │                                        │
          │                        ┌───────────────┴───────────────┐
          │                        ▼                               ▼
          │               isNewUser == true              isNewUser == false
          │                        │                               │
          ▼                        ▼                               ▼
 [Profile Setup Page] ◄── [Setup Profile Screen]          [Navigate to HomePage]
```

### Detailed Token & Credentials Management
- **Phone Number Storage**: Saved in `LocalStorage` under key `phone`.
- **JWT Token Storage**: Stored securely in `SecureStorage` under key `jwt_token`.
- **Bearer Header Injection**: `ApiClient` automatically injects `Authorization: Bearer <JWT_TOKEN>` into all HTTP request headers.
- **Startup Authentication Check**: `SplashPage` reads `SecureStorage.getToken()` and `LocalStorage.getBool('is_logged_in')`. If valid, navigates directly to `RouteNames.home`; otherwise redirects to `RouteNames.login`.
- **Logout Action**: Clears `jwt_token` and `is_logged_in` flag, navigating user back to `RouteNames.login`.
- **Account Deletion**: Invokes `DELETE /api/users/me`, wipes `LocalStorage` and `SecureStorage`, and redirects to `RouteNames.login`.

---

## 4. Profile APIs

### 1. Save Profile (`POST /api/users/profile`)
- **Headers**: `Authorization: Bearer <TOKEN>`
- **Method**: Multipart Form Post
- **Query Parameters**: `name` (String), `about` (String)
- **File Field**: `image` (Uint8List bytes, optional)
- **Local Storage Updated**: Saves `name`, `about`, and `profileImage` URL into `LocalStorage`.

### 2. Delete Account (`DELETE /api/users/me`)
- **Headers**: `Authorization: Bearer <TOKEN>`
- **Behavior**: Calls backend account deletion endpoint, purges all local storage keys, and resets state.

---

## 5. Contact Synchronization APIs (`POST /api/contacts/sync`)

### Contact Sync Sequence

```text
Device Phonebook ──> Read & Normalize Numbers ──> POST /api/contacts/sync
                                                           │
Local Cache: synced_contacts ◄─────────────────────────────┘
          │
          ▼
Contacts List UI (Offline First)
```

- **Endpoint**: `POST /api/contacts/sync`
- **Request Body**:
  ```json
  {
    "contacts": [
      {
        "name": "ConVo User",
        "countryCode": "+91",
        "phoneNumber": "9876543210"
      }
    ],
    "phoneNumbers": ["9876543210", "9910719882"]
  }
  ```
- **Response Format**:
  ```json
  {
    "success": true,
    "message": "Registered contacts fetched successfully",
    "data": [
      {
        "id": 1,
        "name": "Aman",
        "phoneNumber": "8595626824",
        "profileImage": "http://192.168.1.15:7000/uploads/profile/518b9375.jpg",
        "about": "Hey there! I am using ConVo.",
        "status": "ONLINE",
        "online": true
      }
    ]
  }
  ```
- **Local Storage**: Results are serialized into `synced_contacts` in `LocalStorage`. When offline, `ContactsPage` loads registered users directly from `synced_contacts`.

---

## 6. Chat Creation API (`POST /api/chats`)

### ID Terminology Clarification
- **`targetUserId`**: The `id` of the recipient user with whom a chat is being initialized.
- **`receiverId`**: The `targetUserId` when constructing message objects.
- **`chatId`**: The unique conversation container ID created/returned by the server.

### Request / Response Specification
- **Endpoint**: `POST /api/chats`
- **Request Body**:
  ```json
  {
    "targetUserId": 1
  }
  ```
- **Response Structure**:
  ```json
  {
    "success": true,
    "data": {
      "chatId": 11,
      "chatType": "DIRECT",
      "targetUserId": 1
    }
  }
  ```
- **Local Storage Mapping**: Maps `targetUserId -> chatId` in `LocalStorage` key `chat_id_user_$targetUserId`.

---

## 7. Home Chat List API (`GET /api/chats`)

### Request / Response Specification
- **Endpoint**: `GET /api/chats`
- **Response Data Structure**:
  ```json
  {
    "success": true,
    "data": [
      {
        "chatId": 11,
        "chatType": "DIRECT",
        "otherUser": {
          "id": 1,
          "name": "Aman",
          "profileImage": "http://192.168.1.15:7000/uploads/profile/1.jpg",
          "about": "Using ConVo",
          "phoneNumber": "8595626824",
          "online": true
        },
        "lastMessage": {
          "id": 13,
          "chatId": 11,
          "senderId": 6,
          "content": "Hi",
          "status": "SENT",
          "createdAt": "2026-08-19T23:06:40.109759"
        },
        "lastMessageTime": "2026-08-19T23:06:40.109759",
        "unreadCount": 0
      }
    ]
  }
  ```

### Filtering & Sorting Rules Implemented in Flutter (`HomeBloc`)
1. **Direct Chats Only**: Ignores `chatType == "SYSTEM"`.
2. **Non-Empty Messages Only**: Only displays chats where `lastMessage != null` and `lastMessageContent.trim().isNotEmpty`. Empty chats are hidden automatically.
3. **Contact Independence**: Chats appear regardless of whether the recipient is in the phone contact list.
4. **Newest-First Sorting**: Sorted by `lastMessageTime` descending.
5. **Offline Support**: Stores full summary list in `LocalStorage` key `home_chats_list`.

---

## 8. Message APIs (`GET /api/chats/{id}/messages` & `POST /api/messages`)

### 1. Fetch Messages (`GET /api/chats/{chatId}/messages`)
- **Endpoint**: `GET /api/chats/{chatId}/messages`
- **Response**: Returns message objects list inside `data.content`.
- **Local Storage Impact**: Saves messages list to `LocalStorage` key `chat_messages_$chatId`.

### 2. Send Message (`POST /api/messages`)
- **Endpoint**: `POST /api/messages`
- **Request Body**:
  ```json
  {
    "chatId": 11,
    "receiverId": 1,
    "type": "TEXT",
    "content": "Hello",
    "mediaUrl": null,
    "mediaId": null,
    "replyToId": null
  }
  ```
- **Response Data**: Returns the saved `MessageModel` object with server-generated `id`, `createdAt`, and `status: "SENT"`.

---

## 9. Message Model Specification

The Flutter codebase models message data strictly via `MessageEntity` and `MessageModel`:

```dart
class MessageEntity {
  final int id;
  final int chatId;
  final int senderId;
  final int? receiverId;
  final String type;      // "TEXT", "IMAGE", "VIDEO", "AUDIO"
  final String content;   // Message text or media placeholder
  final String? mediaUrl; // Optional uploaded media URL
  final String status;   // "PENDING", "SENT", "DELIVERED", "SEEN"
  final String createdAt; // ISO8601 Timestamp
  final bool seen;        // Read receipt status
}
```

---

## 10. Real-Time WebSocket & STOMP Engine

- **Connection URL**: `ws://192.168.1.15:7000/ws/websocket`
- **Client Library**: `stomp_dart_client`
- **Authentication**: JWT Bearer token passed in `stompConnectHeaders` and `webSocketConnectHeaders`.
- **Subscribed Topics**:
  - `/user/queue/messages`
  - `/topic/chat/$chatId`
  - `/topic/messages`

### Implemented STOMP Events Flow

```text
[Sender] ──> POST /api/messages ──> [Spring Boot Backend]
                                             │
   [Sender UI Updates] ◄── message:seen ─────┴─────► STOMP Event: message:new ──> [Receiver UI Updates]
```

- `message:new`: Broadcasts new message to `ChatBloc` (updates active chat bubbles) and `HomeBloc` (updates last message and moves chat to top).
- `message:seen`: Updates message tick status to double blue tick `✓✓`.
- `notifyMessageSeen`: Automatically triggers when receiver opens active `ChatPage`.

---

## 11. Message Status Tick Matrix

| Icon UI Indicator | Internal Status String | Meaning |
| :--- | :--- | :--- |
| 🕐 `Icons.access_time` | `PENDING` | Optimistic local message waiting to send |
| `✓` `Icons.check` | `SENT` | Accepted by server (single gray tick) |
| `✓✓` `Icons.done_all` (Gray) | `DELIVERED` | Delivered to recipient device |
| `✓✓` `Icons.done_all` (Blue `#64B5F6`) | `SEEN` / `seen: true` | Read by recipient (double blue tick) |

---

## 12. Complete Local Storage Key Registry

| Storage Key / Table | Data Format | Written By | Read By | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `jwt_token` | Secure String | `AuthBloc` / `SecureStorage` | `ApiClient`, `StompService` | Authentication Bearer Token |
| `is_logged_in` | Boolean String | `AuthBloc` | `SplashPage` | Quick login state check |
| `synced_contacts` | JSON Array String | `ContactsLocalDataSource` | `ContactsBloc`, `ContactsPage` | Cached registered contacts for offline view |
| `chat_id_user_$targetUserId` | String (Integer) | `ChatLocalDataSource` | `ContactsPage`, `ChatPage` | Local `targetUserId -> chatId` lookup |
| `chat_messages_$chatId` | JSON Array String | `ChatLocalDataSource` | `ChatBloc`, `ChatPage` | Offline-first message history |
| `chat_user_profile_$chatId` | JSON Object String | `ChatLocalDataSource` | `ChatPage` | Offline contact header info (name, avatar, about) |
| `home_chats_list` | JSON Array String | `HomeLocalDataSource` | `HomeBloc`, `HomePage` | Offline-first Home conversation summaries |

---

## 13. Offline-First Capability Matrix

| Feature / Screen | Offline Supported? | Data Source |
| :--- | :--- | :--- |
| App Startup Check | ✅ Yes | `SecureStorage` & `LocalStorage` |
| Home Conversation List | ✅ Yes | Cached `home_chats_list` |
| View Registered Contacts | ✅ Yes | Cached `synced_contacts` |
| Open Previous Chat | ✅ Yes | Cached `chat_user_profile_$chatId` |
| Read Message History | ✅ Yes | Cached `chat_messages_$chatId` |
| Send New Message | ⚠️ Pending Optimistic | Saved as `PENDING` clock icon locally |
| Image & Media Viewing | ✅ Yes | Cached network/file bytes |
| STOMP WebSocket Sync | ❌ No | Internet connection required |

---

## 14. Media Upload API (`POST /api/media/upload`)

- **Endpoint**: `POST /api/media/upload`
- **Method**: Multipart Form Upload
- **Implementation**: Handled via `ApiClient.postMultipart` in `ChatPage`.
- **Supported Options**: Document, Camera, Gallery, Video, Audio.
- **Upload Response**: Returns `{ success: true, data: { mediaId, mediaUrl } }`.

---

## 15. Screen to API Mapping

| Flutter Screen | Associated APIs Used | Local Storage Keys Used | Real-Time WebSocket |
| :--- | :--- | :--- | :--- |
| **SplashPage** | None | `jwt_token`, `is_logged_in` | ❌ No |
| **LoginPage** | `POST /api/auth/request-otp` | `phone` | ❌ No |
| **OtpPage** | `POST /api/auth/verify-otp` | `jwt_token`, `is_logged_in` | ❌ No |
| **ProfileSetupPage** | `POST /api/users/profile` | `name`, `about`, `profile` | ❌ No |
| **HomePage** | `GET /api/chats` | `home_chats_list` | ⚡ Yes (`message:new`) |
| **ContactsPage** | `POST /api/contacts/sync`, `POST /api/chats` | `synced_contacts`, `chat_id_user_*` | ❌ No |
| **ChatPage** | `GET /api/chats/{id}/messages`, `POST /api/messages` | `chat_messages_*`, `chat_user_profile_*` | ⚡ Yes (All STOMP events) |
| **ContactProfilePage** | None | Local args / cache | ❌ No |

---

## 16. Architecture Diagrams

### 1. Remote Data Flow
```text
[Flutter UI Widget] ──> [BLoC / Cubit] ──> [Repository Impl] ──> [ApiClient] ──> [Spring Boot API (Port 7000)]
```

### 2. Local Storage Flow
```text
[Flutter UI Widget] ◄── [BLoC / Cubit] ◄── [Local DataSource] ◄── [LocalStorage / SharedPreferences]
```

### 3. Real-Time WebSocket Flow
```text
[Spring Boot WebSocket] ──> STOMP ──> [StompService] ──> [ChatRealtimeService Stream] ──> [ChatBloc / HomeBloc] ──> [UI Update]
```

---

## 17. Error Handling Strategy

- **HTTP 400 / 500**: Caught by `ApiClient`, throwing user-friendly exception messages extracted from backend `res["message"]`.
- **HTTP 401 Unauthorized**: Wipes stored tokens and triggers re-authentication redirect.
- **Network Disconnect**: Falls back seamlessly to cached local storage data.
- **WebSocket Connection Loss**: `StompClient` automatically attempts reconnection every 4 seconds (`reconnectDelay`).

---

## 18. Network Environment Configurations

- **Base Server URL**: `http://192.168.1.15:7000` (Defined in `lib/app/config/api_config.dart`).
- **WebSocket URL**: `ws://192.168.1.15:7000/ws/websocket`.
- **Android Emulator IP**: Use `http://10.0.2.2:7000`.
- **Physical Device IP**: Use machine IPv4 address (e.g., `http://192.168.1.15:7000`).

---

## 19. Feature Implementation Status

### ✅ Currently Implemented & Verified
- Phone OTP Request & Verification flow (`/api/auth/*`).
- Dual-mode Profile Setup with custom typing or preset dropdown.
- Background Contact Synchronization & Local Caching (`/api/contacts/sync`).
- Pre-creation and local mapping of conversation `chatId`s (`POST /api/chats`).
- Home Page chat filtering (DIRECT chats only, auto-hiding empty chats, sorting newest-first).
- WhatsApp-style Chat Screen UI (Date separators, emoji-only sizing, mic/send toggle, audio recording, attachment action sheet).
- Real-time STOMP WebSocket messaging (`message:new`, `message:seen`).
- Complete offline-first fallback for Home, Contacts, and Chat screens.

### 🚧 Planned / Future Enhancements
- WebRTC Audio & Video Calling integration (`/calling` route).
- Group Chat management and multi-participant message routing.

---

## 20. End-to-End API Dependency Flow

```text
[APP START]
    │
    ▼
Check Local JWT ──(Exists)──► GET /api/chats ──► Render Home Screen (Offline First)
    │                                                     │
    ▼                                                     ▼
(No Token)                                        Open Contact List
    │                                                     │
    ▼                                                     ▼
POST /api/auth/request-otp                        POST /api/contacts/sync
    │                                                     │
    ▼                                                     ▼
POST /api/auth/verify-otp                         POST /api/chats (Get chatId)
    │                                                     │
    ▼                                                     ▼
Save Bearer JWT Token                             GET /api/chats/{chatId}/messages
    │                                                     │
    └─────────────────────────────────────────────────────┴──► Connect STOMP WebSocket ──► Real-Time Messaging
```

---

## 21. Developer Quick Reference

- **Base API URL**: `http://192.168.1.15:7000`
- **STOMP WebSocket URL**: `ws://192.168.1.15:7000/ws/websocket`
- **Authorization Header**: `Authorization: Bearer <JWT_TOKEN>`
- **Key Injection File**: [`lib/injection/dependency_injection.dart`](file:///e:/git_projects/Convo/lib/injection/dependency_injection.dart)
- **Key Configuration File**: [`lib/app/config/api_config.dart`](file:///e:/git_projects/Convo/lib/app/config/api_config.dart)
- **Primary BLoCs**: `AuthBloc`, `ContactsBloc`, `ChatBloc`, `HomeBloc`
- **Primary Storage Keys**: `jwt_token`, `synced_contacts`, `home_chats_list`, `chat_messages_$chatId`