# 🐦 Flock — Meet & Hangout

> *Stop wandering alone. Find your flock.*

Flock is a real-time, location-based spontaneous social activity app that connects people who are bored and available **right now** — safely.

---

## 🎯 Problem

You're free in the evening. No plans, no friends available. You go out and wander aimlessly — nothing to do, no one to do it with.

Current apps don't solve this:
- **Meetup** → Too formal, requires planning ahead
- **Tinder** → Dating only, not friendship/activity
- **Facebook Events** → Outdated, not spontaneous

**Flock fills this gap.**

---

## 💡 Concept

Open the app. One question:

> *"What do you want to do right now?"*

Pick an activity — coffee, food, billiards, a walk, cinema, board games...

Instantly see nearby people posting the same vibe. Join someone's invite or post your own. It expires in 2 hours. No pressure, no commitment.

---

## ✨ Core Features

### 🗺️ Activity Feed
- Real-time map + list view of nearby active invites
- Filter by activity type, distance, group size
- Invites expire automatically (2 hours max)

### 👤 Profile & Trust Score
- Verified identity — no anonymous accounts
- Activity history visible to others
- Trust score grows with every positive meetup

### 💬 In-App Messaging
- Chat with group before meeting
- AI-monitored for safety flags
- No external contact info sharing required

### 📍 Venue-Anchored Meetups
- Meetups happen only at partner venues (cafés, restaurants, public spaces)
- No "meet me anywhere" — always a known, safe location

### 👥 Group-Only Model
- Minimum 3 people per activity
- No 1-on-1 stranger meetups
- Reduces risk dramatically

---

## 🔒 Safety System

Safety is not an afterthought — it's the foundation of Flock.

| Layer | Feature |
|-------|---------|
| 🪪 Identity | TC ID + selfie verification, e-Devlet API |
| 📹 Video Check | Real-time face match to profile photo |
| 👥 Group Model | Minimum 3 people, no solo meetups |
| 🏠 Partner Venues | Meetups only at verified locations |
| 🤝 Mutual Contacts | Shows shared friends via phone/Instagram |
| ⭐ Rating System | Post-activity mutual ratings, low scores = reduced visibility |
| 🔒 Account Maturity | New accounts limited; trust unlocks features over time |
| 📍 Silent Tracking | Share live location with a trusted contact during activity |
| ✅ Check-in System | "I arrived safely" button; auto-notifies trusted contact if missed |
| 🚨 SOS Button | One tap → shares location + connects to 112 |
| 🤖 AI Chat Monitor | Detects threatening language, auto-flags & suspends |
| 🌙 First-Meet Protocol | First meetup: daytime only, partner venue only, 3+ people |

---

## 💰 Revenue Model

| Tier | Details | Price |
|------|---------|-------|
| Free | 3 invites/day, basic filters | ₺0 |
| Premium | Unlimited invites, advanced filters, priority visibility | ₺99/month |
| Venue Partner | Cafés & restaurants pay to be featured | B2B package |
| Boost | Promote your invite to more nearby users | ₺15/boost |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (iOS + Android) |
| Backend | Firebase (Firestore, Auth, Cloud Functions) |
| Real-time Location | Firebase Realtime Database + Google Maps API |
| Messaging | Firebase Cloud Messaging |
| AI Safety | Custom NLP model + moderation API |
| Identity Verification | e-Devlet API + third-party KYC |
| Push Notifications | Firebase Cloud Messaging (FCM) |

---

## 📱 App Screens (MVP)

```
Onboarding
├── Phone verification
├── ID verification (TC + selfie)
└── Interest selection

Home
├── Map view (nearby invites)
├── List view (nearby invites)
└── Filter bar (activity, distance)

Create Invite
├── Activity type
├── Time (now → max 2h)
├── Venue selection (partner venues)
└── Group size (min 3)

Invite Detail
├── Activity info
├── Attendee profiles + trust scores
├── Join button
└── In-app chat

Profile
├── My info + trust score
├── Activity history
├── Ratings received
└── Trusted contact settings

Safety Center
├── SOS button
├── Active location share
├── Check-in timer
└── Report user
```

---

## 🗺️ MVP Roadmap

### Phase 1 — Foundation (Weeks 1–2)
- [ ] Flutter project setup
- [ ] Firebase integration
- [ ] Auth flow (phone + ID verification)
- [ ] Basic profile creation

### Phase 2 — Core Features (Weeks 3–4)
- [ ] Create & browse invites
- [ ] Google Maps integration
- [ ] Real-time location feed
- [ ] Partner venue database (seed data)

### Phase 3 — Safety Layer (Weeks 5–6)
- [ ] Trusted contact + location sharing
- [ ] Check-in system
- [ ] In-app chat + AI moderation
- [ ] Rating system

### Phase 4 — Polish & Launch (Weeks 7–8)
- [ ] UI/UX polish
- [ ] Push notifications
- [ ] Beta test (Konya pilot)
- [ ] App Store + Google Play submission

---

## 🚀 Launch Strategy

1. **Pilot city: Konya** — controlled launch, gather feedback
2. **University campuses** — highest density of bored young people
3. **Venue partnerships first** — get 10-15 partner venues before launch
4. **Social proof loop** — every successful meetup = shareable story

---

## 🌍 Target Market

- **Primary:** Turkey (18–35 age group, urban)
- **Secondary:** MENA region (similar social dynamics)
- **Long-term:** Global (loneliness epidemic is worldwide)

---

## 👤 Founder

Built by [Your Name] — entrepreneur & software developer based in Konya, Turkey.

---

## 📄 License

Private repository — all rights reserved.

---

*Flock — Because wandering alone is overrated.*
