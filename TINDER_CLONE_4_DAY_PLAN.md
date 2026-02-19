# Tinder Clone – 4 Day Delivery Plan (Flutter + Backend)

This plan is based on your current project state where authentication (login/signup) is already implemented.

## Current state in this repo
- Auth flow and clean architecture layers are present (`data/domain/presentation`).
- API endpoints currently include only `signup` and `login`.
- App base URL is configured for Android emulator (`10.0.2.2:3000`).

---

## Delivery goal (4 days)
Build and ship an MVP that includes:
1. Login / Signup ✅ (already started)
2. Swipe feed (like/pass)
3. Match creation when two users like each other
4. Basic chat for matched users
5. Human verification page (KYC-lite + selfie/liveness submission)
6. Deployable backend + production-ready mobile configs

---

## Suggested feature scope (MVP only)
Keep only essential Tinder-like flows for 4-day delivery:

- Onboarding/profile setup (name, age, gender, interests, photos)
- Swipe cards (like/dislike)
- Matches list
- Chat page (text-only first)
- Verification page (upload ID + selfie, submit to backend)
- Optional: location filtering (simple radius)

Avoid for now (save for phase 2):
- Video calling
- Stories/reels
- AI recommendations
- Complex boosts/super likes
- Payment subscriptions

---

## What you should add in backend
Right now backend likely has only auth APIs. Add these modules next:

## 1) Profile module
- `GET /users/me`
- `PUT /users/me`
- `POST /users/me/photos` (multipart upload)
- `DELETE /users/me/photos/:photoId`

Data fields:
- `id, username, email`
- `age, gender, bio, interests[]`
- `photos[]`
- `location (lat, lng)`
- `isVerified` (bool)
- `verificationStatus` (`none | pending | approved | rejected`)

## 2) Discovery/Swipe module
- `GET /discovery?limit=20&cursor=...`
- `POST /swipes` with body `{ targetUserId, action: "like" | "pass" }`

Rules:
- Never return self
- Exclude users already swiped
- Optionally filter by distance/gender preferences

## 3) Match module
- `GET /matches`
- Server creates match when A likes B and B likes A
- Return `matchId`, `user`, `matchedAt`

## 4) Chat module
- `GET /matches/:matchId/messages`
- `POST /matches/:matchId/messages`
- Add realtime via WebSocket / Socket.IO if possible

Minimum message model:
- `id, matchId, senderId, text, createdAt, seen`

## 5) Verification module (your required “identify human” page)
- `POST /verification/submit` (ID front/back + selfie)
- `GET /verification/status`
- Admin-side action endpoint for approval/rejection

Recommended checks:
- 1 account per phone/email/device rule
- selfie required
- optional liveness prompt (blink/turn head) if time permits

## 6) Trust & safety essentials
- `POST /report` (report user)
- `POST /block` (block user)
- `DELETE /matches/:id` (unmatch)

---

## What to change in Flutter app structure now
You already have an auth feature; create new features with same pattern:

- `features/profile`
- `features/discovery`
- `features/match`
- `features/chat`
- `features/verification`

For each feature, keep:
- `data/` (models, remote datasource, repository impl)
- `domain/` (entities, repository contracts, usecases)
- `presentation/` (pages, widgets, viewmodels/providers, state)

This keeps your code maintainable and deployable.

---

## 4-day execution plan

## Day 1 – Core profile + discovery setup
1. Complete profile create/edit page.
2. Add profile photo upload support.
3. Add discovery API integration + swipe card UI.
4. Persist JWT and fetch `/users/me` on app start.

Deliverable:
- User can sign in, complete profile, and see swipe cards.

## Day 2 – Swipes to matches
1. Wire like/pass API from swipe page.
2. Build matches list page.
3. Handle “it’s a match” event after mutual like.
4. Add block/report actions in profile card overflow menu.

Deliverable:
- Mutual likes create visible matches.

## Day 3 – Chat + verification page
1. Build chat UI for each match.
2. Implement send/load messages (polling first, realtime optional).
3. Create verification page:
   - ID upload
   - selfie upload
   - submit button
   - verification status badge

Deliverable:
- Matched users can chat; verification request can be submitted.

## Day 4 – Stabilize + deploy
1. Error handling and retries.
2. Form validation and loading states.
3. Test key flows on Android (and iOS if available).
4. Backend deployment + mobile production config update.
5. Prepare app demo script and fallback data.

Deliverable:
- Demo-ready MVP you can deploy.

---

## Backend checklist before giving access to frontend
Ask backend team (or do yourself) to confirm:
- [ ] JWT auth with refresh strategy or stable long-lived token for MVP
- [ ] CORS + rate limiting enabled
- [ ] File upload storage configured (S3/Cloudinary/local)
- [ ] DB indexes on swipe/match/message tables
- [ ] API docs (Postman/Swagger) shared
- [ ] Seed script for test users
- [ ] Verification status endpoints complete
- [ ] Basic moderation endpoints (report/block)

---

## Deployment checklist

Backend:
- Use Render/Railway/Fly/EC2
- Set env vars: DB URL, JWT secret, storage keys, CORS origins
- Enable HTTPS

Flutter app:
- Replace local base URL with production URL in `ApiEndpoints`
- Create flavor/env config (dev/stage/prod)
- Test release build:
  - `flutter build apk --release`
  - `flutter build appbundle --release`

---

## Immediate code TODOs in this repo
1. Remove artificial `Future.delayed(3s)` from login/signup view model before production.
2. Add endpoint constants for profile/discovery/swipe/match/chat/verification.
3. Add auth guard + token expiry handling.
4. Add central typed failure mapping for API errors.
5. Introduce environment-based base URL (not hardcoded emulator URL in production).

---

## If you share design/backend access
If you provide design and backend access, the fastest sequence is:
1. Freeze exact MVP screens (no scope creep)
2. Freeze API contract first
3. Build feature-by-feature in same order as 4-day plan
4. Daily checkpoint with “working demo build”

This is the safest way to ship in 4 days.
