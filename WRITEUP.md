# Lumi Beauty – writeup

**What it does:** A cosmetics shopping app: login, browse, search, product details, favorites and a cart. It runs on Android and in the browser.

**Why I built it:** I wanted to learn Flutter through a complete shopping flow, not a tutorial screen. I used Claude Code to write much of the code; my part was deciding the scope and design and checking that each feature behaved correctly.

**Decisions and tradeoffs:**
- Provider instead of Bloc: less boilerplate for a 7-screen app; I'd revisit it if the app grew.
- Cart in SQLite, not shared_preferences: the cart is structured data (items, quantity, stock limits) that I need to query.
- Search waits 400 ms after typing: fewer API calls and less flicker, at the cost of a small delay.
- A web build (SQLite via WebAssembly) so anyone can try it without installing an APK; the trade is a slower first load.

**What I'd do next:** add a real checkout and track where users leave the flow.
